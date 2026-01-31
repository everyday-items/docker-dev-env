#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== GitLab 安装脚本 ===${NC}"

# 检查内存
TOTAL_MEM=$(sysctl -n hw.memsize 2>/dev/null || free -b | awk '/^Mem:/{print $2}')
TOTAL_MEM_GB=$((TOTAL_MEM / 1024 / 1024 / 1024))

if [ "$TOTAL_MEM_GB" -lt 8 ]; then
    echo -e "${YELLOW}警告: 系统内存 ${TOTAL_MEM_GB}GB，建议 8GB 以上${NC}"
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 创建数据目录
mkdir -p data/config data/logs data/data

# 启动 GitLab
echo -e "${YELLOW}正在启动 GitLab（首次启动需要 3-5 分钟）...${NC}"
docker-compose up -d

echo ""
echo -e "${YELLOW}等待 GitLab 启动...${NC}"
echo "可以运行以下命令查看日志："
echo "  docker logs -f gitlab"
echo ""

# 等待健康检查通过
MAX_WAIT=300
WAIT=0
while [ $WAIT -lt $MAX_WAIT ]; do
    if docker exec gitlab curl -sf http://localhost:80/-/health > /dev/null 2>&1; then
        break
    fi
    echo -n "."
    sleep 10
    WAIT=$((WAIT + 10))
done
echo ""

if [ $WAIT -ge $MAX_WAIT ]; then
    echo -e "${YELLOW}GitLab 仍在启动中，请稍后访问${NC}"
else
    echo -e "${GREEN}GitLab 已就绪！${NC}"
fi

# 获取 root 初始密码
echo ""
echo -e "${GREEN}=== GitLab 安装完成 ===${NC}"
echo ""
echo "访问地址: http://localhost:8929"
echo ""
echo "初始账号: root"
echo "初始密码: 运行以下命令获取"
echo "  docker exec gitlab grep 'Password:' /etc/gitlab/initial_root_password"
echo ""
echo "（初始密码 24 小时后过期，请及时修改）"
echo ""
echo "SSH 克隆: ssh://git@localhost:2224/username/repo.git"
echo "镜像仓库: localhost:5050"
echo ""
echo "数据存储位置: ./data/"
echo "  - ./data/data    代码仓库数据"
echo "  - ./data/config  配置文件"
echo "  - ./data/logs    日志文件"
