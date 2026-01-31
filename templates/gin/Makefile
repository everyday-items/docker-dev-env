# Gin 项目 Makefile

.PHONY: all build run test clean docker help

APP_NAME := gin-api
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
REGISTRY := localhost:5000

# 编译
build:
	go build -ldflags="-s -w" -o bin/$(APP_NAME) ./cmd/main.go

# 运行
run:
	GIN_MODE=debug go run ./cmd/main.go

# 热重载
dev:
	air -c .air.toml

# 测试
test:
	go test -v -race -cover ./...

# 清理
clean:
	rm -rf bin/ tmp/

# Docker
docker-build:
	docker build -t $(REGISTRY)/$(APP_NAME):$(VERSION) .

docker-push: docker-build
	docker push $(REGISTRY)/$(APP_NAME):$(VERSION)

docker-run:
	docker-compose up -d

docker-stop:
	docker-compose down

# K8s
k8s-deploy:
	kubectl apply -f deploy/k8s/

k8s-delete:
	kubectl delete -f deploy/k8s/

# 帮助
help:
	@echo "make build       - 编译"
	@echo "make run         - 运行"
	@echo "make dev         - 热重载开发"
	@echo "make test        - 测试"
	@echo "make docker-build - 构建镜像"
	@echo "make docker-run  - Docker 运行"
	@echo "make k8s-deploy  - K8s 部署"
