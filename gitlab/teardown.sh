#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== GitLab 管理脚本 ===${NC}"
echo ""
echo "1) 停止 GitLab（保留数据）"
echo "2) 删除 GitLab 容器（保留数据）"
echo "3) 完全删除（包括所有数据）⚠️"
echo "4) 取消"
echo ""
read -p "请选择 [1-4]: " choice

case $choice in
    1)
        docker-compose stop
        echo -e "${GREEN}GitLab 已停止，数据已保留${NC}"
        echo "重新启动: docker-compose up -d"
        ;;
    2)
        docker-compose down
        echo -e "${GREEN}GitLab 容器已删除，数据已保留${NC}"
        echo "重新启动: docker-compose up -d"
        ;;
    3)
        echo -e "${RED}警告: 这将删除所有代码仓库、配置和数据！${NC}"
        read -p "确定要继续吗？输入 'DELETE' 确认: " confirm
        if [ "$confirm" == "DELETE" ]; then
            docker-compose down -v
            rm -rf data/
            echo -e "${GREEN}GitLab 已完全删除${NC}"
        else
            echo "取消操作"
        fi
        ;;
    *)
        echo "取消操作"
        ;;
esac
