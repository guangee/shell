# 用于 GitLab CI 的 Docker 镜像
FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=stable
ENV NODE_VERSION=18

# 安装基础工具
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    libssl-dev \
    pkg-config \
    mingw-w64 \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 安装 Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs

# 安装 Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . $HOME/.cargo/env \
    && rustup target add x86_64-pc-windows-gnu

# 配置环境变量
ENV PATH="/root/.cargo/bin:${PATH}"

# 配置 Cargo 使用 MinGW
RUN mkdir -p /root/.cargo && \
    echo '[target.x86_64-pc-windows-gnu]' > /root/.cargo/config.toml && \
    echo 'linker = "x86_64-w64-mingw32-gcc"' >> /root/.cargo/config.toml && \
    echo 'ar = "x86_64-w64-mingw32-ar"' >> /root/.cargo/config.toml

# 设置工作目录
WORKDIR /build

# 验证安装
RUN node --version && \
    npm --version && \
    rustc --version && \
    cargo --version && \
    x86_64-w64-mingw32-gcc --version

CMD ["/bin/bash"]
