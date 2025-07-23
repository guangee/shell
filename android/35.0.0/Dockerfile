FROM ubuntu:22.04
USER root

ENV ANDROID_HOME                    /opt/android
ENV LANG                            C.UTF-8

RUN DEBIAN_FRONTEND=noninteractive
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改欢迎命令
COPY .bashrc /root/.bashrc

RUN mkdir /opt/android
RUN apt update && apt upgrade -y \
    && apt install -y openjdk-8-jdk-headless wget unzip curl jq tzdata language-pack-zh* \
    && cd /opt/android && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip sdk-tools-linux-4333796.zip && rm sdk-tools-linux-4333796.zip \
    && yes | /opt/android/tools/bin/sdkmanager "platform-tools" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;30.0.0" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;30.0.1" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;30.0.2" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;30.0.3" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;31.0.0" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;32.0.0" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;33.0.0" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;33.0.1" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;33.0.2" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;33.0.3" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;34.0.0" \
    && yes | /opt/android/tools/bin/sdkmanager "build-tools;35.0.0" \
    && yes | /opt/android/tools/bin/sdkmanager "platforms;android-31" \
    && yes | /opt/android/tools/bin/sdkmanager "platforms;android-30" \
    && yes | /opt/android/tools/bin/sdkmanager "platforms;android-32" \
    && yes | /opt/android/tools/bin/sdkmanager "platforms;android-33" \
    && yes | /opt/android/tools/bin/sdkmanager "platforms;android-34" \
    && yes | /opt/android/tools/bin/sdkmanager "platforms;android-35" \
    && yes | /opt/android/tools/bin/sdkmanager --licenses \
    && apt autoremove -y openjdk-8-jdk-headless \
    && apt install -y openjdk-11-jdk-headless
ADD sources.list /etc/apt/sources.list
