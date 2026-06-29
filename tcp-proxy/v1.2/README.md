# TCP Proxy v1.2

轻量级 **TCP 透明代理** 容器，通过环境变量配置 1～N 条转发规则。

v1.2 以 **四层 TCP 转发** 为默认模式，原生支持 **HTTP、HTTPS、WebSocket** 及任意基于 TCP 的协议（TLS 不终止，字节流原样透传）。

## 与 v1.1 的关键区别

| 场景 | v1.1 | v1.2 |
|------|------|------|
| `443,https://host:443` | HTTP 七层反向代理 | **TCP 透明代理**（推荐 HTTPS 用法） |
| `80,http://host:80` | HTTP 七层反向代理 | **TCP 透明代理** |
| WebSocket | 需 L7 代理 | TCP 透传即可 |
| 七层反向代理 | 默认 | 仅 `HTTP_PROXIES` / `l7,` 前缀时启用 |

## 配置格式

### TCP 透明代理（默认）

```text
本地端口,目标地址
```

目标地址支持以下写法：

```text
443,cf.emerald-atelier.com:443
443,https://cf.emerald-atelier.com:443
80,http://backend.internal
3306,mysql.example.com:3306
```

`http://`、`https://` 仅用于解析 host 与端口（省略端口时默认 80/443），**不会**做 HTTP 反向代理。

### HTTPS 示例

本地监听 443，透明转发到远端 HTTPS 服务：

```bash
-e PROXIES="443,https://cf.emerald-atelier.com:443"
```

客户端（浏览器、curl）应对 `https://localhost` 或 `https://127.0.0.1` 发起 TLS 连接，代理只转发 TCP 字节，证书由远端服务器提供。

### HTTP 示例

```bash
-e PROXIES="80,http://backend.internal:80"
```

### 七层 HTTP 反向代理（可选）

仅在需要由代理解析 HTTP 请求、改写 Host 等场景使用：

```text
l7,8080,http://backend.internal:80
```

或通过 `HTTP_PROXIES` / `HTTP_PROXY_N` 配置（与 v1.1 相同）。

## 环境变量

| 变量 | 说明 |
|------|------|
| `PROXIES` | 默认 **TCP 透明代理** |
| `TCP_PROXIES` | TCP 透明代理（与 `PROXIES` 等价） |
| `HTTP_PROXIES` | **七层** HTTP/WebSocket 反向代理 |
| `PROXY_1` ~ `PROXY_N` | 编号配置 |
| `TCP_PROXY_1` ~ `TCP_PROXY_N` | 编号 TCP（兼容 v1.0） |
| `HTTP_PROXY_1` ~ `HTTP_PROXY_N` | 编号 L7 HTTP |

多个代理用分号 `;` 或换行分隔。同一本地端口不能重复。

## 构建镜像

```bash
docker build -t tcp-proxy:1.2 .
```

## 运行示例

### HTTPS 透明代理

```bash
docker run -d --name tcp-proxy \
  -p 443:443 \
  -e PROXIES="443,https://cf.emerald-atelier.com:443" \
  tcp-proxy:1.2
```

启动日志示例：

```text
已启动 1 个代理
  [TCP/HTTPS] 0.0.0.0:443 -> cf.emerald-atelier.com:443
[TCP/HTTPS] 监听 0.0.0.0:443，透明转发至 cf.emerald-atelier.com:443
```

### 同时代理 HTTP + HTTPS

```bash
docker run -d --name tcp-proxy \
  -p 80:80 -p 443:443 \
  -e PROXIES="80,http://cf.emerald-atelier.com:80;443,https://cf.emerald-atelier.com:443" \
  tcp-proxy:1.2
```

### docker compose

```bash
docker compose up -d --build
```

## 注意事项

1. 容器内监听 `0.0.0.0:本地端口`，需在 `ports` 中映射到宿主机。
2. **HTTPS 透明代理**不终止 TLS；若访问 `https://127.0.0.1:443`，浏览器会因证书域名不匹配告警（证书仍是远端域名），属正常现象。
3. 需要本地证书或 Host 改写时，请使用 `HTTP_PROXIES` 七层模式，而非 TCP 模式。
4. WebSocket over HTTPS 在 TCP 模式下随 TLS 流一并透传，无需额外配置。
5. 监听 443 等特权端口时，确保容器有权限绑定（或使用 `-p 8443:443` 映射非特权端口）。
