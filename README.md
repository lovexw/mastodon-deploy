# Mastodon 部署指南

这是一个用于快速部署 Mastodon 社交平台的完整方案。

## 准备工作

### 1. 服务器要求
- **操作系统**: Ubuntu 20.04 或 22.04
- **配置**: 最低 2核4GB内存，推荐 4核8GB
- **存储**: 至少 40GB SSD
- **网络**: 海外VPS，建议使用 Vultr、DigitalOcean 等

### 2. 域名配置
1. 在 Cloudflare 添加你的域名
2. 将域名的 A 记录指向服务器 IP
3. 开启 Cloudflare 的代理（橙色云朵）

### 3. Cloudflare 优化设置
- **SSL/TLS**: 设置为 "Full (strict)"
- **Speed > Optimization**: 开启 Auto Minify (HTML, CSS, JS)
- **Caching**: 设置缓存级别为 "Standard"
- **Network**: 开启 HTTP/2 和 HTTP/3

## 部署步骤

### 1. 连接服务器
```bash
ssh root@your-server-ip
```

### 2. 一键部署（推荐）
```bash
curl -sSL https://raw.githubusercontent.com/lovexw/mastodon-deploy/main/deploy.sh | sudo bash
```

### 3. 手动部署
如果你想手动控制每一步：
```bash
# 克隆仓库
git clone https://github.com/lovexw/mastodon-deploy.git
cd mastodon-deploy

# 运行安装脚本
sudo ./install.sh
```

按提示输入：
- 域名 (例如: social.example.com)
- 管理员邮箱

### 4. 等待部署完成
整个过程大约需要 10-20 分钟，脚本会自动：
- 安装 Docker 和 Docker Compose
- 下载并配置 Mastodon
- 设置数据库和 Redis
- 配置 Nginx 反向代理
- 申请 SSL 证书
- 创建管理员账户

## 部署后配置

### 1. 首次登录
1. 访问 `https://your-domain.com`
2. 使用管理员邮箱和脚本输出的密码登录
3. 进入 "偏好设置" > "账户" 修改密码

### 2. 基础设置
进入管理面板 (`https://your-domain.com/admin/settings/edit`)：

**站点设置:**
- 站点标题: 你的社区名称
- 站点简介: 社区介绍
- 站点描述: 详细描述
- 联系邮箱: 你的邮箱

**注册设置:**
- 开放注册: 根据需要开启/关闭
- 需要邀请: 可以设置为仅邀请注册

**本地化:**
- 默认语言: 简体中文 (zh-CN)

### 3. 关闭联邦功能（重要）
由于是内部使用，建议关闭联邦功能：

1. 编辑配置文件:
```bash
cd /opt/mastodon
nano .env.production
```

2. 添加以下配置:
```
# 禁用联邦功能
AUTHORIZED_FETCH=true
DISALLOW_UNAUTHENTICATED_API_ACCESS=true
```

3. 重启服务:
```bash
docker-compose restart
```

## 常用管理命令

### 服务管理
```bash
cd /opt/mastodon

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 停止服务
docker-compose down

# 启动服务
docker-compose up -d
```

### 用户管理
```bash
# 创建新用户
docker-compose run --rm web bin/tootctl accounts create username --email user@example.com --confirmed

# 设置用户为管理员
docker-compose run --rm web bin/tootctl accounts modify username --role Admin

# 重置用户密码
docker-compose run --rm web bin/tootctl accounts modify username --reset-password
```

### 数据备份
```bash
# 备份数据库
docker-compose exec db pg_dump -U mastodon mastodon_production > backup.sql

# 备份媒体文件
tar -czf media_backup.tar.gz public/system/
```

## 故障排除

### 1. 服务无法启动
```bash
# 查看详细日志
docker-compose logs web
docker-compose logs db
docker-compose logs redis
```

### 2. 无法访问网站
- 检查防火墙设置: `ufw status`
- 检查 Nginx 状态: `systemctl status nginx`
- 检查 SSL 证书: `certbot certificates`

### 3. 数据库连接错误
```bash
# 重启数据库
docker-compose restart db

# 检查数据库日志
docker-compose logs db
```

### 4. 内存不足
如果服务器内存不足，可以添加交换空间：
```bash
# 创建 2GB 交换文件
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 永久启用
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## 性能优化

### 1. 数据库优化
编辑 `docker-compose.yml`，在 db 服务中添加：
```yaml
command: postgres -c shared_preload_libraries=pg_stat_statements -c pg_stat_statements.track=all -c max_connections=200
```

### 2. Redis 优化
在 `docker-compose.yml` 的 redis 服务中添加：
```yaml
command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
```

### 3. Web 服务优化
在 `.env.production` 中调整：
```
WEB_CONCURRENCY=4
MAX_THREADS=10
STREAMING_CLUSTER_NUM=2
```

## 安全建议

1. **定期更新**: 定期更新 Mastodon 到最新版本
2. **备份**: 定期备份数据库和媒体文件
3. **监控**: 使用 `htop` 或其他工具监控服务器资源
4. **日志**: 定期检查日志文件，发现异常及时处理

## 支持

如果遇到问题，可以：
1. 查看 Mastodon 官方文档: https://docs.joinmastodon.org/
2. 检查服务日志找出具体错误
3. 在 GitHub 上搜索相关问题

---

祝你部署顺利！🎉