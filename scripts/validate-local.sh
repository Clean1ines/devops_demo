#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "== LOCAL CI CHECK =="

echo "[1] .NET restore & build"
cd dotnet_app
dotnet restore
dotnet publish -c Release -o out
cd ..

echo "[2] Docker build"
docker build -t neolant-dotnet ./dotnet_app
docker build -t neolant-python -f deploy/Dockerfile.python .

echo "[3] Start docker-compose"
docker compose -f deploy/docker-compose.yml up -d

echo "[4] Wait PostgreSQL"
for i in {1..30}; do
  if docker exec neolant-postgres pg_isready -U postgres; then
    echo "Postgres ready"
    break
  fi
  sleep 2
done

echo "[5] Wait .NET API"
for i in {1..30}; do
  if curl -sf http://localhost:8081/health >/dev/null; then
    echo ".NET API ready"
    break
  fi
  sleep 2
done

echo "[6] Wait Python API"
for i in {1..30}; do
  if curl -sf http://localhost:8001/health >/dev/null; then
    echo "Python API ready"
    break
  fi
  sleep 2
done

echo "[7] Smoke tests"
curl -f http://localhost:8081/health
curl -f http://localhost:8001/health

echo "[8] Teardown"
docker compose -f deploy/docker-compose.yml down -v

echo "✅ LOCAL CI PASSED"
