# Go 开发环境镜像
FROM golang:1.25-alpine

# 安装常用工具
RUN apk add --no-cache \
    git \
    curl \
    wget \
    make \
    gcc \
    musl-dev \
    bash \
    vim \
    tzdata \
    protobuf \
    protobuf-dev

# 设置时区
ENV TZ=Asia/Shanghai

# 设置 Go 环境变量
ENV GO111MODULE=on \
    GOPROXY=https://goproxy.cn,direct \
    GOPATH=/go \
    GOBIN=/go/bin

# 安装常用 Go 工具
RUN go install github.com/air-verse/air@latest && \
    go install github.com/swaggo/swag/cmd/swag@latest && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest && \
    go install golang.org/x/tools/gopls@latest && \
    go install github.com/go-delve/delve/cmd/dlv@latest

# 安装 go-zero 工具
RUN go install github.com/zeromicro/go-zero/tools/goctl@latest

# 清理下载缓存（保留构建缓存以加速首次编译）
RUN go clean -modcache

# 工作目录
WORKDIR /app

# 默认命令
CMD ["bash"]
