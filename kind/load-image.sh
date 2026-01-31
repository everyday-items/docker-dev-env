#!/bin/bash
# 将本地 Docker 镜像加载到 Kind 集群
# 用法: ./load-image.sh <image-name>

if [ -z "$1" ]; then
    echo "用法: ./load-image.sh <image-name>"
    echo "示例: ./load-image.sh my-app:latest"
    exit 1
fi

IMAGE=$1
echo "正在将镜像 $IMAGE 加载到 Kind 集群..."
kind load docker-image $IMAGE --name dev-cluster
echo "完成"
