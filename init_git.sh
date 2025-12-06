#!/bin/bash

echo "=== ИНИЦИАЛИЗАЦИЯ GIT ДЛЯ NEOLANT DEMO ==="
echo ""

# Проверяем наличие SSH ключа
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "1. СОЗДАЕМ SSH КЛЮЧ..."
    ssh-keygen -t ed25519 -C "neolant-demo@github.com" -f ~/.ssh/id_ed25519 -N ""
    echo ""
    echo "=== ДОБАВЬ ЭТОТ КЛЮЧ В GITHUB ==="
    echo "1. Открой https://github.com/settings/keys"
    echo "2. Нажми 'New SSH key'"
    echo "3. Введи название: 'Neolant Demo'"
    echo "4. Вставь ключ ниже:"
    echo ""
    cat ~/.ssh/id_ed25519.pub
    echo ""
    read -p "Нажми Enter после добавления ключа в GitHub..."
fi

echo ""
echo "2. СОЗДАЙ РЕПОЗИТОРИЙ НА GITHUB:"
echo "   Открой: https://github.com/new"
echo "   Repository name: neolant-devops-demo"
echo "   Description: DevOps Demo project for Neolant interview"
echo "   Public repository"
echo "   НЕ добавляй README, .gitignore, license"
echo "   Нажми 'Create repository'"
echo ""
read -p "Введи SSH URL репозитория (например git@github.com:username/neolant-devops-demo.git): " repo_url

echo ""
echo "3. ИНИЦИАЛИЗИРУЕМ GIT..."
git init
git add .
git commit -m "Neolant DevOps Demo: Complete stack for interview

Features:
- .NET Core 8 API for industrial objects
- PostgreSQL 15 with production data
- Python FastAPI monitoring service
- Docker Compose with health checks
- Kubernetes manifests
- Helm charts
- CI/CD with GitHub Actions
- Bash scripts for backup and monitoring"

echo ""
echo "4. ДОБАВЛЯЕМ REMOTE И ПУШИМ..."
git branch -M main
git remote add origin "$repo_url"
git push -u origin main

echo ""
echo "🎉 ПРОЕКТ ЗАПУШЕН В GITHUB!"
echo "Ссылка: https://github.com/$(echo $repo_url | cut -d':' -f2 | sed 's/.git$//')"
echo ""
echo "Добавь эту ссылку в резюме!"
echo "Для демонстрации на собеседовании: ./demo.sh"
