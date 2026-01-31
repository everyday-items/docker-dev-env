#!/bin/bash
# 配置 Kind 使用本地镜像仓库
# 参考: https://kind.sigs.k8s.io/docs/user/local-registry/

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REGISTRY_NAME="registry"
REGISTRY_PORT="${REGISTRY_PORT:-5000}"

echo -e "${GREEN}=== 配置 Kind 使用本地镜像仓库 ===${NC}"

# 检查 registry 是否运行
if ! docker ps | grep -q "$REGISTRY_NAME"; then
    echo -e "${YELLOW}启动本地镜像仓库...${NC}"
    docker-compose up -d registry
    sleep 3
fi

# 连接 registry 到 kind 网络
if docker network ls | grep -q "kind"; then
    if ! docker network inspect kind | grep -q "$REGISTRY_NAME"; then
        echo -e "${YELLOW}连接 registry 到 kind 网络...${NC}"
        docker network connect kind $REGISTRY_NAME || true
    fi
fi

# 创建 ConfigMap 告诉 Kind 节点使用本地仓库
echo -e "${YELLOW}配置 Kind 集群使用本地仓库...${NC}"
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${REGISTRY_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

echo ""
echo -e "${GREEN}=== 配置完成 ===${NC}"
echo ""
echo "使用方法:"
echo "  1. 构建并推送镜像:"
echo "     docker build -t localhost:5000/my-app:latest ."
echo "     docker push localhost:5000/my-app:latest"
echo ""
echo "  2. 在 K8s 中使用:"
echo "     image: localhost:5000/my-app:latest"
echo ""
echo "  3. 查看镜像仓库 UI:"
echo "     open http://localhost:8080"
