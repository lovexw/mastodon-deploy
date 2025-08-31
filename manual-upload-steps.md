# 手动上传到GitHub步骤

## 方法一：使用Git命令行

### 1. 在当前目录运行以下命令：

```bash
# 初始化Git仓库
git init
git branch -M main

# 添加远程仓库
git remote add origin https://github.com/lovexw/mastodon-deploy.git

# 添加所有文件
git add .

# 提交文件
git commit -m "Initial commit: Mastodon deployment scripts"

# 推送到GitHub
git push -u origin main
```

### 2. 如果需要输入GitHub凭据：
- 用户名：lovexw
- 密码：使用Personal Access Token（不是GitHub密码）

## 方法二：使用GitHub网页界面

### 1. 访问你的仓库
https://github.com/lovexw/mastodon-deploy

### 2. 点击"uploading an existing file"

### 3. 拖拽或选择以下文件上传：
- install.sh
- deploy.sh
- README.md
- low-memory-tips.md
- quick-start.md
- github-setup.md
- DEPLOY.md
- LICENSE
- .gitignore
- upload-to-github.sh
- manual-upload-steps.md

### 4. 填写提交信息：
```
Initial commit: Mastodon deployment scripts

- Complete deployment solution for 1GB VPS
- One-click deployment script
- Chinese language support
- Memory optimization included
```

### 5. 点击"Commit changes"

## 方法三：使用自动脚本

运行我创建的自动上传脚本：

```bash
chmod +x upload-to-github.sh
./upload-to-github.sh
```

## 上传完成后

验证文件是否上传成功：
1. 访问 https://github.com/lovexw/mastodon-deploy
2. 确认所有文件都在仓库中
3. 测试部署命令：
   ```bash
   curl -sSL https://raw.githubusercontent.com/lovexw/mastodon-deploy/main/deploy.sh | sudo bash
   ```

## 需要的文件清单

确保以下文件都上传了：
- ✅ install.sh
- ✅ deploy.sh  
- ✅ README.md
- ✅ low-memory-tips.md
- ✅ quick-start.md
- ✅ github-setup.md
- ✅ DEPLOY.md
- ✅ LICENSE
- ✅ .gitignore