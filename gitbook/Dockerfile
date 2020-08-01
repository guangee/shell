FROM centos:7
RUN yum install -y wget && wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
RUN curl --silent --location https://rpm.nodesource.com/setup_14.x | bash -
RUN yum install -y nodejs
RUN npm --version
RUN npm install -g gitbook-cli
RUN gitbook install