#!/bin/bash
set -e

LOG_FILE="./logs/watchdog_$(date +%Y%m%d).log"
MAX_FAILURES=3
FAILURE_COUNT=0

echo "$(date '+%Y-%m-%d %H:%M:%S') [START] System watchdog started" >> "$LOG_FILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] Monitoring services. Recovery triggers ONLY after $MAX_FAILURES consecutive failures." >> "$LOG_FILE"

while true; do
    HEALTHY=true
    
    # Проверяем PostgreSQL ТОЛЬКО если контейнер запущен
    if docker ps --format '{{.Names}}' | grep -q "neolant-postgres"; then
        if ! docker exec neolant-postgres pg_isready -U postgres >/dev/null 2>&1; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] PostgreSQL connectivity issue" >> "$LOG_FILE"
            HEALTHY=false
        fi
    fi
    
    # Проверяем API ТОЛЬКО если Nginx запущен
    if docker ps --format '{{.Names}}' | grep -q "neolant-nginx"; then
        if ! curl -skf https://localhost/api/dotnet/health >/dev/null 2>&1; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] .NET API health check failed" >> "$LOG_FILE"
            HEALTHY=false
        fi
        
        if ! curl -skf https://localhost/api/python/health >/dev/null 2>&1; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] Python API health check failed" >> "$LOG_FILE"
            HEALTHY=false
        fi
    fi
    
    # Логируем статус без немедленного действия
    if [ "$HEALTHY" = false ]; then
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        echo "$(date '+%Y-%m-%d %H:%M:%S') [STATUS] Failure detected ($FAILURE_COUNT/$MAX_FAILURES)" >> "$LOG_FILE"
        
        # РЕАЛЬНОЕ ВОССТАНОВЛЕНИЕ ТОЛЬКО ПОСЛЕ МНОГОКРАТНЫХ СБОЕВ
        if [ "$FAILURE_COUNT" -ge "$MAX_FAILURES" ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') [ALERT] CRITICAL SYSTEM FAILURE - $MAX_FAILURES consecutive failures!" >> "$LOG_FILE"
            echo "$(date '+%Y-%m-%d %H:%M:%S') [ACTION] Initiating disaster recovery procedure..." >> "$LOG_FILE"
            
            # Сохраняем логи перед восстановлением
            docker logs neolant-postgres > "./logs/postgres_crash_$(date +%Y%m%d_%H%M%S).log" 2>&1 || true
            docker logs neolant-nginx > "./logs/nginx_crash_$(date +%Y%m%d_%H%M%S).log" 2>&1 || true
            
            # Запускаем восстановление
            ./scripts/disaster-recovery.sh >> "$LOG_FILE" 2>&1
            
            echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] System fully recovered" >> "$LOG_FILE"
            FAILURE_COUNT=0
        fi
    else
        # Система здорова - сбрасываем счетчик и логируем успех
        if [ "$FAILURE_COUNT" -gt 0 ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') [RECOVERY] System stabilized, resetting failure counter" >> "$LOG_FILE"
            FAILURE_COUNT=0
        fi
        echo "$(date '+%Y-%m-%d %H:%M:%S') [HEALTHY] All services operational" >> "$LOG_FILE"
    fi
    
    sleep 30
done
