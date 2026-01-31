# Docker 常见问题及解决方案

## 1. 镜像拉取慢 / 被墙

### 方案一：配置镜像加速器（推荐）

编辑 Docker 配置文件：

**macOS / Windows (Docker Desktop)**:
Settings → Docker Engine，添加：

```json
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me",
    "https://docker.m.daocloud.io"
  ]
}
```

**Linux**:
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me",
    "https://docker.m.daocloud.io"
  ]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 方案二：配置 Docker 代理

**macOS / Windows (Docker Desktop)**:
Settings → Resources → Proxies，配置 HTTP/HTTPS 代理

**Linux**:
```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
Environment="NO_PROXY=localhost,127.0.0.1,docker-registry.example.com"
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 方案三：手动指定镜像源

拉取镜像时使用代理前缀：
```bash
# 原始命令
docker pull mysql:8.0

# 使用代理
docker pull docker.1ms.run/library/mysql:8.0
docker tag docker.1ms.run/library/mysql:8.0 mysql:8.0
```

---

## 2. docker-compose 拉取镜像失败

在 docker-compose.yml 中直接使用镜像代理：

```yaml
services:
  mysql:
    # 原始
    # image: mysql:8.0
    # 使用代理
    image: docker.1ms.run/library/mysql:8.0
```

或者先手动拉取再启动：
```bash
docker pull docker.1ms.run/library/mysql:8.0
docker tag docker.1ms.run/library/mysql:8.0 mysql:8.0
docker-compose up -d
```

---

## 3. 容器无法访问外网

### 检查 DNS
```bash
# 进入容器测试
docker exec -it <container> sh
ping 8.8.8.8      # 测试网络
nslookup baidu.com # 测试 DNS
```

### 配置 DNS
```json
// Docker Desktop → Settings → Docker Engine
{
  "dns": ["8.8.8.8", "114.114.114.114"]
}
```

或在 docker-compose.yml 中指定：
```yaml
services:
  app:
    dns:
      - 8.8.8.8
      - 114.114.114.114
```

---

## 4. 端口被占用

```bash
# 查看端口占用
lsof -i :3306
netstat -tlnp | grep 3306

# 解决方案1：停止占用进程
kill -9 <PID>

# 解决方案2：修改映射端口
# docker-compose.yml
ports:
  - "3307:3306"  # 改用其他端口
```

---

## 5. 磁盘空间不足

```bash
# 查看 Docker 占用空间
docker system df

# 清理未使用的资源
docker system prune -a

# 清理指定类型
docker image prune -a      # 清理未使用镜像
docker container prune     # 清理停止的容器
docker volume prune        # 清理未使用卷
docker network prune       # 清理未使用网络

# 清理构建缓存
docker builder prune -a
```

---

## 6. 容器时区不对

在 docker-compose.yml 中配置：
```yaml
services:
  app:
    environment:
      TZ: Asia/Shanghai
    volumes:
      - /etc/localtime:/etc/localtime:ro  # Linux
```

---

## 7. 文件权限问题

### 问题：容器内创建的文件宿主机无权访问

```bash
# 查看容器内用户
docker exec <container> id

# 方案1：指定用户运行
docker run -u $(id -u):$(id -g) ...

# 方案2：在 docker-compose.yml 中
services:
  app:
    user: "${UID}:${GID}"
```

### 问题：挂载目录无权限（如 Elasticsearch）

```bash
# 修改目录权限
sudo chown -R 1000:1000 ./data
# 或
chmod 777 ./data
```

---

## 8. 容器间网络不通

```bash
# 检查网络
docker network ls
docker network inspect dev-net

# 确认容器在同一网络
docker inspect <container> | grep -A 20 "Networks"

# 容器内测试连通性
docker exec -it go-dev ping mysql
docker exec -it go-dev nc -zv mysql 3306
```

---

## 9. MySQL 连接被拒绝

### 错误：Host is not allowed to connect

```sql
-- 进入 MySQL 容器
docker exec -it mysql mysql -uroot -proot123

-- 授权远程访问
CREATE USER 'root'@'%' IDENTIFIED BY 'root123';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

### 错误：Authentication plugin 'caching_sha2_password'

```bash
# 方案1：修改认证方式
docker exec -it mysql mysql -uroot -proot123 -e \
  "ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root123';"

# 方案2：使用支持新认证的客户端
```

---

## 10. Docker Desktop 启动慢 / 卡死

### macOS
```bash
# 重置 Docker Desktop
rm -rf ~/Library/Group\ Containers/group.com.docker
rm -rf ~/Library/Containers/com.docker.docker
rm -rf ~/.docker

# 重新安装 Docker Desktop
```

### 减少资源占用
Settings → Resources:
- Memory: 4GB（根据需要调整）
- CPUs: 2-4
- Disk: 60GB

---

## 11. Go 模块下载慢

已在 go-dev 中配置了 GOPROXY：
```yaml
environment:
  GOPROXY: https://goproxy.cn,direct
```

手动配置：
```bash
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GOPRIVATE=*.gitlab.com,*.gitee.com
```

---

## 12. 日志文件过大

```bash
# 查看容器日志大小
docker inspect --format='{{.LogPath}}' <container> | xargs ls -lh

# 清理日志
truncate -s 0 $(docker inspect --format='{{.LogPath}}' <container>)
```

配置日志限制：
```json
// Docker Desktop → Settings → Docker Engine
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

或在 docker-compose.yml 中：
```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

---

## 常用镜像加速地址

| 加速器 | 地址 |
|--------|------|
| 1ms | https://docker.1ms.run |
| DaoCloud | https://docker.m.daocloud.io |
| 玄元 | https://docker.xuanyuan.me |
| 南京大学 | https://ghcr.nju.edu.cn |

> 注意：镜像加速地址可能会变化，如失效请搜索最新可用地址。
