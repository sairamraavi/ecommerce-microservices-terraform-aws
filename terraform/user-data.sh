#!/bin/bash
set -euxo pipefail

# Save bootstrap output for troubleshooting
exec > >(tee -a /var/log/ecommerce-bootstrap.log /dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

echo "===== Installing Docker ====="

apt-get update -y
apt-get install -y ca-certificates curl

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

. /etc/os-release

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y

apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

systemctl enable --now docker

docker --version
docker compose version

echo "===== Creating Application Directory ====="

mkdir -p /opt/ecommerce
cd /opt/ecommerce

echo "===== Creating Docker Compose Configuration ====="

cat > compose.yaml <<'EOF'
services:
  mongodb:
    image: mongo:7
    restart: unless-stopped
    volumes:
      - mongo_data:/data/db
    networks:
      - ecommerce-net
    healthcheck:
      test: ["CMD", "mongosh", "--quiet", "--eval", "db.adminCommand('ping').ok"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 30s

  user-service:
    image: sairamraavi/ecommerce-user-service:v1
    platform: linux/amd64
    restart: unless-stopped
    environment:
      PORT: "3001"
      MONGODB_URI: mongodb://mongodb:27017/ecommerce_users
    depends_on:
      mongodb:
        condition: service_healthy
    networks:
      - ecommerce-net

  product-service:
    image: sairamraavi/ecommerce-product-service:v1
    platform: linux/amd64
    restart: unless-stopped
    environment:
      PORT: "3002"
      MONGODB_URI: mongodb://mongodb:27017/ecommerce_products
    depends_on:
      mongodb:
        condition: service_healthy
    networks:
      - ecommerce-net

  cart-service:
    image: sairamraavi/ecommerce-cart-service:v1
    platform: linux/amd64
    restart: unless-stopped
    environment:
      PORT: "3003"
      MONGODB_URI: mongodb://mongodb:27017/ecommerce_carts
    depends_on:
      mongodb:
        condition: service_healthy
    networks:
      - ecommerce-net

  order-service:
    image: sairamraavi/ecommerce-order-service:v1
    platform: linux/amd64
    restart: unless-stopped
    environment:
      PORT: "3004"
      MONGODB_URI: mongodb://mongodb:27017/ecommerce_orders
    depends_on:
      mongodb:
        condition: service_healthy
    networks:
      - ecommerce-net

  frontend:
    image: sairamraavi/ecommerce-frontend:v1
    platform: linux/amd64
    restart: unless-stopped
    ports:
      - "80:80"
    depends_on:
      - user-service
      - product-service
      - cart-service
      - order-service
    networks:
      - ecommerce-net

networks:
  ecommerce-net:
    driver: bridge

volumes:
  mongo_data:
EOF

echo "===== Pulling Docker Images ====="

docker compose pull

echo "===== Starting Application ====="

docker compose up -d --wait --wait-timeout 240

echo "===== Container Status ====="

docker compose ps -a

echo "===== Deployment Bootstrap Completed ====="
