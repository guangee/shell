# PostgreSQL 17

基于 [sameersbn/docker-postgresql](https://github.com/sameersbn/docker-postgresql) 的 PostgreSQL 17 镜像，Ubuntu Noble + PGDG 源。

已预装 **PostGIS**、**pgvector**、**contrib** 扩展包；首次初始化时默认在 `template1`、`postgres` 及 `DB_NAME` 指定的库中启用 `postgis`、`vector`、`pg_trgm`。

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
    restart: always          # 容器退出时自动重启（always=总是重启）
    image: guangee/postgresql:17  # 使用的镜像名称与标签
    ports:
      - "5432:5432"          # 端口映射：宿主机 5432 → 容器 5432
    environment:
      DEBUG: "false"         # 是否开启 bash 调试输出（true 时 entrypoint 加 set -x）

      PG_PASSWORD: ""        # postgres 超级用户密码（仅首次初始化数据目录时生效）
      DB_USER: ""            # 启动时自动创建的数据库用户名
      DB_PASS: ""            # DB_USER 对应的密码（必填，否则创建用户会失败）
      DB_NAME: ""            # 启动时自动创建的数据库名，多个用逗号分隔
      DB_TEMPLATE: ""        # 建库使用的模板库，默认 template1；留空则使用内置默认值

      DB_EXTENSION: "postgis,vector,pg_trgm"  # 首次初始化时启用的扩展，逗号分隔；留空禁用

      REPLICATION_MODE: ""   # 复制模式：留空=主库；slave=从库；snapshot=快照；backup=备份后退出
      REPLICATION_USER: ""   # 复制用户名（主库上创建，从库/快照/备份时用于连接主库）
      REPLICATION_PASS: ""   # 复制用户密码
      REPLICATION_SSLMODE: "" # 连接主库时的 SSL 模式：disable/prefer/require 等；留空默认 prefer
    # postgres 启动参数：wal_keep_size=512 主库为复制保留 WAL（MB）；logging_collector=off 日志走 stderr
    command: "--wal_keep_size=512 --logging_collector=off"
    volumes:
      - postgresql:/var/lib/postgresql  # 数据持久化目录（库文件、WAL 等）

volumes:
  postgresql:                  # 命名卷，由 Docker 管理存储位置
```

按需填写 `environment`，例如：

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

## 扩展（插件）

### 默认已启用

首次初始化数据目录时，会自动在 `template1`、`postgres` 以及 `DB_NAME` 创建的库中执行 `CREATE EXTENSION`：

| 顺序 | 扩展名 | 说明 |
|------|--------|------|
| 1 | `postgis` | 地理空间数据、坐标、空间索引 |
| 2 | `vector` | 向量存储与相似度检索（pgvector） |
| 3 | `pg_trgm` | 模糊搜索、三元组索引，加速 `LIKE` / 相似度查询 |

之后通过 `CREATE DATABASE` 新建的库会继承 `template1` 中已启用的扩展。

可通过环境变量 `DB_EXTENSION` 覆盖默认值，例如：

```bash
# 仅启用 pg_trgm
--env 'DB_EXTENSION=pg_trgm'

# 在默认三项基础上追加 unaccent、pgcrypto
--env 'DB_EXTENSION=postgis,vector,pg_trgm,unaccent,pgcrypto'

# 禁用自动启用（留空）
--env 'DB_EXTENSION='
```

> **注意**：`DB_EXTENSION` 仅在**首次初始化数据目录**时生效。已有数据卷不会自动补装扩展。

### 推荐选用顺序（按需启用）

以下扩展均已安装到镜像中（contrib 或额外包装），按社区常用程度排列，**除默认三项外需自行启用**：

| 顺序 | 扩展名 | 用途 | 来源 |
|------|--------|------|------|
| 1 | `postgis` | GIS / LBS 空间查询 | 默认启用 |
| 2 | `vector` | AI embedding、语义检索 | 默认启用 |
| 3 | `pg_trgm` | 模糊文本搜索 | 默认启用 |
| 4 | `pg_stat_statements` | 慢 SQL 统计、性能分析 | contrib |
| 5 | `pgcrypto` | 加密、哈希、随机数 | contrib |
| 6 | `citext` | 不区分大小写文本 | contrib |
| 7 | `unaccent` | 去重音，配合全文搜索 | contrib |
| 8 | `uuid-ossp` | 生成 UUID（也可用内置 `gen_random_uuid()`） | contrib |
| 9 | `hstore` | key-value 字段 | contrib |
| 10 | `postgres_fdw` | 跨库 / 跨实例联邦查询 | contrib |
| 11 | `btree_gin` / `btree_gist` | 复合索引、排他约束等 | contrib |
| 12 | `pg_prewarm` | 预热数据到缓存 | contrib |
| 13 | `pg_buffercache` | 查看缓存中的页面 | contrib |
| 14 | `tablefunc` | 交叉表（crosstab）等 | contrib |
| 15 | `fuzzystrmatch` | 字符串相似度 | contrib |
| 16 | `intarray` | 整数数组运算 | contrib |
| 17 | `ltree` | 树形结构 | contrib |
| 18 | `pgrowlocks` | 查看行级锁 | contrib |

PostGIS 相关可选子扩展（需单独 `CREATE EXTENSION`）：

| 扩展名 | 用途 |
|--------|------|
| `postgis_raster` | 栅格数据 |
| `postgis_topology` | 拓扑 |
| `postgis_tiger_geocoder` | 美国地址 geocoder |

查看镜像内全部可用扩展：

```sql
SELECT name, default_version, comment
FROM pg_available_extensions
ORDER BY name;
```

查看当前库已启用扩展：

```sql
SELECT extname, extversion FROM pg_extension ORDER BY extname;
```

### 建库时未启用，后续如何补装

**方式一：在目标库手动启用（最常用）**

```bash
docker exec -it postgresql sudo -u postgres psql -d mydb
```

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

**方式二：一次性命令**

```bash
docker exec -it postgresql sudo -u postgres psql -d mydb -c \
  "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"
```

**方式三：新建库时继承 template1**

若 `template1` 已在初始化时装好扩展，后续执行 `CREATE DATABASE newdb;` 会自动继承。若 `template1` 本身缺少扩展，可先补到 template1：

```sql
\c template1
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

> 在 `template1` 上启用扩展会影响之后所有新建库，请谨慎操作。

**方式四：重建数据目录（仅空库 / 可丢数据时）**

删除数据卷后重新启动，并通过 `DB_EXTENSION` 指定需要的扩展列表。

## 常用环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `PG_PASSWORD` | `postgres` 用户密码（首次初始化生效） | 无 |
| `PG_TRUST_LOCALNET` | 信任同网络连接 | `false` |
| `DB_USER` / `DB_PASS` | 创建数据库用户 | 无 |
| `DB_NAME` | 创建数据库，多个用逗号分隔 | 无 |
| `DB_TEMPLATE` | 建库模板 | `template1` |
| `DB_EXTENSION` | 首次初始化时启用的扩展，逗号分隔 | `postgis,vector,pg_trgm` |
| `REPLICATION_USER` / `REPLICATION_PASS` | 创建复制用户 | 无 |
| `REPLICATION_MODE` | `slave` / `snapshot` / `backup` | 无（默认 master） |
| `REPLICATION_HOST` / `REPLICATION_PORT` | 主库地址与端口 | 端口 `5432` |
| `REPLICATION_SSLMODE` | 复制 SSL 模式 | `prefer` |
| `USERMAP_UID` / `USERMAP_GID` | 映射容器内 `postgres` 用户 UID/GID | 无 |
| `DEBUG` | 开启 bash 调试输出 | 无 |

## 示例

设置 `postgres` 密码并创建用户与数据库（默认扩展自动启用）：

```bash
docker run --name postgresql -d --restart always \
  --publish 5432:5432 \
  --env 'PG_PASSWORD=secret' \
  --env 'DB_USER=app' --env 'DB_PASS=apppass' \
  --env 'DB_NAME=mydb' \
  --volume postgresql:/var/lib/postgresql \
  guangee/postgresql:17
```

追加 contrib 扩展（首次初始化时生效）：

```bash
docker run --name postgresql -d \
  --env 'DB_NAME=db1' \
  --env 'DB_EXTENSION=postgis,vector,pg_trgm,pg_stat_statements,pgcrypto' \
  --volume postgresql:/var/lib/postgresql \
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
- PostGIS 文档：https://postgis.net/documentation/
- pgvector：https://github.com/pgvector/pgvector
