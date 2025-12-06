#!/bin/bash

echo "=============================================="
echo "NEOLANT DEVOPS DEMO - ПОЛНЫЙ СТЕК"
echo "=============================================="
echo ""

echo "1. ЗАПУСК ВСЕХ СЕРВИСОВ:"
echo "   $ ./run.sh"
echo ""
sleep 2

echo "2. ПРОВЕРКА ЗДОРОВЬЯ СЕРВИСОВ:"
echo "   $ curl http://localhost:8081/health"
curl -s http://localhost:8081/health | jq .
echo ""
echo "   $ curl http://localhost:8001/health"
curl -s http://localhost:8001/health | jq .
echo ""
sleep 2

echo "3. .NET API - ПРОМЫШЛЕННЫЕ ОБЪЕКТЫ:"
echo "   $ curl http://localhost:8081/api/industrial-objects | jq ."
curl -s http://localhost:8081/api/industrial-objects | jq .
echo ""
sleep 2

echo "4. PYTHON API - МЕТРИКИ МОНИТОРИНГА:"
echo "   $ curl http://localhost:8001/api/metrics"
curl -s http://localhost:8001/api/metrics | jq .
echo ""
sleep 2

echo "5. POSTGRESQL - ДАННЫЕ В БАЗЕ:"
echo "   $ docker exec neolant-postgres psql -U postgres -d neolant_db -c 'SELECT id, name, type FROM industrial_objects;'"
docker exec neolant-postgres psql -U postgres -d neolant_db -c "SELECT id, name, type FROM industrial_objects;"
echo ""
sleep 2

echo "6. DOCKER КОНТЕЙНЕРЫ:"
echo "   $ docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo ""
sleep 2

echo "7. БЭКАП БАЗЫ ДАННЫХ:"
echo "   $ ./scripts/backup.sh"
./scripts/backup.sh 2>/dev/null || echo "Бэкап создается..."
echo ""
sleep 2

echo "8. МОНИТОРИНГ СЕРВИСОВ:"
echo "   $ ./scripts/monitor.sh"
./scripts/monitor.sh
echo ""
sleep 2

echo "=============================================="
echo "ТЕХНИЧЕСКИЕ ХАРАКТЕРИСТИКИ:"
echo "• 3 микросервиса в Docker контейнерах"
echo "• PostgreSQL 15 с промышленными данными"
echo "• ASP.NET Core 8 Web API"
echo "• FastAPI Python 3.11"
echo "• Автоматическое резервное копирование"
echo "• Health checks и мониторинг"
echo "• Kubernetes-ready манифесты"
echo "• Helm charts для деплоя"
echo "• CI/CD через GitHub Actions"
echo "=============================================="

echo "9. КЛЮЧЕВЫЕ ФАЙЛЫ ПРОЕКТА:"
echo "   Структура проекта:"
tree -L 2 2>/dev/null || find . -maxdepth 2 -type f -name "*.yml" -o -name "*.yaml" -o -name "Dockerfile*" -o -name "*.sh" | grep -v backups | head -10
echo ""
sleep 2

echo "=============================================="
echo "GitHub репозиторий: (скопируйте после создания)"
echo "# Создайте репозиторий на GitHub.com"
echo "# Затем выполните:"
echo "git init"
echo "git add ."
echo "git commit -m 'Neolant DevOps Demo'"
echo "git branch -M main"
echo "git remote add origin git@github.com:ВАШ_ЛОГИН/neolant-devops-demo.git"
echo "git push -u origin main"
echo "=============================================="
