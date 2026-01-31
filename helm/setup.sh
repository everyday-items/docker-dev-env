#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Helm 安装脚本 ===${NC}"

# 检查 helm 是否已安装
if command -v helm &> /dev/null; then
    echo -e "${YELLOW}Helm 已安装${NC}"
    helm version
    exit 0
fi

echo -e "${YELLOW}正在安装 Helm...${NC}"

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command -v brew &> /dev/null; then
        brew install helm
    else
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "不支持的操作系统，请手动安装 Helm"
    echo "https://helm.sh/docs/intro/install/"
    exit 1
fi

echo ""
echo -e "${GREEN}=== Helm 安装完成 ===${NC}"
helm version
echo ""
echo "常用命令:"
echo "  helm repo add bitnami https://charts.bitnami.com/bitnami  # 添加仓库"
echo "  helm search repo <keyword>     # 搜索 Chart"
echo "  helm install <name> <chart>    # 安装"
echo "  helm list                      # 查看已安装"
echo "  helm uninstall <name>          # 卸载"
