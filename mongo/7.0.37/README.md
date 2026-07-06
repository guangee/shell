# MongoDB 7.0

基于官方 [mongo](https://hub.docker.com/_/mongo) 镜像的 MongoDB 7.0 定制版，预置 `mongod.conf` 与应用用户初始化脚本。

- 默认开启 **authorization**（需认证连接）
- 首次初始化数据目录时，可通过环境变量自动创建 root 用户和/或应用用户
- WiredTiger 缓存默认 **1 GB**（适合中小实例）

## 构建与发布

推送到 `master` 分支且 `mongo/7.0.34/Dockerfile` 有变更时，GitHub Actions 会自动构建并推送到 Docker Hub，镜像标签为：

```
guangee/mongo:7.0.34
```

本地手动构建：

```bash
# 在项目根目录
./build.sh mongo:7.0.34 mongo/7.0.34
```

## 快速启动

**至少**设置 root 凭证或应用用户凭证之一，否则开启认证后无法连接：

```bash
docker run --name mongo -d --restart always \
  --publish 27017:27017 \
  --env MONGO_INITDB_ROOT_USERNAME=root \
  --env MONGO_INITDB_ROOT_PASSWORD=rootpass \
  --env MONGO_INITDB_DATABASE=mydb \
  --env MONGO_APP_USER=app \
  --env MONGO_APP_PASSWORD=apppass \
  --volume mongo:/data/db \
  --volume mongo-log:/var/log/mongodb \
  guangee/mongo:7.0.34
```

进入 mongosh（使用 root 账号）：

```bash
docker exec -it mongo mongosh -u root -p rootpass --authenticationDatabase admin
```

连接串示例：

```
mongodb://app:apppass@<主机IP>:27017/mydb?authSource=mydb
```

## Docker Compose

将以下内容保存为 `docker-compose.yml` 后执行 `docker compose up -d`：

```yaml
services:
  mongo:
    restart: always
    image: zziaguan/mongo:7.0.37
    ports:
      - "27017:27017"
    environment:
      # ── root 用户（官方变量，首次初始化时创建 admin 库 root 角色）──
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: rootpass

      # ── 初始化脚本使用的目标库（官方变量）──
      MONGO_INITDB_DATABASE: mydb

      # ── 应用用户（单用户模式，见 mongo-init.js）──
      MONGO_APP_DATABASE: mydb       # 所属库，默认等于 MONGO_INITDB_DATABASE
      MONGO_APP_USER: app            # 未设则跳过建应用用户
      MONGO_APP_PASSWORD: apppass    # 设了 MONGO_APP_USER 时必填
      MONGO_APP_ROLES: readWrite     # 默认 readWrite；或 JSON 数组指定多角色/多库

      # ── 多用户模式（设此项后忽略上方单用户变量）──
      # MONGO_INIT_USERS: >-
      #   [{"user":"u1","pwd":"p1","roles":[{"role":"readWrite","db":"db1"}]}]

      # ── 跳过内置初始化脚本 ──
      # MONGO_INIT_SKIP: "1"
    volumes:
      - mongo:/data/db
      - mongo-log:/var/log/mongodb   # mongod.conf 日志路径，需可写

volumes:
  mongo:
  mongo-log:
```

按需精简 `environment`，例如仅 root + 应用用户：

```yaml
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: secret
      MONGO_INITDB_DATABASE: myapp
      MONGO_APP_USER: myapp
      MONGO_APP_PASSWORD: myapp_secret
```

## 数据持久化

挂载卷到 `/data/db` 即可保留数据；日志目录建议一并挂载：

```bash
docker run --name mongo -d \
  --volume /srv/docker/mongo/data:/data/db \
  --volume /srv/docker/mongo/log:/var/log/mongodb \
  guangee/mongo:7.0.34
```

> **注意**：环境变量与 `/docker-entrypoint-initdb.d` 脚本**仅在数据目录为空时执行一次**。已有数据卷不会重复建用户。

## 用户初始化说明

内置脚本 `mongo-init.js`（挂载为 `10-app-user.js`）在官方 entrypoint 完成 root 用户创建后执行。

### 单用户模式（常用）

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `MONGO_INITDB_DATABASE` | 官方变量，init 脚本默认上下文库 | `test` |
| `MONGO_APP_DATABASE` | 应用用户所属库 | 等于 `MONGO_INITDB_DATABASE` |
| `MONGO_APP_USER` | 应用用户名 | 未设则跳过 |
| `MONGO_APP_PASSWORD` | 应用用户密码 | 设了用户名时必填 |
| `MONGO_APP_ROLES` | 角色：`readWrite` 或 `readWrite,read` 或 JSON 数组 | `readWrite` |

### 多用户模式

设置 `MONGO_INIT_USERS` 为 JSON 数组（设置后忽略单用户变量）：

```yaml
MONGO_INIT_USERS: >-
  [
    {"user":"reader","pwd":"rpass","roles":[{"role":"read","db":"mydb"}]},
    {"user":"writer","pwd":"wpass","roles":[{"role":"readWrite","db":"mydb"}]}
  ]
```

### 跳过初始化

```yaml
MONGO_INIT_SKIP: "1"   # 或 true / yes / on
```

### 手动建用户（等价示例）

```bash
docker exec -it mongo mongosh -u root -p rootpass --authenticationDatabase admin
```

```javascript
use mydb
db.createUser({
  user: "app",
  pwd: "apppass",
  roles: [{ role: "readWrite", db: "mydb" }]
})
```

## 常用环境变量

| 变量 | 说明 |
|------|------|
| `MONGO_INITDB_ROOT_USERNAME` | root 用户名（与 `MONGO_INITDB_ROOT_PASSWORD` 成对设置） |
| `MONGO_INITDB_ROOT_PASSWORD` | root 密码 |
| `MONGO_INITDB_DATABASE` | init 脚本默认库 |
| `MONGO_APP_USER` / `MONGO_APP_PASSWORD` | 自动创建应用用户 |
| `MONGO_APP_DATABASE` | 应用用户所属库 |
| `MONGO_APP_ROLES` | 应用用户角色 |
| `MONGO_INIT_USERS` | 多用户 JSON 数组 |
| `MONGO_INIT_SKIP` | 跳过内置 init 脚本 |

## 配置说明（mongod.conf）

| 项 | 值 | 说明 |
|----|-----|------|
| `storage.dbPath` | `/data/db` | 数据目录 |
| `storage.wiredTiger.engineConfig.cacheSizeGB` | `1` | WiredTiger 缓存 |
| `net.port` | `27017` | 监听端口 |
| `net.bindIp` | `0.0.0.0` | 允许外部连接 |
| `security.authorization` | `enabled` | 强制认证 |
| `systemLog.path` | `/var/log/mongodb/mongod.log` | 文件日志 |

## 目录说明

```
mongo/7.0.34/
├── Dockerfile        # 基于官方 mongo 镜像，注入 conf 与 init 脚本
├── mongod.conf       # mongod 配置
├── mongo-init.js     # 应用用户初始化（/docker-entrypoint-initdb.d）
└── README.md
```

## 参考

- 官方镜像：[mongo](https://hub.docker.com/_/mongo)
- MongoDB 7.0 文档：https://www.mongodb.com/docs/v7.0/
- 用户与角色：https://www.mongodb.com/docs/manual/reference/built-in-roles/
