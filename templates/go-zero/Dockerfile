# Go-Zero 服务 Dockerfile
# 多阶段构建：编译 + 运行

# ============ 编译阶段 ============
FROM golang:1.23-alpine AS builder

# 设置 Go 环境
ENV GO111MODULE=on \
    GOPROXY=https://goproxy.cn,direct \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /build

# 先复制依赖文件，利用缓存
COPY go.mod go.sum ./
RUN go mod download

# 复制源码
COPY . .

# 编译（根据实际服务路径修改）
# API 服务
RUN go build -ldflags="-s -w" -o /app/server ./cmd/api/main.go

# 或 RPC 服务
# RUN go build -ldflags="-s -w" -o /app/server ./cmd/rpc/main.go

# ============ 运行阶段 ============
FROM alpine:3.20

# 安装证书（HTTPS 请求需要）
RUN apk --no-cache add ca-certificates tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

WORKDIR /app

# 从编译阶段复制二进制文件
COPY --from=builder /app/server .

# 复制配置文件
COPY etc/ ./etc/

# 暴露端口（根据实际修改）
EXPOSE 8080

# 启动服务
CMD ["./server", "-f", "etc/config.yaml"]
