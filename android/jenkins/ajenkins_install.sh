#!/usr/bin/env bash

ANDROID_HOME=/opt/android

apt update
apt upgrade -y
apt install wget unzip -y
mkdir /opt/android && cd /opt/android
wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
unzip sdk-tools-linux-4333796.zip



yes |  /opt/android/tools/bin/sdkmanager "platform-tools"
yes |  /opt/android/tools/bin/sdkmanager "build-tools;28.0.2"
yes |  /opt/android/tools/bin/sdkmanager "build-tools;28.0.3"
yes |  /opt/android/tools/bin/sdkmanager "platforms;android-28"

yes | /opt/android/tools/bin/sdkmanager --licenses


wget http://mirror.bit.edu.cn/apache/tomcat/tomcat-8/v8.5.37/bin/apache-tomcat-8.5.37.tar.gz
tar -xzvf apache-tomcat-8.5.37.tar.gz tomcat
rm -rf tomcat/webapps/*
wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war tomcat/webapps/jenkins.war
