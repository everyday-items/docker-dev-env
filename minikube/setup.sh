#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Minikube K8s 集群安装脚本 ===${NC}"

# 检查 minikube 是否安装
if ! command -v minikube &> /dev/null; then
    echo -e "${YELLOW}minikube 未安装，正在安装...${NC}"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install minikube
        else
            echo -e "${RED}请先安装 Homebrew 或手动安装 minikube${NC}"
            echo "手动安装: https://minikube.sigs.k8s.io/docs/start/"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
    else
        echo -e "${RED}不支持的操作系统，请手动安装 minikube${NC}"
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

# 解析参数
DRIVER="docker"
CPUS="2"
MEMORY="4096"
NODES="1"

while [[ $# -gt 0 ]]; do
    case $1 in
        --driver)
            DRIVER="$2"
            shift 2
            ;;
        --cpus)
            CPUS="$2"
            shift 2
            ;;
        --memory)
            MEMORY="$2"
            shift 2
            ;;
        --nodes)
            NODES="$2"
            shift 2
            ;;
        --multi)
            NODES="3"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo -e "${YELLOW}配置: driver=$DRIVER, cpus=$CPUS, memory=${MEMORY}MB, nodes=$NODES${NC}"

# 检查是否已存在集群
if minikube status &> /dev/null; then
    echo -e "${YELLOW}Minikube 集群已存在${NC}"
    read -p "是否删除并重新创建？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        minikube delete
    else
        echo "保留现有集群"
        exit 0
    fi
fi

# 创建集群
echo -e "${GREEN}正在创建集群...${NC}"
minikube start \
    --driver=$DRIVER \
    --cpus=$CPUS \
    --memory=$MEMORY \
    --nodes=$NODES \
    --addons=ingress,metrics-server,dashboard

# 等待就绪
echo -e "${GREEN}等待节点就绪...${NC}"
kubectl wait --for=condition=Ready nodes --all --timeout=180s

echo ""
echo -e "${GREEN}=== 集群创建完成 ===${NC}"
echo ""
kubectl cluster-info
echo ""
kubectl get nodes
echo ""
echo -e "${GREEN}常用命令：${NC}"
echo "  minikube dashboard          # 打开 Dashboard"
echo "  minikube tunnel             # 启用 LoadBalancer（新终端运行）"
echo "  minikube service <name>     # 访问服务"
echo "  minikube image load <img>   # 加载本地镜像"
echo "  minikube stop               # 停止集群"
echo "  minikube delete             # 删除集群"
