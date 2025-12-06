# DevOps Demo для Neolant

## 📋 Покрытие требований вакансии

### ✅ Обязательные:
- Linux: Все скрипты на Bash
- Docker: Dockerfile + Docker Compose
- Git: CI/CD через GitHub Actions
- SQL: PostgreSQL с бэкапами
- Bash: Скрипты администрирования
- Сети: Nginx, сетевые настройки

### ✅ Желательные:
- .NET Core: Рабочее приложение
- Kubernetes: Манифесты
- Helm: Chart для деплоя
- TLS: SSL сертификаты
- Мониторинг: Prometheus + Grafana

## 🚀 Быстрый старт
```bash
# 1. Поднять инфраструктуру
docker-compose -f deploy/docker-compose.yml up -d

# 2. Проверить
curl http://localhost:8080/health
curl http://localhost:8000/health
```

📁 Структура проекта

· /app - Python FastAPI приложение
· /dotnet_app - .NET Core Web API
· /db - SQL скрипты
· /deploy - Docker и Nginx конфиги
· /scripts - Bash скрипты
· /k8s - Kubernetes манифесты
· /helm - Helm charts
· /.github - CI/CD workflows




# devops_demo
# devops_demo
