#!/bin/bash
# 将本地 Docker 镜像加载到 Minikube 集群
# 用法: ./load-image.sh <image-name>

if [ -z "$1" ]; then
    echo "用法: ./load-image.sh <image-name>"
    echo "示例: ./load-image.sh my-app:latest"
    exit 1
fi

IMAGE=$1
echo "正在将镜像 $IMAGE 加载到 Minikube 集群..."
minikube image load $IMAGE
echo "完成"

echo ""
echo "提示: 也可以使用 minikube 的 Docker 环境直接构建镜像:"
echo "  eval \$(minikube docker-env)"
echo "  docker build -t my-app:latest ."
