#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== 删除 Kind K8s 集群 ===${NC}"

if kind get clusters 2>/dev/null | grep -q "dev-cluster"; then
    read -p "确定要删除集群 dev-cluster 吗？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kind delete cluster --name dev-cluster
        echo -e "${GREEN}集群已删除${NC}"
    else
        echo "取消操作"
    fi
else
    echo -e "${YELLOW}集群 dev-cluster 不存在${NC}"
fi
