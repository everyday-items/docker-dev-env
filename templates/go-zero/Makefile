# Go-Zero 项目 Makefile

.PHONY: all build run test clean docker help

# 变量
APP_NAME := go-zero-api
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME := $(shell date +%Y-%m-%d_%H:%M:%S)
REGISTRY := localhost:5000
IMAGE := $(REGISTRY)/$(APP_NAME):$(VERSION)

# Go 编译参数
LDFLAGS := -ldflags "-s -w -X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME)"

# 默认目标
all: build

# 编译
build:
	@echo "Building $(APP_NAME)..."
	go build $(LDFLAGS) -o bin/$(APP_NAME) ./cmd/api/main.go

# 运行
run:
	go run ./cmd/api/main.go -f etc/config.yaml

# 热重载运行（需要安装 air）
dev:
	air -c .air.toml

# 测试
test:
	go test -v -race -cover ./...

# 代码检查
lint:
	golangci-lint run

# 生成代码（go-zero goctl）
gen:
	goctl api go -api api/*.api -dir . -style goZero
	goctl model mysql ddl -src sql/*.sql -dir internal/model -style goZero

# 清理
clean:
	rm -rf bin/ tmp/

# ============ Docker ============

# 构建镜像
docker-build:
	docker build -t $(IMAGE) .
	docker tag $(IMAGE) $(REGISTRY)/$(APP_NAME):latest

# 推送镜像
docker-push: docker-build
	docker push $(IMAGE)
	docker push $(REGISTRY)/$(APP_NAME):latest

# 本地运行
docker-run:
	docker-compose up -d

# 停止
docker-stop:
	docker-compose down

# 查看日志
docker-logs:
	docker-compose logs -f

# ============ K8s ============

# 部署到 K8s
k8s-deploy:
	kubectl apply -f deploy/k8s/

# 删除部署
k8s-delete:
	kubectl delete -f deploy/k8s/

# 查看状态
k8s-status:
	kubectl get pods -l app=$(APP_NAME)
	kubectl get svc -l app=$(APP_NAME)

# 查看日志
k8s-logs:
	kubectl logs -f -l app=$(APP_NAME)

# ============ 帮助 ============
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build        编译项目"
	@echo "  run          运行项目"
	@echo "  dev          热重载运行"
	@echo "  test         运行测试"
	@echo "  lint         代码检查"
	@echo "  gen          生成代码"
	@echo "  clean        清理构建文件"
	@echo ""
	@echo "  docker-build 构建 Docker 镜像"
	@echo "  docker-push  推送镜像到仓库"
	@echo "  docker-run   本地 Docker 运行"
	@echo "  docker-stop  停止 Docker 容器"
	@echo ""
	@echo "  k8s-deploy   部署到 K8s"
	@echo "  k8s-delete   从 K8s 删除"
	@echo "  k8s-status   查看 K8s 状态"
	@echo "  k8s-logs     查看 K8s 日志"
