FROM ubuntu:22.04
USER root

ENV LANG                            C.UTF-8
ENV JAVA_HOME                       /usr/lib/jvm/java-17-openjdk-amd64
ENV MAVEN_HOME                      /opt/maven
ENV PATH                            $PATH:$JAVA_HOME/bin:$MAVEN_HOME/bin
ENV OPENCODE_CONFIG                 /home/workspace/opencode.json

RUN DEBIAN_FRONTEND=noninteractive
RUN echo "Asia/Shanghai" > /etc/timezone
# 修改欢迎命令
COPY .bashrc /root/.bashrc

RUN apt update && apt upgrade -y \
    && apt install -y wget unzip curl jq tzdata gettext net-tools tree \
    && wget https://dl.min.io/client/mc/release/linux-amd64/mc \
    && chmod +x mc \
    && mv mc /usr/bin/ \
    &&wget https://github.com/mikefarah/yq/releases/download/v4.16.2/yq_linux_amd64 \
    && chmod +x yq_linux_amd64 \
    && mv yq_linux_amd64 /usr/bin/yq \
    && apt install -y ca-certificates gnupg openjdk-17-jdk \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt update && apt install -y nodejs \
    && wget https://dlcdn.apache.org/maven/maven-3/3.9.14/binaries/apache-maven-3.9.14-bin.tar.gz -O /tmp/apache-maven-3.9.14-bin.tar.gz \
    && tar -xzf /tmp/apache-maven-3.9.14-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-3.9.14 /opt/maven \
    && ln -s /opt/maven/bin/mvn /usr/bin/mvn \
    && rm /tmp/apache-maven-3.9.14-bin.tar.gz \
    && npm install -g yarn \
    && yarn global add opencode-ai


RUN mkdir -p /home/workspace
WORKDIR /home/workspace
ADD opencode.json /home/workspace/opencode.json

ADD sources.list /etc/apt/sources.list

CMD opencode serve