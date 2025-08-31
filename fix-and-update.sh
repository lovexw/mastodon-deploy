#!/bin/bash

echo "=== 修复部署脚本并更新到GitHub ==="

# 提交修复
git add .
git commit -m "Fix: 修复管道模式下无法读取用户输入的问题

- 修改install.sh中的read命令，使用/dev/tty读取输入
- 修改deploy.sh使用bash而不是./运行脚本
- 现在可以正确在管道模式下运行"

# 推送到GitHub
git push origin main

echo ""
echo "=== 修复完成！ ==="
echo "现在可以重新运行部署命令："
echo "curl -sSL https://raw.githubusercontent.com/lovexw/mastodon-deploy/main/deploy.sh | sudo bash"