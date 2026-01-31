#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== 删除 Minikube K8s 集群 ===${NC}"

if minikube status &> /dev/null; then
    read -p "确定要删除 Minikube 集群吗？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        minikube delete
        echo -e "${GREEN}集群已删除${NC}"
    else
        echo "取消操作"
    fi
else
    echo -e "${YELLOW}Minikube 集群不存在${NC}"
fi
