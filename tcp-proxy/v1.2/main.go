package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"
	"sync"
	"time"
)

type proxyType int

const (
	proxyTCP proxyType = iota
	proxyHTTP
)

type proxyRule struct {
	kind       proxyType
	listenAddr string
	targetAddr string
	protocol   string // 日志用: tcp / http / https
	targetURL  *url.URL
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lmicroseconds)

	rules, err := loadRules()
	if err != nil {
		log.Fatalf("配置错误: %v", err)
	}
	if len(rules) == 0 {
		log.Fatal("未找到任何代理配置，请设置 PROXIES / TCP_PROXIES / HTTP_PROXIES 或 PROXY_1、PROXY_2 ...")
	}

	var wg sync.WaitGroup
	for _, rule := range rules {
		wg.Add(1)
		go func(r proxyRule) {
			defer wg.Done()
			if err := serveRule(r); err != nil {
				log.Fatalf("代理 %s 启动失败: %v", r.listenAddr, err)
			}
		}(rule)
	}

	log.Printf("已启动 %d 个代理", len(rules))
	for _, rule := range rules {
		switch rule.kind {
		case proxyTCP:
			log.Printf("  [TCP/%s] %s -> %s", strings.ToUpper(rule.protocol), rule.listenAddr, rule.targetAddr)
		case proxyHTTP:
			log.Printf("  [HTTP/L7] %s -> %s (含 WebSocket)", rule.listenAddr, rule.targetURL)
		}
	}

	wg.Wait()
}

func loadRules() ([]proxyRule, error) {
	var entries []rawEntry

	if raw := strings.TrimSpace(os.Getenv("PROXIES")); raw != "" {
		for _, part := range splitMulti(raw) {
			part = strings.TrimSpace(part)
			if part != "" {
				entries = append(entries, rawEntry{value: part, numbered: false})
			}
		}
	}

	if raw := strings.TrimSpace(os.Getenv("TCP_PROXIES")); raw != "" {
		for _, part := range splitMulti(raw) {
			part = strings.TrimSpace(part)
			if part != "" {
				entries = append(entries, rawEntry{value: part, numbered: false, forceTCP: true})
			}
		}
	}

	if raw := strings.TrimSpace(os.Getenv("HTTP_PROXIES")); raw != "" {
		for _, part := range splitMulti(raw) {
			part = strings.TrimSpace(part)
			if part != "" {
				entries = append(entries, rawEntry{value: part, numbered: false, forceHTTP: true})
			}
		}
	}

	for i := 1; i <= 100; i++ {
		key := fmt.Sprintf("PROXY_%d", i)
		if raw := strings.TrimSpace(os.Getenv(key)); raw != "" {
			entries = append(entries, rawEntry{value: raw, numbered: true})
		}
		key = fmt.Sprintf("TCP_PROXY_%d", i)
		if raw := strings.TrimSpace(os.Getenv(key)); raw != "" {
			entries = append(entries, rawEntry{value: raw, numbered: true, forceTCP: true})
		}
		key = fmt.Sprintf("HTTP_PROXY_%d", i)
		if raw := strings.TrimSpace(os.Getenv(key)); raw != "" {
			entries = append(entries, rawEntry{value: raw, numbered: true, forceHTTP: true})
		}
	}

	rules := make([]proxyRule, 0, len(entries))
	seenListen := make(map[string]struct{})

	for idx, entry := range entries {
		rule, err := parseEntry(entry)
		if err != nil {
			label := fmt.Sprintf("第 %d 条配置 %q", idx+1, entry.value)
			if entry.numbered {
				label = fmt.Sprintf("配置 %q", entry.value)
			}
			return nil, fmt.Errorf("%s: %w", label, err)
		}
		if _, exists := seenListen[rule.listenAddr]; exists {
			return nil, fmt.Errorf("监听地址重复: %s", rule.listenAddr)
		}
		seenListen[rule.listenAddr] = struct{}{}
		rules = append(rules, rule)
	}

	return rules, nil
}

type rawEntry struct {
	value     string
	numbered  bool
	forceTCP  bool
	forceHTTP bool
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

func parseEntry(entry rawEntry) (proxyRule, error) {
	value := entry.value

	if entry.forceTCP && entry.forceHTTP {
		return proxyRule{}, fmt.Errorf("不能同时强制 TCP 与 HTTP(L7) 类型")
	}

	// 显式类型前缀
	if parts := strings.SplitN(value, ",", 3); len(parts) == 3 {
		typeName := strings.ToLower(strings.TrimSpace(parts[0]))
		localPort := strings.TrimSpace(parts[1])
		target := strings.TrimSpace(parts[2])
		switch typeName {
		case "tcp", "http", "https", "ws", "websocket":
			if typeName == "http" || typeName == "ws" || typeName == "websocket" {
				if entry.forceTCP {
					return parseTCPRule(localPort, target)
				}
				return parseHTTPRule(localPort, target)
			}
			return parseTCPRule(localPort, target)
		case "l7", "reverse":
			return parseHTTPRule(localPort, target)
		}
	}

	if entry.forceHTTP {
		return parseLegacyHTTPRule(value)
	}

	// 默认 TCP 透明代理（含 http://、https:// URL 写法）
	return parseLegacyTCPRule(value)
}

func parseLegacyTCPRule(entry string) (proxyRule, error) {
	parts := strings.SplitN(entry, ",", 2)
	if len(parts) != 2 {
		return proxyRule{}, fmt.Errorf("格式应为 \"本地端口,目标地址\" 或 \"本地端口,目标URL\"")
	}
	return parseTCPRule(strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1]))
}

func parseLegacyHTTPRule(entry string) (proxyRule, error) {
	parts := strings.SplitN(entry, ",", 2)
	if len(parts) != 2 {
		return proxyRule{}, fmt.Errorf("HTTP(L7) 格式应为 \"本地端口,目标URL\"")
	}
	return parseHTTPRule(strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1]))
}

func parseTCPRule(localPort, target string) (proxyRule, error) {
	if localPort == "" || target == "" {
		return proxyRule{}, fmt.Errorf("本地端口和目标地址不能为空")
	}

	if _, err := net.LookupPort("tcp", localPort); err != nil {
		return proxyRule{}, fmt.Errorf("无效本地端口 %q", localPort)
	}

	targetAddr, protocol, err := normalizeTCPTarget(target)
	if err != nil {
		return proxyRule{}, err
	}

	host, port, err := net.SplitHostPort(targetAddr)
	if err != nil {
		return proxyRule{}, fmt.Errorf("无效目标地址 %q: %w", targetAddr, err)
	}
	if host == "" {
		return proxyRule{}, fmt.Errorf("目标主机不能为空")
	}
	if _, err := net.LookupPort("tcp", port); err != nil {
		return proxyRule{}, fmt.Errorf("无效目标端口 %q", port)
	}

	return proxyRule{
		kind:       proxyTCP,
		listenAddr: net.JoinHostPort("0.0.0.0", localPort),
		targetAddr: targetAddr,
		protocol:   protocol,
	}, nil
}

// normalizeTCPTarget 将 host:port 或 http(s):// URL 转为 TCP 目标地址。
func normalizeTCPTarget(target string) (addr string, protocol string, err error) {
	if strings.HasPrefix(target, "http://") || strings.HasPrefix(target, "https://") {
		parsed, parseErr := url.Parse(target)
		if parseErr != nil {
			return "", "", fmt.Errorf("无效目标 URL %q: %w", target, parseErr)
		}
		if parsed.Host == "" {
			return "", "", fmt.Errorf("目标 URL 缺少 host")
		}
		host := parsed.Hostname()
		port := parsed.Port()
		switch {
		case port != "":
		case parsed.Scheme == "https":
			port = "443"
		default:
			port = "80"
		}
		return net.JoinHostPort(host, port), parsed.Scheme, nil
	}

	host, port, splitErr := net.SplitHostPort(target)
	if splitErr != nil {
		return "", "", fmt.Errorf("无效目标地址 %q，应为 host:port 或 http(s)://host[:port]", target)
	}

	protocol = "tcp"
	switch port {
	case "80":
		protocol = "http"
	case "443":
		protocol = "https"
	}

	return net.JoinHostPort(host, port), protocol, nil
}

func parseHTTPRule(localPort, target string) (proxyRule, error) {
	if localPort == "" || target == "" {
		return proxyRule{}, fmt.Errorf("本地端口和目标 URL 不能为空")
	}

	if _, err := net.LookupPort("tcp", localPort); err != nil {
		return proxyRule{}, fmt.Errorf("无效本地端口 %q", localPort)
	}

	if !strings.Contains(target, "://") {
		target = "http://" + target
	}

	parsed, err := url.Parse(target)
	if err != nil {
		return proxyRule{}, fmt.Errorf("无效目标 URL %q: %w", target, err)
	}
	if parsed.Scheme != "http" && parsed.Scheme != "https" {
		return proxyRule{}, fmt.Errorf("目标 URL 协议必须为 http 或 https，当前为 %q", parsed.Scheme)
	}
	if parsed.Host == "" {
		return proxyRule{}, fmt.Errorf("目标 URL 缺少 host")
	}

	return proxyRule{
		kind:       proxyHTTP,
		listenAddr: net.JoinHostPort("0.0.0.0", localPort),
		targetURL:  parsed,
	}, nil
}

func serveRule(rule proxyRule) error {
	switch rule.kind {
	case proxyTCP:
		return serveTCPProxy(rule)
	case proxyHTTP:
		return serveHTTPProxy(rule)
	default:
		return fmt.Errorf("未知代理类型")
	}
}

func serveTCPProxy(rule proxyRule) error {
	ln, err := net.Listen("tcp", rule.listenAddr)
	if err != nil {
		return err
	}
	log.Printf("[TCP/%s] 监听 %s，透明转发至 %s", strings.ToUpper(rule.protocol), rule.listenAddr, rule.targetAddr)

	for {
		client, err := ln.Accept()
		if err != nil {
			log.Printf("[TCP/%s] 接受连接失败 [%s]: %v", strings.ToUpper(rule.protocol), rule.listenAddr, err)
			continue
		}
		go handleTCPConn(client, rule)
	}
}

func handleTCPConn(client net.Conn, rule proxyRule) {
	defer client.Close()

	target, err := net.Dial("tcp", rule.targetAddr)
	if err != nil {
		log.Printf("[TCP/%s] 连接目标失败 %s -> %s: %v", strings.ToUpper(rule.protocol), client.RemoteAddr(), rule.targetAddr, err)
		return
	}
	defer target.Close()

	log.Printf("[TCP/%s] 已建立连接 %s -> %s (%s)", strings.ToUpper(rule.protocol), client.RemoteAddr(), rule.targetAddr, rule.listenAddr)

	var wg sync.WaitGroup
	wg.Add(2)

	copyConn := func(dst, src net.Conn, direction string) {
		defer wg.Done()
		written, err := io.Copy(dst, src)
		if err != nil && !isClosed(err) {
			log.Printf("[TCP/%s] 转发异常 [%s] %s: %v", strings.ToUpper(rule.protocol), rule.listenAddr, direction, err)
		}
		_ = closeWrite(dst)
		log.Printf("[TCP/%s] 连接关闭 [%s] %s，传输 %d 字节", strings.ToUpper(rule.protocol), rule.listenAddr, direction, written)
	}

	go copyConn(target, client, "client->target")
	go copyConn(client, target, "target->client")

	wg.Wait()
}

func serveHTTPProxy(rule proxyRule) error {
	target := rule.targetURL
	proxy := httputil.NewSingleHostReverseProxy(target)

	originalDirector := proxy.Director
	proxy.Director = func(req *http.Request) {
		originalDirector(req)
		req.Host = target.Host
	}

	proxy.ErrorHandler = func(w http.ResponseWriter, r *http.Request, err error) {
		log.Printf("[HTTP/L7] 代理错误 [%s] %s %s: %v", rule.listenAddr, r.Method, r.URL.Path, err)
		http.Error(w, "Bad Gateway", http.StatusBadGateway)
	}

	proxy.ModifyResponse = func(resp *http.Response) error {
		if resp.StatusCode == http.StatusSwitchingProtocols {
			log.Printf("[HTTP/L7] WebSocket 升级 [%s] -> %s", rule.listenAddr, target)
		}
		return nil
	}

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("[HTTP/L7] %s %s <- %s", r.Method, r.URL.Path, r.RemoteAddr)
		proxy.ServeHTTP(w, r)
	})

	server := &http.Server{
		Addr:              rule.listenAddr,
		Handler:           handler,
		ReadHeaderTimeout: 10 * time.Second,
	}

	log.Printf("[HTTP/L7] 监听 %s，反向代理至 %s（含 WebSocket）", rule.listenAddr, target)
	return server.ListenAndServe()
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
