#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== MongoDB Replica Set 启动脚本 ===${NC}"

# 创建数据目录
mkdir -p data/mongo-1 data/mongo-2 data/mongo-3 scripts

# 创建初始化脚本
cat > scripts/init-replica.js << 'EOF'
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo-1:27017", priority: 2 },
    { _id: 1, host: "mongo-2:27017", priority: 1 },
    { _id: 2, host: "mongo-3:27017", priority: 1 }
  ]
});
EOF

# 启动集群
echo -e "${YELLOW}启动 MongoDB 集群...${NC}"
docker-compose up -d mongo-1 mongo-2 mongo-3

# 等待节点启动
echo -e "${YELLOW}等待节点就绪（约 15 秒）...${NC}"
sleep 15

# 初始化副本集
echo -e "${YELLOW}初始化副本集...${NC}"
docker exec mongo-1 mongosh -u root -p root123 --authenticationDatabase admin --eval '
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo-1:27017", priority: 2 },
    { _id: 1, host: "mongo-2:27017", priority: 1 },
    { _id: 2, host: "mongo-3:27017", priority: 1 }
  ]
});
'

# 等待副本集初始化
echo -e "${YELLOW}等待副本集选举 Primary（约 10 秒）...${NC}"
sleep 10

# 检查副本集状态
echo -e "${YELLOW}检查副本集状态...${NC}"
docker exec mongo-1 mongosh -u root -p root123 --authenticationDatabase admin --eval 'rs.status().members.forEach(m => print(m.name + " -> " + m.stateStr))'

# 启动 Mongo Express
echo -e "${YELLOW}启动 Mongo Express...${NC}"
docker-compose up -d mongo-express

echo ""
echo -e "${GREEN}=== MongoDB Replica Set 启动完成 ===${NC}"
echo ""
echo "节点地址:"
echo "  localhost:27017 (mongo-1, Primary)"
echo "  localhost:27018 (mongo-2, Secondary)"
echo "  localhost:27019 (mongo-3, Secondary)"
echo ""
echo "Mongo Express: http://localhost:8081"
echo "  用户: admin"
echo "  密码: admin123"
echo ""
echo "连接字符串:"
echo "  mongodb://root:root123@localhost:27017,localhost:27018,localhost:27019/?replicaSet=rs0&authSource=admin"
echo ""
echo "测试命令:"
echo "  # 连接主节点"
echo "  docker exec -it mongo-1 mongosh -u root -p root123 --authenticationDatabase admin"
echo ""
echo "  # 查看副本集状态"
echo "  docker exec mongo-1 mongosh -u root -p root123 --authenticationDatabase admin --eval 'rs.status()'"
echo ""
echo "  # 查看主节点"
echo "  docker exec mongo-1 mongosh -u root -p root123 --authenticationDatabase admin --eval 'rs.isMaster()'"
echo ""
echo "Go 代码示例:"
cat << 'EOF'
import "go.mongodb.org/mongo-driver/mongo"
import "go.mongodb.org/mongo-driver/mongo/options"

uri := "mongodb://root:root123@localhost:27017,localhost:27018,localhost:27019/?replicaSet=rs0&authSource=admin"
client, err := mongo.Connect(ctx, options.Client().ApplyURI(uri))
EOF
