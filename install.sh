#!/bin/bash

# Mastodon 一键部署脚本 (1GB内存优化版)
# 适用于 Ubuntu 20.04/22.04

set -e

echo "=== Mastodon 一键部署脚本 (1GB内存优化版) ==="
echo "请确保已经将域名解析到此服务器"
echo ""

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本"
    exit 1
fi

# 获取域名和邮箱 (从环境变量或交互输入)
if [ -z "$DOMAIN" ]; then
    echo "请输入你的域名 (例如: social.example.com): "
    read DOMAIN
    if [ -z "$DOMAIN" ]; then
        echo "域名不能为空"
        exit 1
    fi
fi

if [ -z "$ADMIN_EMAIL" ]; then
    echo "请输入管理员邮箱: "
    read ADMIN_EMAIL
    if [ -z "$ADMIN_EMAIL" ]; then
        echo "邮箱不能为空"
        exit 1
    fi
fi

echo "使用域名: $DOMAIN"
echo "管理员邮箱: $ADMIN_EMAIL"
echo ""

echo "=== 更新系统 ==="
apt update && apt upgrade -y

echo "=== 创建交换空间 (1GB内存需要) ==="
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo "交换空间创建完成"
else
    echo "交换空间已存在"
fi

echo "=== 安装必要软件 ==="
apt install -y curl wget git nano ufw htop

echo "=== 安装 Docker ==="
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable docker
    systemctl start docker
    rm get-docker.sh
else
    echo "Docker 已安装"
fi

echo "=== 安装 Docker Compose ==="
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose 已安装"
fi

echo "=== 配置防火墙 ==="
ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable

echo "=== 创建 Mastodon 目录 ==="
mkdir -p /opt/mastodon
cd /opt/mastodon

echo "=== 下载 Mastodon ==="
if [ ! -d ".git" ]; then
    git clone https://github.com/mastodon/mastodon.git .
    git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)
else
    echo "Mastodon 已下载"
fi

echo "=== 生成配置文件 ==="
cp .env.production.sample .env.production

# 生成密钥
echo "生成密钥中..."
SECRET_KEY_BASE=$(openssl rand -hex 64)
OTP_SECRET=$(openssl rand -hex 64)

# 生成 VAPID 密钥
echo "生成 VAPID 密钥中..."
VAPID_PRIVATE_KEY=$(openssl ecparam -genkey -name prime256v1 | openssl pkcs8 -topk8 -nocrypt | base64 -w 0)
VAPID_PUBLIC_KEY=$(echo "$VAPID_PRIVATE_KEY" | base64 -d | openssl ec -pubout | tail -c 65 | base64 -w 0)

echo "=== 配置环境变量 (1GB内存优化) ==="
cat > .env.production << EOF
# 基础配置
LOCAL_DOMAIN=$DOMAIN
SINGLE_USER_MODE=false
SECRET_KEY_BASE=$SECRET_KEY_BASE
OTP_SECRET=$OTP_SECRET

# VAPID 密钥
VAPID_PRIVATE_KEY=$VAPID_PRIVATE_KEY
VAPID_PUBLIC_KEY=$VAPID_PUBLIC_KEY

# 数据库配置
DB_HOST=db
DB_USER=mastodon
DB_NAME=mastodon_production
DB_PASS=mastodon_db_password
DB_PORT=5432

# Redis 配置
REDIS_HOST=redis
REDIS_PORT=6379

# Elasticsearch (禁用以节省内存)
ES_ENABLED=false

# 邮件配置 (暂时禁用)
SMTP_SERVER=
SMTP_PORT=587
SMTP_LOGIN=
SMTP_PASSWORD=
SMTP_FROM_ADDRESS=$ADMIN_EMAIL

# 文件存储
S3_ENABLED=false

# 其他配置 (1GB内存优化)
STREAMING_CLUSTER_NUM=1
WEB_CONCURRENCY=1
MAX_THREADS=2
SIDEKIQ_THREADS=2

# 语言
DEFAULT_LOCALE=zh-CN

# 注册设置
REGISTRATIONS_MODE=open

# 内存优化
MALLOC_ARENA_MAX=2
RUBY_GC_HEAP_GROWTH_FACTOR=1.1
RUBY_GC_HEAP_GROWTH_MAX_SLOTS=10000

# 禁用预览卡片以节省内存
PREVIEW_CARDS=false
EOF

echo "=== 创建 Docker Compose 配置 (1GB内存优化版) ==="
cat > docker-compose.yml << 'EOF'
version: '3'
services:
  db:
    restart: always
    image: postgres:14-alpine
    shm_size: 64mb
    networks:
      - internal_network
    healthcheck:
      test: ['CMD', 'pg_isready', '-U', 'mastodon']
    volumes:
      - ./postgres14:/var/lib/postgresql/data
    environment:
      - 'POSTGRES_HOST_AUTH_METHOD=trust'
      - 'POSTGRES_USER=mastodon'
      - 'POSTGRES_PASSWORD=mastodon_db_password'
      - 'POSTGRES_DB=mastodon_production'
    command: postgres -c shared_buffers=32MB -c effective_cache_size=128MB -c maintenance_work_mem=16MB -c checkpoint_completion_target=0.9 -c wal_buffers=4MB -c default_statistics_target=100 -c random_page_cost=1.1 -c effective_io_concurrency=200 -c work_mem=2MB -c min_wal_size=1GB -c max_wal_size=4GB
    deploy:
      resources:
        limits:
          memory: 200M
        reservations:
          memory: 100M

  redis:
    restart: always
    image: redis:7-alpine
    networks:
      - internal_network
    healthcheck:
      test: ['CMD', 'redis-cli', 'ping']
    volumes:
      - ./redis:/data
    command: redis-server --maxmemory 64mb --maxmemory-policy allkeys-lru --save 900 1 --save 300 10
    deploy:
      resources:
        limits:
          memory: 80M
        reservations:
          memory: 40M

  web:
    build: .
    image: mastodon/mastodon:latest
    restart: always
    env_file: .env.production
    command: bash -c "rm -f /mastodon/tmp/pids/server.pid; bundle exec rails s -p 3000"
    networks:
      - external_network
      - internal_network
    healthcheck:
      test: ['CMD-SHELL', 'wget -q --spider --proxy=off localhost:3000/health || exit 1']
    ports:
      - '127.0.0.1:3000:3000'
    depends_on:
      - db
      - redis
    volumes:
      - ./public/system:/mastodon/public/system
    deploy:
      resources:
        limits:
          memory: 400M
        reservations:
          memory: 200M

  streaming:
    build: .
    image: mastodon/mastodon:latest
    restart: always
    env_file: .env.production
    command: node ./streaming
    networks:
      - external_network
      - internal_network
    healthcheck:
      test: ['CMD-SHELL', 'wget -q --spider --proxy=off localhost:4000/api/v1/streaming/health || exit 1']
    ports:
      - '127.0.0.1:4000:4000'
    depends_on:
      - db
      - redis
    deploy:
      resources:
        limits:
          memory: 200M
        reservations:
          memory: 100M

  sidekiq:
    build: .
    image: mastodon/mastodon:latest
    restart: always
    env_file: .env.production
    command: bundle exec sidekiq -c 2
    depends_on:
      - db
      - redis
    networks:
      - external_network
      - internal_network
    volumes:
      - ./public/system:/mastodon/public/system
    deploy:
      resources:
        limits:
          memory: 300M
        reservations:
          memory: 150M

networks:
  external_network:
  internal_network:
    internal: true
EOF

echo "=== 构建 Mastodon 镜像 ==="
docker-compose build

echo "=== 初始化数据库 ==="
docker-compose run --rm web rails db:migrate
docker-compose run --rm web rails db:seed

echo "=== 预编译资源文件 ==="
docker-compose run --rm web rails assets:precompile

echo "=== 启动服务 ==="
docker-compose up -d

echo "=== 安装 Nginx ==="
apt install -y nginx certbot python3-certbot-nginx

echo "=== 配置 Nginx ==="
cat > /etc/nginx/sites-available/$DOMAIN << EOF
map \$http_upgrade \$connection_upgrade {
  default upgrade;
  ''      close;
}

upstream backend {
    server 127.0.0.1:3000 fail_timeout=0;
}

upstream streaming {
    server 127.0.0.1:4000 fail_timeout=0;
}

proxy_cache_path /var/cache/nginx/mastodon clean_time=1d;

server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;
    root /opt/mastodon/public;
    location /.well-known/acme-challenge/ { allow all; }
    location / { return 301 https://\$host\$request_uri; }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!MEDIUM:!LOW:!aNULL:!NULL:!SHA;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;

    keepalive_timeout    70;
    sendfile             on;
    client_max_body_size 80m;

    root /opt/mastodon/public;

    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
      text/plain
      text/css
      text/xml
      text/javascript
      application/json
      application/javascript
      application/xml+rss
      application/atom+xml
      image/svg+xml;

    add_header Strict-Transport-Security "max-age=31536000" always;

    location / {
      try_files \$uri @proxy;
    }

    location ~ ^/(emoji|packs|system/accounts/avatars|system/media_attachments/files) {
      add_header Cache-Control "public, max-age=31536000, immutable";
      add_header Strict-Transport-Security "max-age=31536000" always;
      try_files \$uri @proxy;
    }

    location /sw.js {
      add_header Cache-Control "public, max-age=604800, must-revalidate";
      add_header Strict-Transport-Security "max-age=31536000" always;
      try_files \$uri @proxy;
    }

    location @proxy {
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto \$scheme;
      proxy_set_header Proxy "";
      proxy_pass_header Server;

      proxy_pass http://backend;
      proxy_buffering on;
      proxy_redirect off;
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection \$connection_upgrade;

      proxy_cache mastodon;
      proxy_cache_valid 200 7d;
      proxy_cache_valid 410 24h;
      proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
      add_header X-Cached \$upstream_cache_status;
      add_header Strict-Transport-Security "max-age=31536000" always;

      tcp_nodelay on;
    }

    location /api/v1/streaming {
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto \$scheme;
      proxy_set_header Proxy "";

      proxy_pass http://streaming;
      proxy_buffering off;
      proxy_redirect off;
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection \$connection_upgrade;

      tcp_nodelay on;
    }

    error_page 500 501 502 503 504 /500.html;
}
EOF

# 启用站点
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 测试 Nginx 配置
nginx -t

# 重启 Nginx
systemctl restart nginx

echo "=== 获取 SSL 证书 ==="
certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL

echo "=== 创建管理员账户 ==="
echo "现在创建管理员账户..."
docker-compose run --rm web bin/tootctl accounts create admin --email $ADMIN_EMAIL --confirmed --role Owner

echo ""
echo "=== 部署完成！ ==="
echo "网站地址: https://$DOMAIN"
echo "管理员邮箱: $ADMIN_EMAIL"
echo "服务器IP: $(curl -s ifconfig.me)"
echo ""
echo "请访问你的网站并使用管理员账户登录"
echo "初始密码已显示在上面的输出中，请记录下来"
echo ""
echo "内存使用情况:"
free -h
echo ""
echo "常用管理命令："
echo "查看日志: cd /opt/mastodon && docker-compose logs -f"
echo "重启服务: cd /opt/mastodon && docker-compose restart"
echo "停止服务: cd /opt/mastodon && docker-compose down"
echo "启动服务: cd /opt/mastodon && docker-compose up -d"
echo "查看内存: htop 或 docker stats"
