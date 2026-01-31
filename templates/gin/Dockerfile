# Gin 服务 Dockerfile
# 多阶段构建：编译 + 运行

# ============ 编译阶段 ============
FROM golang:1.23-alpine AS builder

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

# 编译
RUN go build -ldflags="-s -w" -o /app/server ./cmd/main.go

# ============ 运行阶段 ============
FROM alpine:3.20

RUN apk --no-cache add ca-certificates tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

WORKDIR /app

# 从编译阶段复制
COPY --from=builder /app/server .

# 复制配置和静态文件
COPY config/ ./config/
# COPY templates/ ./templates/
# COPY static/ ./static/

EXPOSE 8080

CMD ["./server"]
