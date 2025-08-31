# 1GB内存VPS运行Mastodon优化指南

## 重要提醒
1GB内存运行Mastodon比较紧张，但通过优化配置是可以运行的。

## 已做的优化

### 1. 系统级优化
- ✅ 自动创建2GB交换空间
- ✅ 数据库内存参数优化
- ✅ Redis内存限制设置

### 2. 应用级优化
- ✅ 减少Web进程并发数 (WEB_CONCURRENCY=1)
- ✅ 减少线程数 (MAX_THREADS=2)
- ✅ 限制Sidekiq线程 (SIDEKIQ_THREADS=2)
- ✅ 设置容器内存限制

### 3. 数据库优化
- ✅ PostgreSQL内存参数调优
- ✅ 减少共享内存使用
- ✅ 优化检查点和WAL设置

## 部署后的额外优化

### 1. 监控内存使用
```bash
# 查看内存使用情况
free -h
htop

# 查看容器内存使用
docker stats
```

### 2. 如果内存不够用
可以进一步优化：

```bash
cd /opt/mastodon

# 编辑环境变量
nano .env.production
```

添加更严格的内存限制：
```
# 更严格的内存控制
RUBY_GC_HEAP_INIT_SLOTS=5000
RUBY_GC_HEAP_FREE_SLOTS=2000
RUBY_GC_HEAP_GROWTH_FACTOR=1.05
```

### 3. 定期清理
```bash
# 清理旧的媒体文件 (保留7天)
docker-compose run --rm web bin/tootctl media remove --days=7

# 清理预览卡片
docker-compose run --rm web bin/tootctl preview_cards remove --days=7

# 清理Docker镜像
docker system prune -f
```

### 4. 关闭不必要的功能
在 `.env.production` 中添加：
```
# 禁用全文搜索 (节省内存)
ES_ENABLED=false

# 禁用预览卡片生成
PREVIEW_CARDS=false

# 减少媒体处理
MAX_IMAGE_SIZE=2097152
MAX_VIDEO_SIZE=10485760
```

## 性能预期

### 正常情况下
- 🟢 支持 50-100 并发用户
- 🟢 响应时间 < 2秒
- 🟢 基本功能正常

### 高峰期可能出现
- 🟡 响应变慢 (3-5秒)
- 🟡 偶尔需要重启服务
- 🟡 媒体上传较慢

## 故障处理

### 内存不足导致服务崩溃
```bash
# 重启所有服务
cd /opt/mastodon
docker-compose restart

# 如果数据库启动失败
docker-compose restart db
sleep 30
docker-compose restart web streaming sidekiq
```

### 交换空间使用过多
```bash
# 清理交换空间
swapoff -a && swapon -a

# 调整交换空间使用策略
echo 'vm.swappiness=10' >> /etc/sysctl.conf
sysctl -p
```

## 升级建议

如果用户增长到500+人，强烈建议升级到：
- **2核2GB内存** (最低推荐)
- **2核4GB内存** (舒适运行)

## 监控脚本

创建简单的监控脚本：
```bash
#!/bin/bash
# 保存为 monitor.sh

echo "=== 系统资源使用情况 ==="
free -h
echo ""
echo "=== Docker容器状态 ==="
docker-compose ps
echo ""
echo "=== 内存使用TOP5 ==="
docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}" | head -6
```

定期运行检查：
```bash
chmod +x monitor.sh
./monitor.sh
```

记住：1GB内存是最低配置，如果预算允许，建议升级到2GB内存会有更好的体验！