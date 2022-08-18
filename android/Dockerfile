FROM ubuntu:20.04
RUN echo "Asia/Shanghai" > /etc/timezone
USER root
ADD sources.list /etc/apt/sources.list

RUN DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME=/opt/android

RUN apt update \
    && apt upgrade -y \
    && apt install -y tzdata wget unzip curl openjdk-8-jdk-headless
RUN mkdir /opt/android
RUN cd /opt/android && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip sdk-tools-linux-4333796.zip


RUN yes | /opt/android/tools/bin/sdkmanager "platform-tools"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;29.0.2"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;29.0.3"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;30.0.0"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;30.0.1"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;30.0.2"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;30.0.3"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;31.0.0"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;32.0.0"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;33.0.0"

RUN yes | /opt/android/tools/bin/sdkmanager "platforms;android-29"
RUN yes | /opt/android/tools/bin/sdkmanager "platforms;android-30"
RUN yes | /opt/android/tools/bin/sdkmanager "platforms;android-31"
RUN yes | /opt/android/tools/bin/sdkmanager "platforms;android-32"
RUN yes | /opt/android/tools/bin/sdkmanager "platforms;android-33"


RUN yes | /opt/android/tools/bin/sdkmanager --licenses

RUN apt autoremove openjdk-8-jdk-headless && apt install  -y openjdk-11-jdk-headless
COPY .bashrc /root/.bashrc
