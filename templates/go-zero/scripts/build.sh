#!/bin/bash
# 构建脚本

set -e

APP_NAME=${APP_NAME:-"go-zero-api"}
VERSION=${VERSION:-$(git describe --tags --always --dirty 2>/dev/null || echo "dev")}
REGISTRY=${REGISTRY:-"localhost:5000"}

echo "Building $APP_NAME:$VERSION..."

# 构建镜像
docker build -t $REGISTRY/$APP_NAME:$VERSION .
docker tag $REGISTRY/$APP_NAME:$VERSION $REGISTRY/$APP_NAME:latest

echo "Build complete: $REGISTRY/$APP_NAME:$VERSION"

# 推送（可选）
if [ "$1" == "--push" ]; then
    echo "Pushing to registry..."
    docker push $REGISTRY/$APP_NAME:$VERSION
    docker push $REGISTRY/$APP_NAME:latest
    echo "Push complete"
fi
