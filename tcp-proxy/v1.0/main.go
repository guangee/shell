package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"strings"
	"sync"
)

type proxyRule struct {
	listenAddr string
	targetAddr string
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lmicroseconds)

	rules, err := loadRules()
	if err != nil {
		log.Fatalf("配置错误: %v", err)
	}
	if len(rules) == 0 {
		log.Fatal("未找到任何代理配置，请设置 TCP_PROXIES 或 TCP_PROXY_1、TCP_PROXY_2 ...")
	}

	var wg sync.WaitGroup
	for _, rule := range rules {
		wg.Add(1)
		go func(r proxyRule) {
			defer wg.Done()
			if err := serveProxy(r); err != nil {
				log.Fatalf("代理 %s -> %s 启动失败: %v", r.listenAddr, r.targetAddr, err)
			}
		}(rule)
	}

	log.Printf("已启动 %d 个 TCP 代理", len(rules))
	for _, rule := range rules {
		log.Printf("  %s -> %s", rule.listenAddr, rule.targetAddr)
	}

	wg.Wait()
}

func loadRules() ([]proxyRule, error) {
	var entries []string

	if raw := strings.TrimSpace(os.Getenv("TCP_PROXIES")); raw != "" {
		for _, part := range splitMulti(raw) {
			part = strings.TrimSpace(part)
			if part != "" {
				entries = append(entries, part)
			}
		}
	}

	for i := 1; i <= 100; i++ {
		key := fmt.Sprintf("TCP_PROXY_%d", i)
		raw := strings.TrimSpace(os.Getenv(key))
		if raw != "" {
			entries = append(entries, raw)
		}
	}

	rules := make([]proxyRule, 0, len(entries))
	seenListen := make(map[string]struct{})

	for idx, entry := range entries {
		rule, err := parseRule(entry)
		if err != nil {
			return nil, fmt.Errorf("第 %d 条配置 %q: %w", idx+1, entry, err)
		}
		if _, exists := seenListen[rule.listenAddr]; exists {
			return nil, fmt.Errorf("监听地址重复: %s", rule.listenAddr)
		}
		seenListen[rule.listenAddr] = struct{}{}
		rules = append(rules, rule)
	}

	return rules, nil
}

func splitMulti(raw string) []string {
	raw = strings.ReplaceAll(raw, "\n", ";")
	raw = strings.ReplaceAll(raw, "\r", "")
	var parts []string
	for _, part := range strings.Split(raw, ";") {
		part = strings.TrimSpace(part)
		if part != "" {
			parts = append(parts, part)
		}
	}
	return parts
}

func parseRule(entry string) (proxyRule, error) {
	parts := strings.SplitN(entry, ",", 2)
	if len(parts) != 2 {
		return proxyRule{}, fmt.Errorf("格式应为 \"本地端口,目标地址:目标端口\"")
	}

	localPort := strings.TrimSpace(parts[0])
	target := strings.TrimSpace(parts[1])
	if localPort == "" || target == "" {
		return proxyRule{}, fmt.Errorf("本地端口和目标地址不能为空")
	}

	if _, err := net.LookupPort("tcp", localPort); err != nil {
		return proxyRule{}, fmt.Errorf("无效本地端口 %q", localPort)
	}

	host, port, err := net.SplitHostPort(target)
	if err != nil {
		return proxyRule{}, fmt.Errorf("无效目标地址 %q，应为 host:port 或 ip:port", target)
	}
	if host == "" {
		return proxyRule{}, fmt.Errorf("目标主机不能为空")
	}
	if _, err := net.LookupPort("tcp", port); err != nil {
		return proxyRule{}, fmt.Errorf("无效目标端口 %q", port)
	}

	return proxyRule{
		listenAddr: net.JoinHostPort("0.0.0.0", localPort),
		targetAddr: net.JoinHostPort(host, port),
	}, nil
}

func serveProxy(rule proxyRule) error {
	ln, err := net.Listen("tcp", rule.listenAddr)
	if err != nil {
		return err
	}
	log.Printf("监听 %s，转发至 %s", rule.listenAddr, rule.targetAddr)

	for {
		client, err := ln.Accept()
		if err != nil {
			log.Printf("接受连接失败 [%s]: %v", rule.listenAddr, err)
			continue
		}
		go handleConn(client, rule)
	}
}

func handleConn(client net.Conn, rule proxyRule) {
	defer client.Close()

	target, err := net.Dial("tcp", rule.targetAddr)
	if err != nil {
		log.Printf("连接目标失败 %s -> %s: %v", client.RemoteAddr(), rule.targetAddr, err)
		return
	}
	defer target.Close()

	log.Printf("已建立连接 %s -> %s (%s)", client.RemoteAddr(), rule.targetAddr, rule.listenAddr)

	var wg sync.WaitGroup
	wg.Add(2)

	copyConn := func(dst, src net.Conn, direction string) {
		defer wg.Done()
		written, err := io.Copy(dst, src)
		if err != nil && !isClosed(err) {
			log.Printf("转发异常 [%s] %s: %v", rule.listenAddr, direction, err)
		}
		_ = closeWrite(dst)
		log.Printf("连接关闭 [%s] %s，传输 %d 字节", rule.listenAddr, direction, written)
	}

	go copyConn(target, client, "client->target")
	go copyConn(client, target, "target->client")

	wg.Wait()
}

func isClosed(err error) bool {
	if err == nil {
		return false
	}
	msg := err.Error()
	return strings.Contains(msg, "use of closed network connection") ||
		strings.Contains(msg, "connection reset by peer") ||
		strings.Contains(msg, "broken pipe")
}

func closeWrite(conn net.Conn) error {
	if tcpConn, ok := conn.(*net.TCPConn); ok {
		return tcpConn.CloseWrite()
	}
	return conn.Close()
}
