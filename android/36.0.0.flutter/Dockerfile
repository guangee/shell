# Android SDK 镜像：用于在容器内构建 Flutter APK（用户端 / 司机端）。
# 与工程 android/app/build.gradle.kts 中 ndkVersion = "27.0.12077973" 对齐。
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV ANDROID_HOME=/opt/android
ENV ANDROID_SDK_ROOT=/opt/android

COPY sources.list /etc/apt/sources.list
COPY .bashrc /root/.bashrc

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        openjdk-17-jdk-headless \
        wget unzip curl jq tzdata ca-certificates \
        git \
        language-pack-zh-hans \
        figlet \
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
ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/27.0.12077973

RUN yes | sdkmanager --sdk_root="${ANDROID_HOME}" --licenses \
    && yes | sdkmanager --sdk_root="${ANDROID_HOME}" \
        "platform-tools" \
        "platforms;android-36" \
        "platforms;android-35" \
        "build-tools;36.0.0" \
        "build-tools;35.0.0" \
        "ndk;27.0.12077973" \
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
