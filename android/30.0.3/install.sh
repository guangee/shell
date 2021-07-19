#!/usr/bin/env bash


apt update
apt upgrade -y
apt install git -y
apt install zsh -y
apt install wget unzip -y
apt install openjdk-8-jdk-headless -y
mkdir /opt/android
cd /opt/android && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip sdk-tools-linux-4333796.zip

ANDROID_HOME=/opt/android

yes | /opt/android/tools/bin/sdkmanager "platform-tools"
yes | /opt/android/tools/bin/sdkmanager "build-tools;28.0.2"
yes | /opt/android/tools/bin/sdkmanager "build-tools;28.0.3"
yes | /opt/android/tools/bin/sdkmanager "platforms;android-28"
yes | /opt/android/tools/bin/sdkmanager --licenses