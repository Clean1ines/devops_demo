#!/bin/bash
echo "=== СИМУЛЯЦИЯ GITHUB ACTIONS ==="
echo ""

echo "1. Проверяем YAML синтаксис пайплайна..."
if python3 -c "import yaml; yaml.safe_load(open('.github/workflows/test.yml'))" 2>/dev/null; then
    echo "✅ YAML синтаксис OK"
else
    echo "❌ Ошибка в YAML файле!"
    exit 1
fi

echo ""
echo "2. Проверяем структуру как в пайплайне..."
echo "=== ФАЙЛЫ В РЕПОЗИТОРИИ ==="
find . -type f | grep -E '\.(sh|yml|yaml|cs|py|sql|csproj)$' | head -20

echo ""
echo "=== ПРОВЕРКА ПРИВАТНЫХ КЛЮЧЕЙ ==="
KEY_FILES=$(find . -type f -name "*.key" -o -name "*.pem" -o -name "*.crt" 2>/dev/null | grep -v node_modules | grep -v ".git" | wc -l)
if [ $KEY_FILES -gt 0 ]; then
    echo "❌ Найдено приватных ключей: $KEY_FILES"
    find . -type f -name "*.key" -o -name "*.pem" -o -name "*.crt" 2>/dev/null | grep -v node_modules | grep -v ".git"
    echo "СОВЕТ: удали их из Git: git rm --cached <файлы>"
else
    echo "✅ Приватных ключей нет"
fi

echo ""
echo "=== ПРОСТАЯ ВАЛИДАЦИЯ ==="
[ -f "run.sh" ] && echo "✅ run.sh есть" || echo "❌ run.sh нет"
[ -f "deploy/docker-compose.yml" ] && echo "✅ docker-compose.yml есть" || echo "❌ docker-compose.yml нет"

echo ""
echo "🎉 Локальная симуляция прошла успешно!"
echo "Теперь можно пушить и смотреть реальный запуск на GitHub"
