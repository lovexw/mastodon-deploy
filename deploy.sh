#!/bin/bash

# 快速部署脚本 - 从GitHub获取文件并部署
# 使用方法: curl -sSL https://raw.githubusercontent.com/your-username/mastodon-deploy/main/deploy.sh | bash

set -e

echo "=== Mastodon 快速部署脚本 ==="
echo "正在从GitHub获取最新的部署文件..."

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本"
    exit 1
fi

# 创建临时目录
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

# 下载部署文件
echo "下载部署文件..."
curl -sSL -o install.sh https://raw.githubusercontent.com/lovexw/mastodon-deploy/main/install.sh
curl -sSL -o README.md https://raw.githubusercontent.com/lovexw/mastodon-deploy/main/README.md
curl -sSL -o low-memory-tips.md https://raw.githubusercontent.com/lovexw/mastodon-deploy/main/low-memory-tips.md

# 设置执行权限
chmod +x install.sh

echo "文件下载完成，开始部署..."
echo ""

# 获取用户输入
echo "请输入你的域名 (例如: social.example.com): "
read DOMAIN
if [ -z "$DOMAIN" ]; then
    echo "域名不能为空"
    exit 1
fi

echo "请输入管理员邮箱: "
read ADMIN_EMAIL
if [ -z "$ADMIN_EMAIL" ]; then
    echo "邮箱不能为空"
    exit 1
fi

# 将参数传递给安装脚本
export DOMAIN
export ADMIN_EMAIL

# 运行安装脚本
bash install.sh

# 清理临时文件
cd /
rm -rf $TEMP_DIR

echo "部署完成！"