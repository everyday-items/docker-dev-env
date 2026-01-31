#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Elasticsearch 启动脚本 ===${NC}"

# 创建数据目录并设置权限
mkdir -p data
chmod 777 data

# 启动
docker-compose up -d

echo -e "${YELLOW}等待 Elasticsearch 启动...${NC}"
sleep 10

# 检查健康状态
for i in {1..30}; do
    if curl -sf http://localhost:9200/_cluster/health > /dev/null 2>&1; then
        echo -e "${GREEN}Elasticsearch 已就绪！${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""
echo -e "${GREEN}=== Elasticsearch 启动完成 ===${NC}"
echo ""
echo "访问地址: http://localhost:9200"
echo ""
echo "测试命令:"
echo "  curl http://localhost:9200"
echo "  curl http://localhost:9200/_cluster/health?pretty"
echo ""
echo "接下来启动 Kibana:"
echo "  cd ../kibana && docker-compose up -d"
