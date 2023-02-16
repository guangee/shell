FROM ubuntu:20.04
USER root

ENV ANDROID_HOME                    /opt/android
ENV LANG                            C.UTF-8

RUN apt update
RUN apt upgrade -y
RUN apt install openjdk-8-jdk-headless wget unzip curl -y
RUN mkdir /opt/android
RUN cd /opt/android && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip sdk-tools-linux-4333796.zip

ENV ANDROID_HOME=/opt/android

RUN yes | /opt/android/tools/bin/sdkmanager "platform-tools"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;30.0.3"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;31.0.0"
RUN yes | /opt/android/tools/bin/sdkmanager "platforms;android-31"
RUN yes | /opt/android/tools/bin/sdkmanager --licenses

RUN DEBIAN_FRONTEND=noninteractive && apt update  &&  apt install -y tzdata openjdk-11-jdk-headless language-pack-zh*
RUN apt autoremove -y openjdk-8-jdk-headless
RUN echo "Asia/Shanghai" > /etc/timezone
ADD sources.list /etc/apt/sources.list
