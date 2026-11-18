# android:36.1.1.flutter

私有镜像标签：`hub.tulan.wang/zziaguan/android:36.1.1.flutter`

## 为何升这一版

`36.1.0.flutter` 能编 Flutter APK，但 CI 脚本还缺：

| 工具 | 用途 |
|------|------|
| `python3` | `tool/patch_plugin_kgp.py`、Fabu `upload.sh` JSON |
| `procps`（`pkill`） | `build.sh` 清 Gradle daemon |
| `zip` / `file` / `openssl` | 产物处理与校验 |
| `openssh-client` | 私有仓 SSH |

每次 job 里 `apt-get install` 慢且依赖镜像源；预装更稳。

## 构建推送

在 `shell` 仓库根目录：

```bash
export docker_hub_username=zziaguan
./build.sh android:36.1.1.flutter android/36.1.1.flutter

# 推到内网 Harbor（按你们实际登录方式）
docker tag zziaguan/android:36.1.1.flutter hub.tulan.wang/zziaguan/android:36.1.1.flutter
docker push hub.tulan.wang/zziaguan/android:36.1.1.flutter
```

## 工程切换

`customs-rag-app` / 培友圈等 `.gitlab-ci.yml`：

```yaml
image: hub.tulan.wang/zziaguan/android:36.1.1.flutter
```

推送镜像成功后再改 CI，避免 Runner 拉不到新 tag。
