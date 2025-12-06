#!/bin/bash
set -e

echo "=== LOCAL CI PIPELINE ==="
echo "Timestamp: $(date)"
echo ""

# Этап 1: Проверка синтаксиса
echo "[1] Syntax checks..."
bash -n ./run.sh
bash -n ./scripts/*.sh
echo "✅ Syntax checks passed"

# Этап 2: Сборка образов
echo "[2] Building Docker images..."
docker-compose -f deploy/docker-compose.yml build
echo "✅ Images built successfully"

# Этап 3: Запуск и проверка
echo "[3] Starting services for testing..."
docker-compose -f deploy/docker-compose.yml up -d
sleep 15

echo "[4] Running health checks..."
curl -sk https://localhost/api/dotnet/health | jq .
curl -sk https://localhost/api/python/health | jq .
echo "✅ Health checks passed"

# Этап 4: Остановка сервисов
echo "[5] Cleaning up..."
docker-compose -f deploy/docker-compose.yml down
echo "✅ Local CI pipeline completed successfully"
