# Gin 项目模板

## 快速开始

```bash
# 本地运行
make run

# 热重载开发
make dev

# Docker 运行
make docker-run
```

## 目录结构

```
.
├── cmd/
│   └── main.go              # 入口
├── internal/
│   ├── handler/             # 路由处理
│   ├── middleware/          # 中间件
│   ├── model/               # 数据模型
│   ├── service/             # 业务逻辑
│   └── repository/          # 数据访问
├── config/
│   └── config.yaml          # 配置文件
├── deploy/k8s/              # K8s 部署
├── Dockerfile
├── docker-compose.yml
├── .gitlab-ci.yml
└── Makefile
```

## 构建部署

```bash
# 构建镜像
make docker-build

# 部署到 K8s
make k8s-deploy
```
