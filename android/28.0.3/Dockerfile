FROM ubuntu:20.04
RUN echo "Asia/Shanghai" > /etc/timezone
USER root

RUN apt update
RUN apt upgrade -y
RUN apt install openjdk-8-jdk-headless wget unzip curl -y
RUN mkdir /opt/android
RUN cd /opt/android && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip sdk-tools-linux-4333796.zip

ENV ANDROID_HOME=/opt/android

RUN yes | /opt/android/tools/bin/sdkmanager "platform-tools"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;28.0.3"
RUN yes | /opt/android/tools/bin/sdkmanager "platforms;android-28"
RUN yes | /opt/android/tools/bin/sdkmanager --licenses
ADD sources.list /etc/apt/sources.list
