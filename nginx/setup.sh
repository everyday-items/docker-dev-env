#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Nginx 启动脚本 ===${NC}"

# 创建目录
mkdir -p logs ssl html

# 检查配置
echo -e "${YELLOW}检查 Nginx 配置...${NC}"
docker run --rm -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
    -v $(pwd)/conf.d:/etc/nginx/conf.d:ro \
    nginx:1.25-alpine nginx -t

# 启动
docker-compose up -d

echo ""
echo -e "${GREEN}=== Nginx 启动完成 ===${NC}"
echo ""
echo "访问地址: http://localhost"
echo ""
echo "配置文件:"
echo "  nginx.conf      - 主配置"
echo "  conf.d/*.conf   - 站点配置"
echo ""
echo "启用示例配置:"
echo "  mv conf.d/api-proxy.conf.example conf.d/api-proxy.conf"
echo "  docker-compose restart"
echo ""
echo "常用命令:"
echo "  docker exec nginx nginx -t        # 测试配置"
echo "  docker exec nginx nginx -s reload # 重载配置"
