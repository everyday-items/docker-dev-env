#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=== Go 开发环境启动脚本 ===${NC}"

# 构建镜像
echo -e "${YELLOW}构建 Go 开发环境镜像...${NC}"
docker-compose build

echo ""
echo -e "${GREEN}=== Go 开发环境准备完成 ===${NC}"
echo ""
echo -e "${BLUE}使用方式：${NC}"
echo ""
echo "1. 进入交互式开发环境："
echo "   ${YELLOW}cd go-dev && PROJECT_PATH=/path/to/your/project docker-compose run --rm go-dev bash${NC}"
echo ""
echo "2. 启动后台开发容器："
echo "   ${YELLOW}cd go-dev && PROJECT_PATH=/path/to/your/project docker-compose up -d go-dev${NC}"
echo "   ${YELLOW}docker exec -it go-dev bash${NC}"
echo ""
echo "3. 使用热重载开发（需要 .air.toml）："
echo "   ${YELLOW}cd go-dev && PROJECT_PATH=/path/to/your/project docker-compose --profile air up go-dev-air${NC}"
echo ""
echo "4. 快捷命令（添加到 ~/.bashrc 或 ~/.zshrc）："
cat << 'EOF'

# Go Docker 开发环境
alias godev='docker run --rm -it -v $(pwd):/app -v go-mod-cache:/go/pkg/mod -w /app go-dev:1.22 bash'
alias gofmt='docker run --rm -v $(pwd):/app -w /app go-dev:1.22 gofmt -w .'
alias gotest='docker run --rm -v $(pwd):/app -v go-mod-cache:/go/pkg/mod -w /app go-dev:1.22 go test ./...'
alias gobuild='docker run --rm -v $(pwd):/app -v go-mod-cache:/go/pkg/mod -w /app go-dev:1.22 go build -o ./bin/app .'
alias goctl='docker run --rm -v $(pwd):/app -w /app go-dev:1.22 goctl'
alias swag='docker run --rm -v $(pwd):/app -w /app go-dev:1.22 swag'
alias golint='docker run --rm -v $(pwd):/app -v go-mod-cache:/go/pkg/mod -w /app go-dev:1.22 golangci-lint run'

EOF
echo ""
echo -e "${BLUE}容器内已安装的工具：${NC}"
echo "  - go 1.22"
echo "  - air          (热重载)"
echo "  - goctl        (go-zero 代码生成)"
echo "  - swag         (Swagger 文档生成)"
echo "  - protoc       (Protobuf 编译)"
echo "  - protoc-gen-go / protoc-gen-go-grpc"
echo "  - golangci-lint (代码检查)"
echo "  - gopls        (LSP 服务)"
echo "  - dlv          (调试器)"
echo ""
echo -e "${BLUE}示例命令（容器内）：${NC}"
echo "  go mod init myproject    # 初始化项目"
echo "  go mod tidy              # 整理依赖"
echo "  go run main.go           # 运行"
echo "  go build -o app .        # 编译"
echo "  go test ./...            # 测试"
echo "  air                      # 热重载开发"
echo "  goctl api new myapi      # 创建 go-zero API"
echo "  swag init                # 生成 Swagger 文档"
echo ""
