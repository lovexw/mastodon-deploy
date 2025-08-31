#!/bin/bash

# 上传到GitHub的脚本
# 使用方法: ./upload-to-github.sh

echo "=== 准备上传到GitHub ==="

# 检查是否已经初始化git
if [ ! -d ".git" ]; then
    echo "初始化Git仓库..."
    git init
    git branch -M main
fi

# 添加远程仓库
echo "添加远程仓库..."
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/lovexw/mastodon-deploy.git

# 添加所有文件
echo "添加文件到Git..."
git add .

# 提交
echo "提交文件..."
git commit -m "Initial commit: Mastodon deployment scripts for 1GB VPS

- install.sh: Main installation script optimized for 1GB memory
- deploy.sh: One-click deployment script
- README.md: Complete deployment guide
- low-memory-tips.md: 1GB memory optimization guide
- quick-start.md: Quick start guide
- DEPLOY.md: Immediate deployment instructions
- LICENSE: MIT license
- .gitignore: Git ignore rules"

# 推送到GitHub
echo "推送到GitHub..."
git push -u origin main

echo ""
echo "=== 上传完成！ ==="
echo "仓库地址: https://github.com/lovexw/mastodon-deploy"
echo ""
echo "现在可以在服务器上运行部署命令："
echo "curl -sSL https://raw.githubusercontent.com/lovexw/mastodon-deploy/main/deploy.sh | sudo bash"