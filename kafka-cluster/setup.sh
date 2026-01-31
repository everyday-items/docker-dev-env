#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Kafka Cluster 启动脚本 ===${NC}"

# 创建数据目录
mkdir -p data/kafka-1 data/kafka-2 data/kafka-3

# 启动集群
echo -e "${YELLOW}启动 Kafka 集群...${NC}"
docker-compose up -d

# 等待启动
echo -e "${YELLOW}等待集群就绪（约 30 秒）...${NC}"
sleep 30

# 检查集群状态
echo -e "${YELLOW}检查集群状态...${NC}"
docker exec kafka-1 kafka-broker-api-versions.sh --bootstrap-server localhost:9092 > /dev/null 2>&1 && \
    echo -e "${GREEN}Kafka-1 就绪${NC}" || echo "Kafka-1 未就绪"
docker exec kafka-2 kafka-broker-api-versions.sh --bootstrap-server localhost:9092 > /dev/null 2>&1 && \
    echo -e "${GREEN}Kafka-2 就绪${NC}" || echo "Kafka-2 未就绪"
docker exec kafka-3 kafka-broker-api-versions.sh --bootstrap-server localhost:9092 > /dev/null 2>&1 && \
    echo -e "${GREEN}Kafka-3 就绪${NC}" || echo "Kafka-3 未就绪"

echo ""
echo -e "${GREEN}=== Kafka Cluster 启动完成 ===${NC}"
echo ""
echo "Broker 地址:"
echo "  localhost:9192 (Kafka-1)"
echo "  localhost:9193 (Kafka-2)"
echo "  localhost:9194 (Kafka-3)"
echo ""
echo "Kafka UI: http://localhost:8088"
echo ""
echo "测试命令:"
echo "  # 创建 topic（3 副本）"
echo "  docker exec kafka-1 kafka-topics.sh --create --topic test --partitions 3 --replication-factor 3 --bootstrap-server localhost:9092"
echo ""
echo "  # 查看 topic"
echo "  docker exec kafka-1 kafka-topics.sh --describe --topic test --bootstrap-server localhost:9092"
echo ""
echo "  # 生产消息"
echo "  docker exec -it kafka-1 kafka-console-producer.sh --topic test --bootstrap-server localhost:9092"
echo ""
echo "  # 消费消息"
echo "  docker exec -it kafka-1 kafka-console-consumer.sh --topic test --from-beginning --bootstrap-server localhost:9092"
echo ""
echo "Go 代码示例:"
cat << 'EOF'
import "github.com/segmentio/kafka-go"

writer := kafka.NewWriter(kafka.WriterConfig{
    Brokers: []string{"localhost:9192", "localhost:9193", "localhost:9194"},
    Topic:   "test",
})

reader := kafka.NewReader(kafka.ReaderConfig{
    Brokers: []string{"localhost:9192", "localhost:9193", "localhost:9194"},
    Topic:   "test",
    GroupID: "my-group",
})
EOF
