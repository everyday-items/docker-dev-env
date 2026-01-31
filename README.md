# Docker 开发环境模板

用于快速搭建 Golang 微服务开发环境。

## 目录

- [服务列表](#服务列表)
  - [数据存储](#数据存储)
  - [消息队列](#消息队列)
  - [服务治理](#服务治理)
  - [可观测性](#可观测性)
  - [DevOps](#devops)
  - [开发环境](#开发环境)
  - [项目模板](#项目模板)
- [快速开始](#快速开始)
- [集群版启动](#集群版启动)
- [Go 开发环境](#go-开发环境无需本地安装-go)
- [项目模板使用](#项目模板使用)
- [组件常用命令](#组件常用命令)
  - [数据存储命令](#数据存储命令)
  - [消息队列命令](#消息队列命令)
  - [服务治理命令](#服务治理命令)
  - [可观测性命令](#可观测性命令)
  - [Docker 通用命令](#docker-通用命令)
- [网络说明](#网络说明)
  - [network-setup.sh](#network-setupsh)
  - [访问方式](#访问方式)
- [常见问题](#常见问题)
  - [镜像拉取慢](#1-镜像拉取慢)
  - [端口被占用](#2-端口被占用)
  - [磁盘空间不足](#3-磁盘空间不足)
  - [容器时区不对](#4-容器时区不对)
  - [MySQL 连接被拒绝](#5-mysql-连接被拒绝)
  - [容器间网络不通](#6-容器间网络不通)
  - [日志文件过大](#7-日志文件过大)

---

## 服务列表

### 数据存储

| 服务 | 目录 | 端口 | 用户/密码 |
|------|------|------|----------|
| Redis | `redis/` | 6379 | - |
| Redis Cluster | `redis-cluster/` | 6371-6376 | - |
| MySQL | `mysql/` | 3306 | root/root123 |
| MySQL Cluster | `mysql-cluster/` | 3316-3318 | root/root123 |
| MongoDB | `mongodb/` | 27017 | root/root123 |
| MongoDB Cluster | `mongodb-cluster/` | 27017-27019 | root/root123 |
| MinIO | `minio/` | 9000/9001 | admin/admin123456 |
| Elasticsearch | `elasticsearch/` | 9200 | - |
| ClickHouse | `clickhouse/` | 8123/9000 | default/clickhouse123 |
| ClickHouse Cluster | `clickhouse-cluster/` | 8123-8126 | default/clickhouse123 |

### 消息队列

| 服务 | 目录 | 端口 | 说明 |
|------|------|------|------|
| Kafka | `kafka/` | 9094 | 单节点 |
| Kafka Cluster | `kafka-cluster/` | 9192-9194 | 3 节点 + UI(8088) |
| RabbitMQ | `rabbitmq/` | 5672/15672 | admin/admin123 |

### 服务治理

| 服务 | 目录 | 端口 | 说明 |
|------|------|------|------|
| etcd | `etcd/` | 2379 | 服务发现/配置中心 |
| DTM | `dtm/` | 36789/36790 | 分布式事务 |
| Nginx | `nginx/` | 80/443 | 反向代理/网关 |

### 可观测性

| 服务 | 目录 | 端口 | 说明 |
|------|------|------|------|
| Jaeger | `jaeger/` | 16686 | 链路追踪 |
| Prometheus | `prometheus/` | 9090 | 指标采集 |
| Grafana | `grafana/` | 3000 | 监控面板 (admin/admin123) |
| Kibana | `kibana/` | 5601 | 日志可视化 |

### DevOps

| 服务 | 目录 | 端口 | 说明 |
|------|------|------|------|
| GitLab | `gitlab/` | 8929/2224/5050 | 代码托管+CI/CD |
| Registry | `registry/` | 5000/8080 | 镜像仓库 |
| ArgoCD | `argocd/` | 8443 | GitOps |
| Kind | `kind/` | - | 本地 K8s |
| Minikube | `minikube/` | - | 本地 K8s |
| Helm | `helm/` | - | K8s 包管理 |

### 开发环境

| 服务 | 目录 | 说明 |
|------|------|------|
| Go Dev | `go-dev/` | Docker 化 Go 开发环境 |

### 项目模板

| 模板 | 目录 | 说明 |
|------|------|------|
| Go-Zero | `templates/go-zero/` | 微服务框架模板 |
| Gin | `templates/gin/` | Web 框架模板 |

---

## 快速开始

```bash
# 克隆仓库
git clone <repo-url> docker-dev-env
cd docker-dev-env

# 首次使用：创建统一网络（服务间通过容器名互访）
./network-setup.sh

# 启动基础服务
cd redis && docker-compose up -d
cd ../mysql && docker-compose up -d
cd ../mongodb && docker-compose up -d
cd ../etcd && docker-compose up -d

# 启动可观测性
cd ../jaeger && docker-compose up -d
cd ../prometheus && docker-compose up -d
cd ../grafana && docker-compose up -d

# 启动消息队列
cd ../kafka && docker-compose up -d
# 或集群版
cd ../kafka-cluster && ./setup.sh

# 启动 K8s（可选）
cd ../kind && ./setup.sh
```

---

## 集群版启动

```bash
# Redis Cluster（6 节点）
cd redis-cluster && ./setup.sh

# MySQL Cluster（1主2从）
cd mysql-cluster && ./setup.sh

# MongoDB Cluster（3 节点副本集）
cd mongodb-cluster && ./setup.sh

# Kafka Cluster（3 节点）
cd kafka-cluster && ./setup.sh

# ClickHouse 单机版
cd clickhouse && ./setup.sh

# ClickHouse Cluster（2分片×2副本）
cd clickhouse-cluster && ./setup.sh
```

---

## Go 开发环境（无需本地安装 Go）

```bash
# 构建开发环境镜像
cd go-dev && ./setup.sh

# 方式1：进入交互式开发环境
PROJECT_PATH=/path/to/your/project docker-compose run --rm go-dev bash

# 方式2：启动后台容器
PROJECT_PATH=/path/to/your/project docker-compose up -d go-dev
docker exec -it go-dev bash

# 方式3：热重载开发（需要 .air.toml）
PROJECT_PATH=/path/to/your/project docker-compose --profile air up go-dev-air

# 快捷命令（添加到 ~/.bashrc 或 ~/.zshrc）
alias godev='docker run --rm -it -v $(pwd):/app -v go-mod-cache:/go/pkg/mod -w /app go-dev:1.25 bash'
alias gobuild='docker run --rm -v $(pwd):/app -v go-mod-cache:/go/pkg/mod -w /app go-dev:1.25 go build -o ./bin/app .'
alias gotest='docker run --rm -v $(pwd):/app -v go-mod-cache:/go/pkg/mod -w /app go-dev:1.25 go test ./...'
alias goctl='docker run --rm -v $(pwd):/app -w /app go-dev:1.25 goctl'
```

**容器内已安装的工具：**
- go 1.25、air（热重载）、goctl（go-zero）、swag（Swagger）
- protoc、protoc-gen-go、protoc-gen-go-grpc
- golangci-lint、gopls、dlv（调试器）

---

## 项目模板使用

```bash
# 复制到你的项目
cp -r templates/go-zero/* /path/to/your/project/
cp -r templates/gin/* /path/to/your/project/

# 常用命令
make dev          # 热重载开发
make docker-build # 构建镜像
make k8s-deploy   # 部署到 K8s
```

---

## 组件常用命令

### 数据存储命令

#### Redis

```bash
# 连接
docker exec -it redis redis-cli

# 常用操作
redis-cli ping                      # 测试连接
redis-cli info                      # 查看信息
redis-cli keys '*'                  # 查看所有 key
redis-cli get <key>                 # 获取值
redis-cli set <key> <value>         # 设置值
redis-cli del <key>                 # 删除 key
redis-cli flushall                  # 清空所有数据
```

#### Redis Cluster

```bash
# 连接（需要 -c 参数）
docker exec -it redis-1 redis-cli -c -p 6371

# 集群操作
redis-cli -c cluster info           # 集群信息
redis-cli -c cluster nodes          # 节点列表
redis-cli -c cluster slots          # 槽分布
```

#### MySQL

```bash
# 连接
docker exec -it mysql mysql -uroot -proot123

# 常用操作
mysql> SHOW DATABASES;
mysql> USE <database>;
mysql> SHOW TABLES;
mysql> DESCRIBE <table>;
mysql> SELECT * FROM <table> LIMIT 10;

# 命令行直接执行
docker exec -it mysql mysql -uroot -proot123 -e "SHOW DATABASES;"

# 导入 SQL 文件
docker exec -i mysql mysql -uroot -proot123 <database> < backup.sql

# 导出数据库
docker exec mysql mysqldump -uroot -proot123 <database> > backup.sql
```

#### MySQL Cluster

```bash
# 连接主节点
docker exec -it mysql-master mysql -uroot -proot123

# 检查主从状态
docker exec mysql-slave-1 mysql -uroot -proot123 -e "SHOW REPLICA STATUS\G"
```

#### MongoDB

```bash
# 连接
docker exec -it mongodb mongosh -u root -p root123

# 常用操作
> show dbs
> use <database>
> show collections
> db.<collection>.find().limit(10)
> db.<collection>.insertOne({name: "test"})
> db.<collection>.deleteMany({})

# 命令行直接执行
docker exec mongodb mongosh -u root -p root123 --eval "show dbs"

# 导出数据库
docker exec mongodb mongodump -u root -p root123 --out /data/backup

# 导入数据库
docker exec mongodb mongorestore -u root -p root123 /data/backup
```

#### Elasticsearch

```bash
# 查看集群健康状态
curl http://localhost:9200/_cluster/health?pretty

# 查看所有索引
curl http://localhost:9200/_cat/indices?v

# 创建索引
curl -X PUT http://localhost:9200/my-index

# 删除索引
curl -X DELETE http://localhost:9200/my-index

# 查看索引 mapping
curl http://localhost:9200/my-index/_mapping?pretty

# 搜索
curl http://localhost:9200/my-index/_search?pretty
```

#### ClickHouse

```bash
# 连接
docker exec -it clickhouse clickhouse-client -u default --password clickhouse123

# 常用操作
:) SHOW DATABASES;
:) USE <database>;
:) SHOW TABLES;
:) SELECT * FROM <table> LIMIT 10;

# HTTP 接口查询
curl "http://localhost:8123/?query=SHOW%20DATABASES"
```

#### MinIO

```bash
# Web 控制台
open http://localhost:9001  # admin/admin123456

# 使用 mc 客户端
docker exec minio mc alias set local http://localhost:9000 admin admin123456
docker exec minio mc ls local/
docker exec minio mc mb local/my-bucket
docker exec minio mc cp /path/to/file local/my-bucket/
```

---

### 消息队列命令

#### Kafka

```bash
# 创建 Topic
docker exec kafka kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --topic test-topic \
  --partitions 3 \
  --replication-factor 1

# 查看 Topic 列表
docker exec kafka kafka-topics.sh --list --bootstrap-server localhost:9092

# 查看 Topic 详情
docker exec kafka kafka-topics.sh --describe \
  --bootstrap-server localhost:9092 \
  --topic test-topic

# 生产消息
docker exec -it kafka kafka-console-producer.sh \
  --bootstrap-server localhost:9092 \
  --topic test-topic

# 消费消息
docker exec -it kafka kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic test-topic \
  --from-beginning

# 查看消费组
docker exec kafka kafka-consumer-groups.sh --list --bootstrap-server localhost:9092
```

#### RabbitMQ

```bash
# 查看队列
docker exec rabbitmq rabbitmqctl list_queues

# 查看交换机
docker exec rabbitmq rabbitmqctl list_exchanges

# 查看连接
docker exec rabbitmq rabbitmqctl list_connections

# 查看消费者
docker exec rabbitmq rabbitmqctl list_consumers

# Web 管理界面
open http://localhost:15672  # admin/admin123
```

---

### 服务治理命令

#### etcd

```bash
# 连接
docker exec -it etcd etcdctl

# 常用操作
etcdctl put /key "value"            # 设置值
etcdctl get /key                    # 获取值
etcdctl get --prefix /              # 获取所有
etcdctl del /key                    # 删除
etcdctl watch /key                  # 监听变化

# 查看集群状态
etcdctl endpoint health
etcdctl member list
```

---

### 可观测性命令

#### Prometheus

```bash
# Web UI
open http://localhost:9090

# 查看 targets 状态
curl http://localhost:9090/api/v1/targets

# 查询指标
curl "http://localhost:9090/api/v1/query?query=up"

# 重新加载配置
curl -X POST http://localhost:9090/-/reload
```

#### Grafana

```bash
# Web UI
open http://localhost:3000  # admin/admin123

# API 示例
curl -u admin:admin123 http://localhost:3000/api/datasources
```

#### Jaeger

```bash
# Web UI
open http://localhost:16686

# 查询服务
curl http://localhost:16686/api/services

# 查询 traces
curl "http://localhost:16686/api/traces?service=my-service&limit=10"
```

---

### Docker 通用命令

```bash
# 查看运行中的容器
docker ps

# 查看所有容器
docker ps -a

# 查看容器日志
docker logs -f <container>

# 进入容器
docker exec -it <container> sh

# 重启容器
docker restart <container>

# 停止所有容器
docker stop $(docker ps -q)

# 删除所有停止的容器
docker container prune

# 查看容器资源使用
docker stats

# 查看网络
docker network ls

# 查看磁盘使用
docker system df
```

---

## 网络说明

### network-setup.sh

根目录下的 `network-setup.sh` 脚本用于创建统一的 Docker 网络 `dev-net`，使所有容器可以通过服务名互相访问。

```bash
# 首次使用必须执行（只需执行一次）
./network-setup.sh
```

**作用：**
- 创建名为 `dev-net` 的 Docker bridge 网络
- 所有服务的 docker-compose.yml 都已配置加入此网络
- 容器间可直接用服务名通信（如 `mysql:3306`），无需 IP

**手动操作（等效命令）：**
```bash
# 创建网络
docker network create dev-net

# 查看网络
docker network ls

# 查看网络中的容器
docker network inspect dev-net
```

### 访问方式

所有服务已加入 `dev-net` 统一网络，支持两种访问方式：

| 场景 | 地址 | 示例 |
|------|------|------|
| 宿主机访问 | localhost:port | `localhost:3306` |
| 容器间访问 | 服务名:port | `mysql:3306` |

```go
// Go 代码示例（容器内）
db, _ := gorm.Open(mysql.Open("root:root123@tcp(mysql:3306)/app"))
rdb := redis.NewClient(&redis.Options{Addr: "redis:6379"})
```

---

## 常见问题

### 1. 镜像拉取慢

**方案一：配置镜像加速器（推荐）**

macOS / Windows (Docker Desktop): Settings → Docker Engine

```json
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me"
  ]
}
```

Linux:
```bash
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me"
  ]
}
EOF
sudo systemctl daemon-reload && sudo systemctl restart docker
```

**方案二：配置 Docker 代理**

macOS / Windows: Docker Desktop → Settings → Resources → Proxies

Linux:
```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF
sudo systemctl daemon-reload && sudo systemctl restart docker
```

**方案三：手动使用镜像代理**
```bash
docker pull docker.1ms.run/library/mysql:8.0
docker tag docker.1ms.run/library/mysql:8.0 mysql:8.0
```

### 2. 端口被占用

```bash
# 查看端口占用
lsof -i :3306

# 修改映射端口（在 docker-compose.yml 中）
ports:
  - "3307:3306"
```

### 3. 磁盘空间不足

```bash
# 查看 Docker 占用
docker system df

# 清理未使用资源
docker system prune -a
docker volume prune
docker builder prune -a
```

### 4. 容器时区不对

已在所有服务中配置 `TZ: Asia/Shanghai`，如仍有问题：
```yaml
environment:
  TZ: Asia/Shanghai
volumes:
  - /etc/localtime:/etc/localtime:ro
```

### 5. MySQL 连接被拒绝

```bash
# Host is not allowed to connect
docker exec -it mysql mysql -uroot -proot123 -e \
  "CREATE USER 'root'@'%' IDENTIFIED BY 'root123'; \
   GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'; \
   FLUSH PRIVILEGES;"
```

### 6. 容器间网络不通

```bash
# 确认网络已创建
./network-setup.sh

# 检查容器网络
docker network inspect dev-net

# 容器内测试
docker exec -it go-dev ping mysql
```

### 7. 日志文件过大

在 Docker Desktop → Settings → Docker Engine 添加：
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

### 常用镜像加速地址

| 加速器 | 地址 |
|--------|------|
| 1ms | https://docker.1ms.run |
| DaoCloud | https://docker.m.daocloud.io |
| 玄元 | https://docker.xuanyuan.me |

> 更多问题请查看 [docs/FAQ.md](docs/FAQ.md)
