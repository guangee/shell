# Android + Flutter CI 镜像（36.1.1.flutter）
# 基于 36.1.0.flutter：补齐培友圈 / 金属价格等工程 CI 常用工具，避免作业内现场 apt。
#
# 相对 36.1.0.flutter 新增：
#   - python3 / pip / venv：插件 KGP 补丁、Fabu upload JSON 解析
#   - procps：build.sh 里 pkill Gradle daemon
#   - zip / file / openssl / openssh-client：打包校验与私有 git
#
# 构建与推送（在 shell 仓库根目录）：
#   docker_hub_username=zziaguan ./build.sh android:36.1.1.flutter android/36.1.1.flutter
# 私有仓库示例：
#   docker tag zziaguan/android:36.1.1.flutter hub.tulan.wang/zziaguan/android:36.1.1.flutter
#   docker push hub.tulan.wang/zziaguan/android:36.1.1.flutter
#
# 与工程 android/app/build.gradle.kts 中 ndkVersion 对齐（NDK 28.2.x）。
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_ROOT=/opt/android

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        openjdk-17-jdk-headless \
        wget unzip zip curl jq tzdata ca-certificates \
        git openssh-client \
        python3 python3-pip python3-venv \
        procps file openssl xz-utils \
        language-pack-zh-hans \
        figlet \
    && ln -sf /usr/bin/python3 /usr/local/bin/python \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && arch="$(dpkg --print-architecture)" \
    && ln -sfn "/usr/lib/jvm/java-17-openjdk-${arch}" /usr/lib/jvm/java-17-openjdk-current \
    && printf '\nexport JAVA_HOME=/usr/lib/jvm/java-17-openjdk-current\n' >> /root/.bashrc \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-current

RUN mkdir -p "${ANDROID_HOME}/cmdline-tools"

# 新版 command-line tools（内置 sdkmanager），旧版 sdk-tools 已无法可靠安装 NDK r27。
# 版本号见：https://developer.android.com/studio#command-line-tools-only
ARG ANDROID_CMDLINE_TOOLS_ZIP=commandlinetools-linux-11076708_latest.zip
RUN wget -q "https://dl.google.com/android/repository/${ANDROID_CMDLINE_TOOLS_ZIP}" \
    && unzip -q "${ANDROID_CMDLINE_TOOLS_ZIP}" -d /tmp/android-cmdline \
    && rm "${ANDROID_CMDLINE_TOOLS_ZIP}" \
    && mv /tmp/android-cmdline/cmdline-tools "${ANDROID_HOME}/cmdline-tools/latest" \
    && rm -rf /tmp/android-cmdline

ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"

# side-by-side NDK 安装路径：$ANDROID_HOME/ndk/<version>
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/28.2.13676358

RUN yes | sdkmanager --sdk_root="${ANDROID_HOME}" --licenses \
    && yes | sdkmanager --sdk_root="${ANDROID_HOME}" \
        "platform-tools" \
        "platforms;android-36" \
        "build-tools;36.1.0" \
        "ndk;28.2.13676358" \
        "cmake;3.22.1"

# 在容器内执行 `flutter build apk` 需要 Flutter SDK；若只在宿主机跑 flutter、仅挂载本镜像的
# ANDROID_HOME，则可删掉以下段落并自行挂载 Flutter。
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

ARG FLUTTER_BRANCH=stable
RUN git clone --depth 1 --branch "${FLUTTER_BRANCH}" https://github.com/flutter/flutter.git "${FLUTTER_HOME}" \
    && flutter config --no-analytics \
    && flutter precache --android

WORKDIR /workspace

COPY sources.list /etc/apt/sources.list
COPY .bashrc /root/.bashrc