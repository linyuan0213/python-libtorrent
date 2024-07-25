FROM ubuntu:22.04

# 设置环境变量以非交互方式配置 tzdata
ENV DEBIAN_FRONTEND=noninteractive

# 安装编译 libtorrent 和 Python 包所需的依赖
RUN apt-get update && apt-get install -y \
    g++ \
    make \
    cmake \
    libboost-system-dev \
    libboost-tools-dev \
    libboost-dev \
    libboost-python-dev \
    libssl-dev \
    zlib1g-dev \
    pkg-config \
    git \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel

# 获取 libtorrent 源码
RUN git clone --recurse-submodules --branch RC_2_0 --depth 1 https://github.com/arvidn/libtorrent.git /libtorrent

WORKDIR /libtorrent

# 编译 libtorrent
RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$(nproc) && \
    make install

# 编译 libtorrent 的 Python 绑定
WORKDIR /libtorrent/bindings/python

RUN python3 setup.py bdist_wheel

# 设置输出目录并赋予权限
RUN mkdir -p /output && chmod -R 777 /output && cp dist/*.whl /output/