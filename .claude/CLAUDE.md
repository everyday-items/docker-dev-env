# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker 开发环境模板仓库，用于快速搭建 Golang 微服务开发环境。包含 30+ 容器化服务，涵盖数据存储、消息队列、服务治理、可观测性和 DevOps 工具。

## 常用命令

```bash
# 首次使用：创建统一网络
./network-setup.sh

# 单机服务启动
cd <service> && docker-compose up -d

# 集群服务启动（使用 setup.sh）
cd redis-cluster && ./setup.sh
cd mysql-cluster && ./setup.sh
cd mongodb-cluster && ./setup.sh
cd kafka-cluster && ./setup.sh
cd clickhouse-cluster && ./setup.sh

# K8s 本地环境
cd kind && ./setup.sh
cd minikube && ./setup.sh

# Go 开发环境
cd go-dev && ./setup.sh
PROJECT_PATH=/path/to/project docker-compose run --rm go-dev bash
```

### Go 项目模板命令 (templates/go-zero/)

```bash
make build       # 编译
make run         # 运行
make dev         # 热重载 (air)
make test        # 测试
make lint        # golangci-lint
make gen         # goctl 代码生成
make docker-build  # 构建镜像
make k8s-deploy    # 部署到 K8s
```

## 架构模式

### Docker Compose 服务模式

**单机服务**: 直接 `docker-compose up -d`

**集群服务**: 使用 `setup.sh` 脚本，包含：
1. 目录创建和清理
2. 服务启动顺序控制
3. 健康检查等待
4. 集群初始化命令（如 Redis CLUSTER CREATE、MongoDB rs.initiate）

### 配置约定

- 端口映射: `${VARIABLE_PORT:-default_port}` 格式
- 时区: 统一 `TZ=Asia/Shanghai`
- 配置文件: 挂载为只读 (`:ro`)
- 数据目录: `./data/`，已 gitignore
- 密钥目录: `./secrets/`，已 gitignore（使用 `_FILE` 后缀变量读取）

### 网络模式

- **统一网络 (dev-net)**: 所有单机服务加入，容器间通过服务名通信
- **集群服务**: 使用各自的内部网络 + dev-net
- **兼容模式**: 保留 `host.docker.internal` 访问宿主机

## 默认配置

| 服务 | 端口 | 用户 | 密码 |
|------|------|------|------|
| Redis | 6379 | app | redis123 |
| Redis Cluster | 6371-6376 | app | redis123 |
| MySQL | 3306 | root | root123 |
| MySQL Cluster | 3316-3318 | root | root123 |
| MongoDB | 27017 | root | root123 |
| MongoDB Cluster | 27017-27019 | root | root123 |
| ClickHouse | 8123/9000 | default | clickhouse123 |
| ClickHouse Cluster | 8123-8126 | default | clickhouse123 |
| etcd | 2379 | root | etcd123 |
| Kafka | 9094 | app | kafka123 |
| Kafka Cluster | 9192-9194 (+ UI 8088) | app | kafka123 |
| RabbitMQ | 5672/15672 | admin | admin123 |
| DTM | 36789 (HTTP) / 36790 (gRPC) | - | - |
| Jaeger | 16686 | - | - |
| Prometheus | 9090 | - | - |
| Grafana | 3000 | admin | admin123 |
| MinIO | 9000/9001 | admin | admin123456 |
| Elasticsearch | 9200 | elastic | elastic123 |
| Kibana | 5601 | elastic | elastic123 |
| Nginx | 80/443 | - | - |
| GitLab | 8929 | root | gitlab123456 |
| Registry | 5000/8080 | admin | registry123 |

## Docker 化 Go 开发环境（无需本地安装 Go）

### 初始化

```bash
cd go-dev && ./setup.sh   # 构建镜像
```

### 使用方式

```bash
# 方式1：交互式开发（推荐）
cd go-dev
PROJECT_PATH=/path/to/your/project docker-compose run --rm go-dev bash

# 方式2：后台容器
PROJECT_PATH=/path/to/your/project docker-compose up -d go-dev
docker exec -it go-dev bash

# 方式3：热重载开发（项目需有 .air.toml）
PROJECT_PATH=/path/to/your/project docker-compose --profile air up go-dev-air
```

### Shell 快捷命令

添加到 `~/.bashrc` 或 `~/.zshrc`：

```bash
# 进入 Go 开发环境
alias godev='docker run --rm -it -v $(pwd):/app -v go-mod-cache:/go/pkg/mod -v go-build-cache:/root/.cache/go-build -w /app go-dev:1.25 bash'

# 常用命令
alias gobuild='docker run --rm -v $(pwd):/app -v go-mod-cache:/go/pkg/mod -w /app go-dev:1.25 go build -o ./bin/app .'
alias gotest='docker run --rm -v $(pwd):/app -v go-mod-cache:/go/pkg/mod -w /app go-dev:1.25 go test ./...'
alias gofmt='docker run --rm -v $(pwd):/app -w /app go-dev:1.25 gofmt -w .'
alias golint='docker run --rm -v $(pwd):/app -v go-mod-cache:/go/pkg/mod -w /app go-dev:1.25 golangci-lint run'

# 工具命令
alias goctl='docker run --rm -v $(pwd):/app -w /app go-dev:1.25 goctl'
alias swag='docker run --rm -v $(pwd):/app -w /app go-dev:1.25 swag'
alias protoc='docker run --rm -v $(pwd):/app -w /app go-dev:1.25 protoc'
```

### 容器内预装工具

| 工具 | 用途 |
|------|------|
| go 1.25 | Go 编译器 |
| air | 热重载 |
| goctl | go-zero 代码生成 |
| swag | Swagger 文档生成 |
| protoc + protoc-gen-go | Protobuf 编译 |
| golangci-lint | 代码检查 |
| gopls | LSP 语言服务 |
| dlv | 调试器 |

### 容器内常用命令

```bash
go mod init myproject    # 初始化项目
go mod tidy              # 整理依赖
go run main.go           # 运行
go build -o app .        # 编译
go test ./...            # 测试
air                      # 热重载（需 .air.toml）
goctl api new myapi      # 创建 go-zero API
swag init                # 生成 Swagger 文档
```

### 连接其他服务（统一网络）

所有服务已加入 `dev-net` 网络，容器内直接用服务名访问：

```go
// 连接 MySQL（通过容器名）
dsn := "root:root123@tcp(mysql:3306)/mydb"

// 连接 Redis（ACL 认证）
rdb := redis.NewClient(&redis.Options{
    Addr:     "redis:6379",
    Username: "app",
    Password: "redis123",
})

// 连接 etcd（需认证）
cli, _ := clientv3.New(clientv3.Config{
    Endpoints: []string{"etcd:2379"},
    Username:  "root",
    Password:  "etcd123",
})

// 连接 Kafka（SASL 认证）
config := sarama.NewConfig()
config.Net.SASL.Enable = true
config.Net.SASL.User = "app"
config.Net.SASL.Password = "kafka123"
config.Net.SASL.Mechanism = sarama.SASLTypePlaintext
brokers := []string{"kafka:9092"}

// 连接 MongoDB
uri := "mongodb://root:root123@mongodb:27017"

// 连接 Jaeger
endpoint := "http://jaeger:14268/api/traces"
```

**首次使用需先创建网络**：
```bash
./network-setup.sh
```

## go-zero 配置示例

```yaml
# etcd 服务发现（带认证）
Etcd:
  Hosts:
    - localhost:2379
  Key: service.rpc
  User: root
  Pass: etcd123

# 链路追踪
Telemetry:
  Name: service-name
  Endpoint: http://localhost:14268/api/traces
  Batcher: jaeger

# Prometheus 指标
Prometheus:
  Host: 0.0.0.0
  Port: 9081
  Path: /metrics

# Kafka（SASL 认证）
KafkaConf:
  Brokers:
    - localhost:9094
  Username: app
  Password: kafka123

# DTM 分布式事务
DtmConf:
  Target: localhost:36790
```

## 验证服务状态

```bash
# Redis Cluster
docker exec redis-node-1 redis-cli --user app --pass redis123 -c cluster info

# MySQL 主从
docker exec mysql-slave-1 mysql -uroot -proot123 -e "SHOW REPLICA STATUS\G"

# MongoDB 副本集
docker exec mongo-1 mongosh -u root -p root123 --eval 'rs.status()'

# etcd
docker exec etcd etcdctl --user root:etcd123 endpoint health

# Kafka（需 SASL 认证）
docker exec kafka kafka-topics.sh --bootstrap-server localhost:9092 \
  --command-config /opt/bitnami/kafka/config/client.properties --list

# Elasticsearch
curl -u elastic:elastic123 http://localhost:9200/_cluster/health?pretty

# Registry
curl -u admin:registry123 http://localhost:5000/v2/_catalog
```
