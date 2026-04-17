#!/bin/bash

set -e

echo "=============================="
echo "[1] Clean old environment"
echo "=============================="

# Stop existing Compose services (supports both V1 and V2)
docker compose down -v 2>/dev/null || docker-compose down -v 2>/dev/null || true

# Remove leftover containers (to avoid ContainerConfig errors)
docker rm -f client gateway serverA serverB 2>/dev/null || true

# Clean up unused networks (to avoid subnet conflicts)
docker network prune -f >/dev/null 2>&1 || true

echo "=============================="
echo "[2] Start containers"
echo "=============================="

if command -v docker compose >/dev/null 2>&1; then
    docker compose up -d
else
    docker-compose up -d
fi

echo "Waiting containers to be ready..."
sleep 3

echo "=============================="
echo "[3] Configure"
echo "=============================="

# client → server-net
docker exec client ip route add 10.10.50.0/24 via 10.20.16.2 || true

# server → client-net
docker exec serverA ip route replace default via 10.10.50.2 || true
docker exec serverB ip route replace default via 10.10.50.2 || true

# create a fake docker0
docker exec serverB ip link add name docker0 type bridge
docker exec serverB ip addr add 10.20.16.1/20 dev docker0
docker exec serverB ip link set docker0 up

echo "=============================="
echo "[4] Network status"
echo "=============================="

echo "--- client routing ---"
docker exec client ip route

echo "--- gateway routing ---"
docker exec gateway ip route

echo "--- serverA routing ---"
docker exec serverA ip route

echo "--- serverB routing ---"
docker exec serverB ip route

echo "=============================="
echo "[5] Basic connectivity test"
echo "=============================="

echo "client -> gateway"
docker exec client ping -c 2 10.20.16.2 || true

echo "client -> serverA"
docker exec client ping -c 2 10.10.50.9 || true

echo "client -> serverB"
docker exec client ping -c 2 10.10.50.10 || true

echo "=============================="
echo "[DONE] Lab is ready"
echo "=============================="
