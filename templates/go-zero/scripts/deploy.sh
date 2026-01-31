#!/bin/bash
# 部署脚本

set -e

NAMESPACE=${NAMESPACE:-"default"}
ENV=${1:-"dev"}

echo "Deploying to $ENV environment..."

# 应用配置
kubectl apply -f deploy/k8s/configmap.yaml -n $NAMESPACE
kubectl apply -f deploy/k8s/secret.yaml -n $NAMESPACE
kubectl apply -f deploy/k8s/deployment.yaml -n $NAMESPACE

# 等待部署完成
kubectl rollout status deployment/go-zero-api -n $NAMESPACE

echo "Deployment complete!"
kubectl get pods -l app=go-zero-api -n $NAMESPACE
