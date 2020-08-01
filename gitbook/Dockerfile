FROM centos:7
RUN curl --silent --location https://rpm.nodesource.com/setup_14.x | bash -
RUN yum install -y nodejs
RUN npm --version
RUN npm install -g gitbook-cli
RUN gitbook install