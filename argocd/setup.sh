#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== ArgoCD 安装脚本 ===${NC}"

# 检查 kubectl
if ! command -v kubectl &> /dev/null; then
    echo "请先安装 kubectl"
    exit 1
fi

# 检查集群连接
if ! kubectl cluster-info &> /dev/null; then
    echo "请先创建 K8s 集群 (kind 或 minikube)"
    exit 1
fi

# 创建命名空间
echo -e "${YELLOW}创建 argocd 命名空间...${NC}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# 安装 ArgoCD
echo -e "${YELLOW}安装 ArgoCD...${NC}"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 等待就绪
echo -e "${YELLOW}等待 ArgoCD 就绪...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# 获取初始密码
echo -e "${YELLOW}获取初始密码...${NC}"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo -e "${GREEN}=== ArgoCD 安装完成 ===${NC}"
echo ""
echo "访问方式:"
echo ""
echo "  方式1 - Port Forward (推荐):"
echo "    kubectl port-forward svc/argocd-server -n argocd 8443:443"
echo "    打开: https://localhost:8443"
echo ""
echo "  方式2 - NodePort:"
echo "    kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"NodePort\"}}'"
echo ""
echo "登录信息:"
echo "  用户名: admin"
echo "  密码: $ARGOCD_PASSWORD"
echo ""
echo "安装 ArgoCD CLI (可选):"
echo "  brew install argocd"
echo ""
echo "CLI 登录:"
echo "  argocd login localhost:8443 --username admin --password $ARGOCD_PASSWORD --insecure"
