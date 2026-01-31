# Go-Zero 项目模板

## 快速开始

### 本地开发

```bash
# 方式1: 直接运行
make run

# 方式2: 热重载
make dev

# 方式3: Docker Compose
make docker-run
```

### 构建镜像

```bash
# 构建
make docker-build

# 构建并推送
make docker-push
```

### 部署到 K8s

```bash
# 部署
make k8s-deploy

# 查看状态
make k8s-status

# 查看日志
make k8s-logs
```

## 目录结构

```
.
├── cmd/
│   └── api/
│       └── main.go          # 入口文件
├── internal/
│   ├── config/              # 配置
│   ├── handler/             # HTTP 处理器
│   ├── logic/               # 业务逻辑
│   ├── svc/                 # 服务上下文
│   └── types/               # 类型定义
├── etc/
│   └── config.yaml          # 配置文件
├── deploy/
│   └── k8s/                 # K8s 部署文件
├── Dockerfile               # 生产镜像
├── Dockerfile.dev           # 开发镜像
├── docker-compose.yml       # 本地开发
├── .gitlab-ci.yml           # CI/CD
├── Makefile                 # 常用命令
└── README.md
```

## 配置

### 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `MYSQL_HOST` | MySQL 地址 | localhost |
| `REDIS_HOST` | Redis 地址 | localhost |
| `ETCD_HOST` | etcd 地址 | localhost:2379 |

### 端口

| 端口 | 说明 |
|------|------|
| 8080 | HTTP 服务 |
| 9081 | Prometheus 指标 |

## CI/CD

提交到 `main` 分支自动触发：
1. 运行测试
2. 构建镜像
3. 部署到开发环境

打 Tag 触发生产部署（手动确认）。
