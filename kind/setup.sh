#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Kind K8s 集群安装脚本 ===${NC}"

# 检查 kind 是否安装
if ! command -v kind &> /dev/null; then
    echo -e "${YELLOW}kind 未安装，正在安装...${NC}"

    # 检测系统
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install kind
        else
            echo -e "${RED}请先安装 Homebrew 或手动安装 kind${NC}"
            echo "手动安装: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.21.0/kind-linux-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
    else
        echo -e "${RED}不支持的操作系统，请手动安装 kind${NC}"
        exit 1
    fi
fi

# 检查 kubectl 是否安装
if ! command -v kubectl &> /dev/null; then
    echo -e "${YELLOW}kubectl 未安装，正在安装...${NC}"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install kubectl
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    fi
fi

# 选择集群配置
CONFIG_FILE="kind-config.yaml"
if [[ "$1" == "simple" ]]; then
    CONFIG_FILE="kind-config-simple.yaml"
    echo -e "${YELLOW}使用单节点配置${NC}"
else
    echo -e "${YELLOW}使用多节点配置（1 控制面 + 2 工作节点）${NC}"
fi

# 检查集群是否已存在
if kind get clusters 2>/dev/null | grep -q "dev-cluster"; then
    echo -e "${YELLOW}集群 dev-cluster 已存在${NC}"
    read -p "是否删除并重新创建？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kind delete cluster --name dev-cluster
    else
        echo "保留现有集群"
        exit 0
    fi
fi

# 创建集群
echo -e "${GREEN}正在创建集群...${NC}"
kind create cluster --config $CONFIG_FILE

# 等待节点就绪
echo -e "${GREEN}等待节点就绪...${NC}"
kubectl wait --for=condition=Ready nodes --all --timeout=120s

# 安装 Ingress Nginx（可选）
read -p "是否安装 Ingress Nginx？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}正在安装 Ingress Nginx...${NC}"
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

    echo -e "${YELLOW}等待 Ingress 就绪...${NC}"
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=120s
fi

echo ""
echo -e "${GREEN}=== 集群创建完成 ===${NC}"
echo ""
kubectl cluster-info
echo ""
kubectl get nodes
echo ""
echo -e "${GREEN}常用命令：${NC}"
echo "  kubectl get pods -A          # 查看所有 Pod"
echo "  kubectl get svc -A           # 查看所有 Service"
echo "  kind delete cluster --name dev-cluster  # 删除集群"
