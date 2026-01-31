#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== MinIO 启动脚本 ===${NC}"

# 创建数据目录
mkdir -p data

# 启动 MinIO
docker-compose up -d

echo ""
echo -e "${GREEN}=== MinIO 启动完成 ===${NC}"
echo ""
echo "控制台: http://localhost:9001"
echo "API:    http://localhost:9000"
echo ""
echo "用户名: admin"
echo "密码:   admin123456"
echo ""
echo "============================================"
echo ""
echo "Go 代码示例:"
echo ""
cat << 'EOF'
import "github.com/minio/minio-go/v7"
import "github.com/minio/minio-go/v7/pkg/credentials"

client, err := minio.New("localhost:9000", &minio.Options{
    Creds:  credentials.NewStaticV4("admin", "admin123456", ""),
    Secure: false,
})

// 创建 bucket
client.MakeBucket(ctx, "my-bucket", minio.MakeBucketOptions{})

// 上传文件
client.FPutObject(ctx, "my-bucket", "file.jpg", "/path/to/file.jpg", minio.PutObjectOptions{})

// 获取文件 URL
url, _ := client.PresignedGetObject(ctx, "my-bucket", "file.jpg", time.Hour, nil)
EOF
echo ""
