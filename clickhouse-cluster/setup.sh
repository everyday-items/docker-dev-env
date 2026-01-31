#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== ClickHouse Cluster 启动脚本 ===${NC}"

# 创建目录
mkdir -p data/keeper-1 data/keeper-2 data/keeper-3
mkdir -p data/s1r1 data/s1r2 data/s2r1 data/s2r2
mkdir -p logs/s1r1 logs/s1r2 logs/s2r1 logs/s2r2

# 启动 Keeper 集群
echo -e "${YELLOW}启动 ClickHouse Keeper 集群...${NC}"
docker-compose up -d clickhouse-keeper-1 clickhouse-keeper-2 clickhouse-keeper-3

# 等待 Keeper 启动
echo -e "${YELLOW}等待 Keeper 集群就绪（约 15 秒）...${NC}"
sleep 15

# 启动 ClickHouse 节点
echo -e "${YELLOW}启动 ClickHouse 节点...${NC}"
docker-compose up -d clickhouse-s1r1 clickhouse-s1r2 clickhouse-s2r1 clickhouse-s2r2

# 等待节点启动
echo -e "${YELLOW}等待 ClickHouse 节点就绪（约 20 秒）...${NC}"
sleep 20

# 检查集群状态
echo -e "${YELLOW}检查集群状态...${NC}"
docker exec clickhouse-s1r1 clickhouse-client --user default --password clickhouse123 \
    -q "SELECT * FROM system.clusters WHERE cluster = 'cluster_2s2r'" 2>/dev/null && \
    echo -e "${GREEN}集群配置正常${NC}" || echo "集群配置检查失败"

echo ""
echo -e "${GREEN}=== ClickHouse Cluster 启动完成 ===${NC}"
echo ""
echo "集群架构: 2 分片 × 2 副本（4 节点）"
echo ""
echo "节点信息:"
echo "  Shard 1:"
echo "    clickhouse-s1r1: localhost:8123 (HTTP) / localhost:9000 (TCP)"
echo "    clickhouse-s1r2: localhost:8124 (HTTP) / localhost:9001 (TCP)"
echo "  Shard 2:"
echo "    clickhouse-s2r1: localhost:8125 (HTTP) / localhost:9002 (TCP)"
echo "    clickhouse-s2r2: localhost:8126 (HTTP) / localhost:9003 (TCP)"
echo ""
echo "Keeper 集群:"
echo "  clickhouse-keeper-1: localhost:9181"
echo "  clickhouse-keeper-2: localhost:9182"
echo "  clickhouse-keeper-3: localhost:9183"
echo ""
echo "用户: default"
echo "密码: clickhouse123"
echo "集群名: cluster_2s2r"
echo ""
echo "测试命令:"
echo "  # 连接任意节点"
echo "  docker exec -it clickhouse-s1r1 clickhouse-client --user default --password clickhouse123"
echo ""
echo "  # 查看集群状态"
echo "  docker exec clickhouse-s1r1 clickhouse-client --user default --password clickhouse123 -q \"SELECT * FROM system.clusters WHERE cluster = 'cluster_2s2r'\""
echo ""
echo "  # 创建分布式表示例"
cat << 'EOFCREATE'
  -- 在所有节点创建本地表
  CREATE TABLE test_local ON CLUSTER cluster_2s2r (
      id UInt64,
      name String,
      created_at DateTime DEFAULT now()
  ) ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/test_local', '{replica}')
  ORDER BY id;

  -- 创建分布式表
  CREATE TABLE test_distributed ON CLUSTER cluster_2s2r AS test_local
  ENGINE = Distributed(cluster_2s2r, default, test_local, rand());
EOFCREATE
echo ""
echo "Go 代码示例:"
cat << 'EOF'
import "github.com/ClickHouse/clickhouse-go/v2"

conn, err := clickhouse.Open(&clickhouse.Options{
    Addr: []string{
        "localhost:9000",
        "localhost:9001",
        "localhost:9002",
        "localhost:9003",
    },
    Auth: clickhouse.Auth{
        Database: "default",
        Username: "default",
        Password: "clickhouse123",
    },
    Settings: clickhouse.Settings{
        "max_execution_time": 60,
    },
})
EOF
