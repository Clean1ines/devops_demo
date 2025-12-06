#!/bin/bash
echo "=== Neolant DevOps Demo ==="

# Останавливаем старые контейнеры
echo "0. Stopping old containers..."
docker-compose -f deploy/docker-compose.yml down 2>/dev/null || true

# Генерируем SSL сертификаты если их нет
if [ ! -f deploy/ssl/neolant.crt ] || [ ! -f deploy/ssl/neolant.key ]; then
    echo "0.5. Generating SSL certificates (local only, not committed)..."
    mkdir -p deploy/ssl
    cd deploy/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout neolant.key -out neolant.crt \
        -subj "/C=RU/ST=Moscow/L=Moscow/O=Neolant/CN=localhost"
    cd ../..
    echo "SSL certificates generated in deploy/ssl/ (local only)"
fi

echo "1. Building images..."
docker-compose -f deploy/docker-compose.yml build

echo "2. Starting services..."
docker-compose -f deploy/docker-compose.yml up -d

echo "3. Waiting for startup..."
sleep 20

echo "4. Health check..."
curl -sk https://localhost/health && echo " - Reverse Proxy OK" || echo " - Reverse Proxy FAILED"
curl -sk https://localhost/api/dotnet/industrial-objects && echo " - .NET API OK" || echo " - .NET API FAILED"
curl -sk https://localhost/api/python/metrics && echo " - Python API OK" || echo " - Python API FAILED"

echo ""
echo "=== Services running ==="
echo "PostgreSQL:     localhost:5433"
echo "Reverse Proxy:  https://localhost (HTTPS only)"
echo ".NET API:       https://localhost/api/dotnet/"
echo "Python API:     https://localhost/api/python/"
echo ""
echo "Test commands:"
echo "  curl -k https://localhost/api/dotnet/industrial-objects | jq ."
echo "  curl -k https://localhost/api/python/metrics | jq ."
echo ""
echo "To stop:        docker-compose -f deploy/docker-compose.yml down"
