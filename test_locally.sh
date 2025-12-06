#!/bin/bash
echo "=== Локальный тест CI/CD ==="

# 1. Проверяем структуру
echo "1. Проверяем структуру проекта..."
[ -f "deploy/docker-compose.yml" ] && echo "✅ docker-compose.yml существует" || echo "❌ docker-compose.yml отсутствует"
[ -f "dotnet_app/NeolantDemo.csproj" ] && echo "✅ .NET project существует" || echo "❌ .NET project отсутствует"
[ -f "app/requirements.txt" ] && echo "✅ requirements.txt существует" || echo "❌ requirements.txt отсутствует"
[ -f "db/init.sql" ] && echo "✅ init.sql существует" || echo "❌ init.sql отсутствует"

# 2. Проверяем приватные ключи
echo -e "\n2. Проверяем приватные ключи..."
if find . -name "*.key" -o -name "*.pem" -o -name "*.crt" | grep -v node_modules | grep -v ".git"; then
    echo "⚠️  Найденные файлы ключей (проверь .gitignore):"
    find . -name "*.key" -o -name "*.pem" -o -name "*.crt" | grep -v node_modules | grep -v ".git"
else
    echo "✅ Приватных ключей не найдено"
fi

# 3. Проверяем синтаксис bash скриптов
echo -e "\n3. Проверяем bash скрипты..."
for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        if bash -n "$script"; then
            echo "✅ $script: синтаксис корректен"
        else
            echo "❌ $script: ошибка синтаксиса"
        fi
    fi
done

# 4. Проверяем docker-compose
echo -e "\n4. Проверяем docker-compose..."
if docker-compose -f deploy/docker-compose.yml config > /dev/null 2>&1; then
    echo "✅ docker-compose.yml валиден"
else
    echo "❌ docker-compose.yml невалиден"
fi

echo -e "\n=== Тест завершен ==="
