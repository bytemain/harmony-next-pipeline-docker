# 使用 Ubuntu 20.04 作为基础镜像
FROM ubuntu:20.04

# 设置环境变量以避免交互式安装提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装必要的工具
# curl: 部分构建脚本（如 prepare_ohos_sqlite_provider.sh 下载 SQLite amalgamation）依赖它，缺失会 exit 127。
# zstd: GitHub Actions 的 actions/cache 条目指纹包含压缩工具；ubuntu runner 保存的是 zstd 压缩，
#       容器里没有 zstd 时同 key 也会永远 miss（gzip-only 客户端），且不报错。
RUN apt-get update && \
    apt-get install -y \
        wget \
        curl \
        zstd \
        zip \
        unzip \
        python3 \
        openjdk-17-jdk \
        build-essential \
        git \
        && rm -rf /var/lib/apt/lists/*

# 设置 JDK 17 环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# 下载并安装 HarmonyOS CLI 工具
RUN mkdir -p /opt/harmonyos-tools && \
    wget -q -O /tmp/commandline-tools-linux.zip https://image.cdn.dog/commandline-tools-linux-x64-6.1.1.280.zip && \
    echo "b9caf7b73c541b90e6c8f3c7c3de7f2bea9b35e41e80cd3525f2f759ebf16cf4  /tmp/commandline-tools-linux.zip" | sha256sum -c - || { echo "ERROR: SHA256 checksum verification failed for HarmonyOS CLI tools"; exit 1; } && \
    unzip -q /tmp/commandline-tools-linux.zip -d /opt/harmonyos-tools/ && \
    chmod -R +x /opt/harmonyos-tools/command-line-tools/bin && \
    chmod -R +x /opt/harmonyos-tools/command-line-tools/sdk/default/openharmony/native/llvm/bin && \
    rm /tmp/commandline-tools-linux.zip

# 设置 HarmonyOS CLI 工具的环境变量
ENV COMMANDLINE_TOOL_DIR=/opt/harmonyos-tools
ENV PATH=$COMMANDLINE_TOOL_DIR/command-line-tools/bin:$PATH
ENV HDC_HOME=$COMMANDLINE_TOOL_DIR/command-line-tools/sdk/default/openharmony/toolchains
ENV PATH=$HDC_HOME:$PATH
ENV OHOS_BASE_SDK_HOME=$COMMANDLINE_TOOL_DIR/command-line-tools/sdk/default/openharmony
ENV OHOS_LLVM_HOME=$OHOS_BASE_SDK_HOME/native/llvm
ENV PATH=$OHOS_LLVM_HOME/bin:$PATH

# 设置工作目录
WORKDIR /workspace

# 设置默认命令
CMD ["bash"]
