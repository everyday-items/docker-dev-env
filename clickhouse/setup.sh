#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== ClickHouse 单机版启动脚本 ===${NC}"

# 创建目录
mkdir -p data logs config

# 启动服务
echo -e "${YELLOW}启动 ClickHouse...${NC}"
docker-compose up -d

# 等待启动
echo -e "${YELLOW}等待服务就绪（约 10 秒）...${NC}"
sleep 10

# 检查状态
echo -e "${YELLOW}检查服务状态...${NC}"
curl -s "http://localhost:8123/ping" && echo -e " ${GREEN}ClickHouse 就绪${NC}" || echo " ClickHouse 未就绪"

echo ""
echo -e "${GREEN}=== ClickHouse 启动完成 ===${NC}"
echo ""
echo "连接信息:"
echo "  HTTP 接口: http://localhost:8123"
echo "  TCP  接口: localhost:9000"
echo "  用户: default"
echo "  密码: clickhouse123"
echo ""
echo "测试命令:"
echo "  # HTTP 查询"
echo "  curl 'http://localhost:8123/?user=default&password=clickhouse123' --data 'SELECT version()'"
echo ""
echo "  # 进入客户端"
echo "  docker exec -it clickhouse clickhouse-client --user default --password clickhouse123"
echo ""
echo "  # 查看数据库"
echo "  docker exec -it clickhouse clickhouse-client --user default --password clickhouse123 -q 'SHOW DATABASES'"
echo ""
echo "Go 代码示例:"
cat << 'EOF'
import "github.com/ClickHouse/clickhouse-go/v2"

conn, err := clickhouse.Open(&clickhouse.Options{
    Addr: []string{"localhost:9000"},
    Auth: clickhouse.Auth{
        Database: "default",
        Username: "default",
        Password: "clickhouse123",
    },
})
EOF
