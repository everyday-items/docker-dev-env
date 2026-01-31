#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== 卸载 ArgoCD ===${NC}"

if kubectl get namespace argocd &> /dev/null; then
    read -p "确定要卸载 ArgoCD 吗？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
        kubectl delete namespace argocd
        echo -e "${GREEN}ArgoCD 已卸载${NC}"
    else
        echo "取消操作"
    fi
else
    echo -e "${YELLOW}ArgoCD 未安装${NC}"
fi
