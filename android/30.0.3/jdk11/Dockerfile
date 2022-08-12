FROM registry.cn-beijing.aliyuncs.com/guanweiming/android:30.0.3

RUN DEBIAN_FRONTEND=noninteractive apt install -y tzdata
RUN yes | /opt/android/tools/bin/sdkmanager "build-tools;29.0.2"
RUN yes | /opt/android/tools/bin/sdkmanager "platforms;android-31"

RUN apt update && apt install openjdk-11-jdk-headless -y
