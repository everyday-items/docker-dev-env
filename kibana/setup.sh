#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Kibana 启动脚本 ===${NC}"

# 检查 Elasticsearch 是否运行
if ! curl -sf http://localhost:9200 > /dev/null 2>&1; then
    echo -e "${RED}Elasticsearch 未运行，请先启动 Elasticsearch${NC}"
    echo "  cd ../elasticsearch && ./setup.sh"
    exit 1
fi

# 启动
docker-compose up -d

echo -e "${YELLOW}等待 Kibana 启动（约 30 秒）...${NC}"

for i in {1..60}; do
    if curl -sf http://localhost:5601/api/status > /dev/null 2>&1; then
        echo -e "${GREEN}Kibana 已就绪！${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""
echo -e "${GREEN}=== Kibana 启动完成 ===${NC}"
echo ""
echo "访问地址: http://localhost:5601"
echo ""
echo "界面语言: 中文"
