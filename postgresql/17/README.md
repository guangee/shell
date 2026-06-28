# PostgreSQL 17

基于 [sameersbn/docker-postgresql](https://github.com/sameersbn/docker-postgresql) 的 PostgreSQL 17 镜像，Ubuntu Noble + PGDG 源。

## 构建与发布

推送到 `master` 分支且 `postgresql/17/Dockerfile` 有变更时，GitHub Actions 会自动构建并推送到 Docker Hub，镜像标签为：

```
guangee/postgresql:17
```

本地手动构建：

```bash
# 在项目根目录
./build.sh postgresql:17 postgresql/17
```

## 快速启动

```bash
docker run --name postgresql -d --restart always \
  --publish 5432:5432 \
  --volume postgresql:/var/lib/postgresql \
  guangee/postgresql:17
```

进入 psql：

```bash
docker exec -it postgresql sudo -u postgres psql
```

## Docker Compose

将以下内容保存为 `docker-compose.yml` 后执行 `docker compose up -d`：

```yaml
services:
  postgresql:
    restart: always
    image: zziaguan/postgresql:17
    ports:
      - "5432:5432"
    environment:
      DEBUG: "false"

      DB_USER: ""
      DB_PASS: ""
      DB_NAME: ""
      DB_TEMPLATE: ""

      DB_EXTENSION: ""

      REPLICATION_MODE: ""
      REPLICATION_USER: ""
      REPLICATION_PASS: ""
      REPLICATION_SSLMODE: ""
    command: "--wal_keep_size=512 --logging_collector=off"
    volumes:
      - postgresql:/var/lib/postgresql

volumes:
  postgresql:
```

按需填写 `environment` 中的变量，例如：

```yaml
    environment:
      PG_PASSWORD: secret
      DB_USER: app
      DB_PASS: apppass
      DB_NAME: mydb
```

## 数据持久化

挂载卷到 `/var/lib/postgresql` 即可保留数据：

```bash
docker run --name postgresql -d \
  --volume /srv/docker/postgresql:/var/lib/postgresql \
  guangee/postgresql:17
```

## 常用环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `PG_PASSWORD` | `postgres` 用户密码（首次初始化生效） | 无 |
| `PG_TRUST_LOCALNET` | 信任同网络连接 | `false` |
| `DB_USER` / `DB_PASS` | 创建数据库用户 | 无 |
| `DB_NAME` | 创建数据库，多个用逗号分隔 | 无 |
| `DB_TEMPLATE` | 建库模板 | `template1` |
| `DB_EXTENSION` | 启用扩展，多个用逗号分隔 | 无 |
| `REPLICATION_USER` / `REPLICATION_PASS` | 创建复制用户 | 无 |
| `REPLICATION_MODE` | `slave` / `snapshot` / `backup` | 无（默认 master） |
| `REPLICATION_HOST` / `REPLICATION_PORT` | 主库地址与端口 | 端口 `5432` |
| `REPLICATION_SSLMODE` | 复制 SSL 模式 | `prefer` |
| `USERMAP_UID` / `USERMAP_GID` | 映射容器内 `postgres` 用户 UID/GID | 无 |
| `DEBUG` | 开启 bash 调试输出 | 无 |

## 示例

设置 `postgres` 密码并创建用户与数据库：

```bash
docker run --name postgresql -d --restart always \
  --publish 5432:5432 \
  --env 'PG_PASSWORD=secret' \
  --env 'DB_USER=app' --env 'DB_PASS=apppass' \
  --env 'DB_NAME=mydb' \
  --volume postgresql:/var/lib/postgresql \
  guangee/postgresql:17
```

启用扩展：

```bash
docker run --name postgresql -d \
  --env 'DB_NAME=db1' --env 'DB_EXTENSION=unaccent,pg_trgm' \
  guangee/postgresql:17
```

## 目录说明

```
postgresql/17/
├── Dockerfile           # 镜像定义
├── entrypoint.sh        # 容器入口
├── runtime/
│   ├── env-defaults     # 环境变量默认值
│   └── functions        # 初始化、复制、建库等逻辑
└── README.md
```

## 参考

- 上游项目：[sameersbn/docker-postgresql](https://github.com/sameersbn/docker-postgresql)
- PostgreSQL 官方文档：https://www.postgresql.org/docs/17/
