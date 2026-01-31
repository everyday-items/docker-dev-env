#!/bin/bash
# 创建开发环境统一网络

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

NETWORK_NAME="dev-net"

# 检查网络是否存在
if docker network inspect $NETWORK_NAME > /dev/null 2>&1; then
    echo -e "${YELLOW}网络 $NETWORK_NAME 已存在${NC}"
else
    echo -e "${GREEN}创建网络 $NETWORK_NAME ...${NC}"
    docker network create $NETWORK_NAME
    echo -e "${GREEN}网络创建成功${NC}"
fi

echo ""
echo -e "${GREEN}=== 开发网络配置完成 ===${NC}"
echo ""
echo "所有服务将加入 $NETWORK_NAME 网络，容器间可通过服务名互相访问："
echo ""
echo "  MySQL:         mysql:3306"
echo "  Redis:         redis:6379"
echo "  MongoDB:       mongodb:27017"
echo "  Kafka:         kafka:9092"
echo "  etcd:          etcd:2379"
echo "  Elasticsearch: elasticsearch:9200"
echo "  Jaeger:        jaeger:14268"
echo "  Prometheus:    prometheus:9090"
echo ""
echo "Go 代码示例："
echo '  dsn := "root:root123@tcp(mysql:3306)/app"'
echo '  redisAddr := "redis:6379"'
echo ""
