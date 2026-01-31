# 项目模板

## 使用方法

```bash
# 复制到你的项目
cp -r templates/go-zero/* /path/to/your/project/
cp -r templates/gin/* /path/to/your/project/
```

---

## Go-Zero 模板

适用于 go-zero 微服务框架。

```
templates/go-zero/
├── Dockerfile              # 生产镜像
├── Dockerfile.dev          # 开发镜像（热重载）
├── docker-compose.yml      # 本地开发
├── docker-compose.prod.yml # 生产构建
├── .air.toml               # 热重载配置
├── .gitlab-ci.yml          # CI/CD
├── Makefile
└── deploy/k8s/             # K8s 部署
```

---

## Gin 模板

适用于 Gin Web 框架。

```
templates/gin/
├── Dockerfile              # 生产镜像
├── Dockerfile.dev          # 开发镜像（热重载）
├── docker-compose.yml      # 本地开发
├── .air.toml               # 热重载配置
├── .gitlab-ci.yml          # CI/CD
├── Makefile
└── deploy/k8s/             # K8s 部署
```

---

## 常用命令

```bash
make dev          # 热重载开发
make build        # 编译
make test         # 测试
make docker-build # 构建镜像
make docker-push  # 推送镜像
make k8s-deploy   # 部署到 K8s
```
