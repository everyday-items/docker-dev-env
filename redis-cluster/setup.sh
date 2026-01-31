#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Redis ACL 用户配置
REDIS_USER=${REDIS_USER:-app}
REDIS_PASSWORD=${REDIS_PASSWORD:-redis123}

echo -e "${GREEN}=== Redis Cluster 启动脚本 ===${NC}"

# 获取本机 IP
if [[ "$OSTYPE" == "darwin"* ]]; then
    HOST_IP=$(ipconfig getifaddr en0 2>/dev/null || echo "127.0.0.1")
else
    HOST_IP=$(hostname -I | awk '{print $1}' || echo "127.0.0.1")
fi

export HOST_IP
echo -e "${YELLOW}使用 IP: $HOST_IP${NC}"

# 创建数据目录
for i in {1..6}; do
    mkdir -p data/node-$i
done

# 清理旧的集群配置
echo -e "${YELLOW}清理旧配置...${NC}"
rm -f data/node-*/nodes.conf 2>/dev/null || true

# 启动节点
echo -e "${YELLOW}启动 Redis 节点...${NC}"
docker-compose up -d

# 等待节点启动
echo -e "${YELLOW}等待节点启动...${NC}"
sleep 5

# 检查节点状态
for i in {1..6}; do
    port=$((6370 + i))
    if ! redis-cli -h $HOST_IP -p $port --user "$REDIS_USER" --pass "$REDIS_PASSWORD" --no-auth-warning ping > /dev/null 2>&1; then
        echo -e "${RED}节点 $port 未就绪${NC}"
        exit 1
    fi
done

echo -e "${GREEN}所有节点已启动${NC}"

# 创建集群
echo -e "${YELLOW}创建集群...${NC}"
redis-cli --cluster create \
    $HOST_IP:6371 \
    $HOST_IP:6372 \
    $HOST_IP:6373 \
    $HOST_IP:6374 \
    $HOST_IP:6375 \
    $HOST_IP:6376 \
    --cluster-replicas 1 \
    --cluster-yes \
    --user "$REDIS_USER" --pass "$REDIS_PASSWORD" --no-auth-warning

echo ""
echo -e "${GREEN}=== Redis Cluster 创建完成 ===${NC}"
echo ""
echo "集群节点: $HOST_IP:6371 - $HOST_IP:6376"
echo "用户: $REDIS_USER"
echo "密码: $REDIS_PASSWORD"
echo ""
echo "测试命令:"
echo "  redis-cli -c -h $HOST_IP -p 6371 --user $REDIS_USER --pass $REDIS_PASSWORD cluster info"
echo "  redis-cli -c -h $HOST_IP -p 6371 --user $REDIS_USER --pass $REDIS_PASSWORD cluster nodes"
echo "  redis-cli -c -h $HOST_IP -p 6371 --user $REDIS_USER --pass $REDIS_PASSWORD set foo bar"
echo "  redis-cli -c -h $HOST_IP -p 6371 --user $REDIS_USER --pass $REDIS_PASSWORD get foo"
echo ""
echo "Go 连接示例:"
cat << EOF
import "github.com/redis/go-redis/v9"

rdb := redis.NewClusterClient(&redis.ClusterOptions{
    Addrs: []string{
        "$HOST_IP:6371", "$HOST_IP:6372", "$HOST_IP:6373",
        "$HOST_IP:6374", "$HOST_IP:6375", "$HOST_IP:6376",
    },
    Username: "$REDIS_USER",
    Password: "$REDIS_PASSWORD",
})
EOF
