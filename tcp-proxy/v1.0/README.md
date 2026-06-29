# TCP Proxy

轻量级 TCP 代理容器，通过环境变量快速配置 1～N 条转发规则。

## 配置格式

每条规则格式：

```text
本地端口,目标地址:目标端口
```

示例：

```text
3306,mysql.example.com:3306
6379,192.168.1.10:6379
8080,10.0.0.5:80
```

## 环境变量

### `TCP_PROXIES`

多个代理用分号 `;` 或换行分隔：

```bash
TCP_PROXIES="3306,mysql.example.com:3306;6379,192.168.1.10:6379"
```

### `TCP_PROXY_1` ~ `TCP_PROXY_N`

适合 `docker run -e` 逐条指定：

```bash
-e TCP_PROXY_1="3306,mysql.example.com:3306" \
-e TCP_PROXY_2="6379,192.168.1.10:6379"
```

两种方式可同时使用，会合并全部规则。

## 构建镜像

```bash
docker build -t tcp-proxy:latest .
```

## 运行示例

### docker run

```bash
docker run -d --name tcp-proxy \
  -p 3306:3306 \
  -p 6379:6379 \
  -e TCP_PROXIES="3306,mysql.example.com:3306;6379,192.168.1.10:6379" \
  tcp-proxy:latest
```

### docker compose

```bash
docker compose up -d --build
```

按需修改 `docker-compose.yml` 中的 `ports` 和 `environment`。

## 注意事项

1. 容器内代理监听 `0.0.0.0:本地端口`，需在 `ports` 中映射到宿主机。
2. 目标地址支持域名和 IP，域名在建立连接时解析。
3. 同一本地端口不能重复配置。
