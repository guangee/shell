# 安装依赖的程序
yum install -y curl-devel \
     expat-devel gettext-devel \
     openssl-devel zlib-devel \
     gcc perl-ExtUtils-MakeMaker \
     wget autoconf
# 下载最新的git程序
wget https://github.com/git/git/archive/refs/tags/v2.36.1.tar.gz
# 解压
tar -xzvf v2.36.1.tar.gz
# 编译
cd git-2.36.1
make configure
./configure --prefix=/usr/local/git

# 配置git的环境变量
export GIT_HOME=/usr/local/git
export PATH=$PATH:$GIT_HOME/bin