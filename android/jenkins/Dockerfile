FROM jenkins

USER root

RUN apt update && apt upgrade -y && apt install wget unzip && mkdir /opt/android && cd /opt/android  && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip sdk-tools-linux-4333796.zip

ENV ANDROID_HOME=/opt/android

RUN yes | /opt/android/tools/bin/sdkmanager "platform-tools"
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;28.0.2"
RUN yes | /opt/android/tools/bin/sdkmanager "platforms;android-28"

USER jenkins