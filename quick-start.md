# 🚀 Mastodon 快速部署指南

## 一分钟部署

### 方法一：一键部署（最简单）
```bash
curl -sSL https://raw.githubusercontent.com/lovexw/mastodon-deploy/main/deploy.sh | sudo bash
```

### 方法二：手动部署
```bash
git clone https://github.com/lovexw/mastodon-deploy.git
cd mastodon-deploy
sudo ./install.sh
```

## 部署前准备

1. **服务器要求**
   - Ubuntu 20.04/22.04
   - 1GB+ 内存（推荐2GB）
   - 20GB+ 硬盘空间

2. **域名准备**
   - 在Cloudflare添加域名
   - A记录指向服务器IP
   - 开启代理（橙色云朵）

## 部署过程

脚本会自动完成：
- ✅ 系统更新和软件安装
- ✅ Docker环境配置
- ✅ 创建交换空间（1GB内存优化）
- ✅ Mastodon下载和配置
- ✅ 数据库初始化
- ✅ Nginx反向代理配置
- ✅ SSL证书申请
- ✅ 管理员账户创建

## 部署后

1. 访问你的域名
2. 使用管理员账户登录
3. 进入管理面板进行基础设置

## 常见问题

**Q: 1GB内存够用吗？**
A: 够用，但建议升级到2GB获得更好体验

**Q: 支持多少用户？**
A: 1GB内存支持50-100并发，2100总用户没问题

**Q: 如何备份数据？**
A: 参考README.md中的备份章节

## 获取帮助

- 查看完整文档：[README.md](README.md)
- 1GB内存优化：[low-memory-tips.md](low-memory-tips.md)
- 问题反馈：GitHub Issues