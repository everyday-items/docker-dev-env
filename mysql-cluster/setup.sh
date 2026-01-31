#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== MySQL 主从集群启动脚本 ===${NC}"

# 创建数据目录
mkdir -p data/master data/slave-1 data/slave-2

# 启动主节点
echo -e "${YELLOW}启动主节点...${NC}"
docker-compose up -d mysql-master

# 等待主节点就绪
echo -e "${YELLOW}等待主节点就绪...${NC}"
for i in {1..30}; do
    if docker exec mysql-master mysqladmin ping -uroot -proot123 > /dev/null 2>&1; then
        echo -e "${GREEN}主节点已就绪${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# 获取主节点 binlog 位置
echo -e "${YELLOW}获取主节点 binlog 位置...${NC}"
MASTER_STATUS=$(docker exec mysql-master mysql -uroot -proot123 -e "SHOW MASTER STATUS\G" 2>/dev/null)
MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | grep "File:" | awk '{print $2}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | grep "Position:" | awk '{print $2}')

echo "Master Log File: $MASTER_LOG_FILE"
echo "Master Log Pos: $MASTER_LOG_POS"

# 启动从节点
echo -e "${YELLOW}启动从节点...${NC}"
docker-compose up -d mysql-slave-1 mysql-slave-2

# 等待从节点就绪
sleep 10

# 配置从节点复制
for slave in mysql-slave-1 mysql-slave-2; do
    echo -e "${YELLOW}配置 $slave 复制...${NC}"
    docker exec $slave mysql -uroot -proot123 -e "
        STOP REPLICA;
        CHANGE REPLICATION SOURCE TO
            SOURCE_HOST='mysql-master',
            SOURCE_USER='repl',
            SOURCE_PASSWORD='repl123',
            SOURCE_LOG_FILE='$MASTER_LOG_FILE',
            SOURCE_LOG_POS=$MASTER_LOG_POS;
        START REPLICA;
    " 2>/dev/null
done

# 检查复制状态
sleep 3
echo ""
echo -e "${GREEN}=== MySQL 集群启动完成 ===${NC}"
echo ""
echo "主节点: localhost:3316 (读写)"
echo "从节点1: localhost:3317 (只读)"
echo "从节点2: localhost:3318 (只读)"
echo ""
echo "用户名: root"
echo "密码:   root123"
echo ""
echo "检查复制状态:"
echo "  docker exec mysql-slave-1 mysql -uroot -proot123 -e 'SHOW REPLICA STATUS\G'"
echo ""
echo "Go 代码示例（读写分离）:"
cat << 'EOF'
import (
    "gorm.io/driver/mysql"
    "gorm.io/gorm"
    "gorm.io/plugin/dbresolver"
)

db, _ := gorm.Open(mysql.Open("root:root123@tcp(localhost:3316)/app"))

db.Use(dbresolver.Register(dbresolver.Config{
    Sources:  []gorm.Dialector{mysql.Open("root:root123@tcp(localhost:3316)/app")},
    Replicas: []gorm.Dialector{
        mysql.Open("root:root123@tcp(localhost:3317)/app"),
        mysql.Open("root:root123@tcp(localhost:3318)/app"),
    },
    Policy: dbresolver.RandomPolicy{},
}))
EOF
