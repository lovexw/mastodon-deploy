# 🚀 立即部署 Mastodon

## 服务器信息
- **IP地址**: 64.181.224.210
- **配置**: 2核1GB内存
- **系统**: Ubuntu (推荐)

## 一键部署命令

在你的服务器上运行以下命令：

```bash
curl -sSL https://raw.githubusercontent.com/lovexw/mastodon-deploy/main/deploy.sh | sudo bash
```

## 部署过程

脚本会提示你输入：
1. **域名** (例如: social.yourdomain.com)
2. **管理员邮箱** (用于SSL证书和管理员账户)

然后自动完成：
- ✅ 系统更新和软件安装
- ✅ 创建2GB交换空间
- ✅ 安装Docker环境
- ✅ 下载和配置Mastodon
- ✅ 初始化数据库
- ✅ 配置Nginx反向代理
- ✅ 申请SSL证书
- ✅ 创建管理员账户

## 预计时间
整个部署过程大约需要 **15-20分钟**

## 部署完成后
1. 访问你的域名
2. 使用管理员账户登录
3. 进入管理面板进行基础设置

## 如果遇到问题
- 查看详细文档: [README.md](README.md)
- 1GB内存优化: [low-memory-tips.md](low-memory-tips.md)
- 快速指南: [quick-start.md](quick-start.md)

---

**准备好了吗？复制上面的命令到你的服务器运行吧！** 🎉