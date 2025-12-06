#!/bin/bash
set -e

LOG_FILE="./logs/watchdog_$(date +%Y%m%d).log"
MAX_FAILURES=3
FAILURE_COUNT=0

echo "$(date '+%Y-%m-%d %H:%M:%S') [START] System watchdog started" >> "$LOG_FILE"

while true; do
    HEALTHY=true
    
    # Проверяем PostgreSQL
    if ! docker exec neolant-postgres pg_isready -U postgres >/dev/null 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [CRITICAL] PostgreSQL is down!" >> "$LOG_FILE"
        HEALTHY=false
    fi
    
    # Проверяем API через Nginx
    if ! curl -skf https://localhost/api/dotnet/health >/dev/null 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [CRITICAL] .NET API is unreachable!" >> "$LOG_FILE"
        HEALTHY=false
    fi
    
    if ! curl -skf https://localhost/api/python/health >/dev/null 2>&1; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [CRITICAL] Python API is unreachable!" >> "$LOG_FILE"
        HEALTHY=false
    fi
    
    if [ "$HEALTHY" = false ]; then
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] Failure detected ($FAILURE_COUNT/$MAX_FAILURES)" >> "$LOG_FILE"
        
        if [ "$FAILURE_COUNT" -ge "$MAX_FAILURES" ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') [RECOVERY] AUTOMATIC DISASTER RECOVERY INITIATED!" >> "$LOG_FILE"
            
            # Запускаем восстановление
            ./scripts/disaster-recovery.sh >> "$LOG_FILE" 2>&1
            
            echo "$(date '+%Y-%m-%d %H:%M:%S') [RECOVERY] Disaster recovery completed" >> "$LOG_FILE"
            FAILURE_COUNT=0
        fi
    else
        if [ "$FAILURE_COUNT" -gt 0 ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') [RECOVERY] System recovered, resetting counter" >> "$LOG_FILE"
            FAILURE_COUNT=0
        fi
    fi
    
    sleep 30
done
