FROM ubuntu:18.04
RUN echo "Asia/Shanghai" > /etc/timezone

USER root
RUN apt update
RUN apt upgrade -y
RUN apt install wget unzip -y
RUN apt install openjdk-8-jdk-headless -y
RUN mkdir /opt/android
RUN cd /opt/android && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip sdk-tools-linux-4333796.zip



ENV ANDROID_HOME=/opt/android

RUN yes | /opt/android/tools/bin/sdkmanager "platform-tools"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;28.0.2"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;28.0.3"
RUN yes | /opt/android/tools/bin/sdkmanager "platforms;android-28"
RUN yes | /opt/android/tools/bin/sdkmanager --licenses

RUN apt install git -y
RUN apt install zsh -y

RUN git clone https://git.coding-space.cn/jiaochenyu/phone_list_android.git app
RUN cd /app && git checkout dev_gwm
WORKDIR /app
CMD ["bash","/app/build.sh"]