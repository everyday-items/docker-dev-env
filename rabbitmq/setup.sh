#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== RabbitMQ 启动脚本 ===${NC}"

# 创建数据目录
mkdir -p data

# 启动
docker-compose up -d

echo -e "${YELLOW}等待 RabbitMQ 启动...${NC}"
sleep 10

for i in {1..30}; do
    if docker exec rabbitmq rabbitmq-diagnostics check_running > /dev/null 2>&1; then
        echo -e "${GREEN}RabbitMQ 已就绪！${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""
echo -e "${GREEN}=== RabbitMQ 启动完成 ===${NC}"
echo ""
echo "管理界面: http://localhost:15672"
echo "AMQP 端口: localhost:5672"
echo ""
echo "用户名: admin"
echo "密码:   admin123"
echo ""
echo "============================================"
echo ""
echo "Go 代码示例 (github.com/rabbitmq/amqp091-go):"
echo ""
cat << 'EOF'
import amqp "github.com/rabbitmq/amqp091-go"

// 连接
conn, _ := amqp.Dial("amqp://admin:admin123@localhost:5672/")
ch, _ := conn.Channel()

// 声明队列
q, _ := ch.QueueDeclare("task_queue", true, false, false, false, nil)

// 发送消息
ch.PublishWithContext(ctx, "", q.Name, false, false, amqp.Publishing{
    ContentType: "text/plain",
    Body:        []byte("Hello World"),
})

// 消费消息
msgs, _ := ch.Consume(q.Name, "", true, false, false, false, nil)
for msg := range msgs {
    fmt.Println(string(msg.Body))
}
EOF
echo ""
