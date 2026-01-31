#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo -e "${GREEN}=== GitLab 备份脚本 ===${NC}"

mkdir -p $BACKUP_DIR

echo -e "${YELLOW}正在创建备份...${NC}"

# 创建 GitLab 备份
docker exec gitlab gitlab-backup create STRATEGY=copy

# 复制备份文件
echo -e "${YELLOW}正在导出备份文件...${NC}"
docker cp gitlab:/var/opt/gitlab/backups/. $BACKUP_DIR/

# 备份配置文件
echo -e "${YELLOW}正在备份配置文件...${NC}"
tar -czf $BACKUP_DIR/gitlab_config_$DATE.tar.gz -C data config

echo ""
echo -e "${GREEN}=== 备份完成 ===${NC}"
echo "备份位置: $BACKUP_DIR/"
ls -la $BACKUP_DIR/
echo ""
echo "恢复命令:"
echo "  docker exec gitlab gitlab-backup restore BACKUP=<timestamp>"
