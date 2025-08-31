# GitHub 仓库设置指南

## 创建仓库

1. 登录GitHub，创建新仓库
2. 仓库名建议：`mastodon-deploy`
3. 设置为Public（方便直接下载）
4. 添加README.md

## 上传文件

将以下文件上传到GitHub仓库：

```
mastodon-deploy/
├── README.md              # 完整部署指南
├── install.sh             # 主安装脚本
├── deploy.sh              # 一键部署脚本
├── low-memory-tips.md     # 1GB内存优化指南
├── quick-start.md         # 快速开始指南
├── LICENSE                # MIT许可证
├── .gitignore            # Git忽略文件
└── github-setup.md       # 本文件
```

## 使用方法

### 方法一：一键部署
```bash
curl -sSL https://raw.githubusercontent.com/lovexw/mastodon-deploy/main/deploy.sh | sudo bash
```

### 方法二：克隆仓库
```bash
git clone https://github.com/lovexw/mastodon-deploy.git
cd mastodon-deploy
sudo ./install.sh
```

## 修改deploy.sh

上传到GitHub后，需要修改`deploy.sh`中的GitHub链接：

将所有的：
```
https://raw.githubusercontent.com/your-username/mastodon-deploy/main/
```

替换为你的实际GitHub用户名和仓库名。

## 测试部署

上传完成后，在服务器上测试：

```bash
# 测试一键部署
curl -sSL https://raw.githubusercontent.com/lovexw/mastodon-deploy/main/deploy.sh | sudo bash
```

## 仓库描述建议

**仓库描述：**
```
🐘 一键部署Mastodon社交平台 - 支持1GB内存VPS，中文优化，内部社区专用
```

**标签：**
```
mastodon, social-media, docker, deployment, chinese, low-memory
```

## README徽章（可选）

可以在README.md顶部添加：

```markdown
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Ubuntu-orange.svg)
![Memory](https://img.shields.io/badge/memory-1GB+-green.svg)
![Language](https://img.shields.io/badge/language-中文-red.svg)