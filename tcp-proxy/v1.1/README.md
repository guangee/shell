# TCP / HTTP / WebSocket Proxy v1.1

轻量级多协议代理容器，通过环境变量快速配置 1～N 条转发规则。

在 v1.0 的 **TCP 代理** 基础上，v1.1 新增 **HTTP 反向代理** 与 **WebSocket 代理**（WebSocket 通过 HTTP Upgrade 自动处理，与 HTTP 共用同一监听端口）。

## 配置格式

### TCP 代理

```text
本地端口,目标地址:目标端口
```

示例：

```text
3306,mysql.example.com:3306
6379,192.168.1.10:6379
```

### HTTP / WebSocket 代理

```text
本地端口,目标URL
```

目标 URL 必须以 `http://` 或 `https://` 开头。WebSocket 请求（`Upgrade: websocket`）会由同一 HTTP 代理自动转发。

示例：

```text
8080,http://backend.internal:80
8443,https://api.example.com
8081,http://ws-backend.internal:8080
```

### 显式类型前缀（可选）

在 `PROXIES` 中可使用三字段格式明确指定类型：

```text
tcp,3306,mysql.example.com:3306
http,8080,http://backend.internal:80
ws,8081,http://ws-backend.internal:8080
```

`http`、`ws`、`websocket` 均表示 HTTP/WebSocket 代理。

## 环境变量

| 变量 | 说明 |
|------|------|
| `PROXIES` | 统一配置，自动识别 TCP / HTTP |
| `TCP_PROXIES` | 仅 TCP 规则（与 v1.0 兼容） |
| `HTTP_PROXIES` | 仅 HTTP/WebSocket 规则 |
| `PROXY_1` ~ `PROXY_N` | 编号统一配置 |
| `TCP_PROXY_1` ~ `TCP_PROXY_N` | 编号 TCP 配置（与 v1.0 兼容） |
| `HTTP_PROXY_1` ~ `HTTP_PROXY_N` | 编号 HTTP 配置 |

多个代理用分号 `;` 或换行分隔。以上变量可同时使用，规则会合并；同一本地端口不能重复。

## 构建镜像

```bash
docker build -t tcp-proxy:1.1 .
```

## 运行示例

### docker run

```bash
docker run -d --name tcp-proxy \
  -p 3306:3306 \
  -p 8080:8080 \
  -e PROXIES="3306,mysql.example.com:3306;8080,http://backend.internal:80" \
  tcp-proxy:1.1
```

### docker compose

```bash
docker compose up -d --build
```

按需修改 `docker-compose.yml` 中的 `ports` 和 `environment`。

## 与 v1.0 的差异

| 能力 | v1.0 | v1.1 |
|------|------|------|
| TCP 代理 | ✓ | ✓ |
| HTTP 反向代理 | — | ✓ |
| WebSocket 代理 | — | ✓ |
| `TCP_PROXIES` / `TCP_PROXY_N` | ✓ | ✓（兼容） |
| `PROXIES` / `HTTP_PROXIES` | — | ✓ |

## 注意事项

1. 容器内代理监听 `0.0.0.0:本地端口`，需在 `ports` 中映射到宿主机。
2. TCP 目标地址支持域名和 IP，域名在建立连接时解析。
3. HTTP 代理会将请求的 `Host` 头设为目标 URL 的 host，适用于大多数后端服务。
4. WebSocket 为长连接，HTTP 服务未设置 `ReadTimeout`，避免中途断开。
5. 同一本地端口不能重复配置。
