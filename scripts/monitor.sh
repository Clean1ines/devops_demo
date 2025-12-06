#!/bin/bash
echo "=== Service Health Check ==="
echo "Checking at: $(date)"

check_http_service() {
    local name=$1
    local url=$2
    
    if curl -s -f "$url" > /dev/null; then
        echo "✅ $name: HEALTHY"
        return 0
    else
        echo "❌ $name: UNHEALTHY"
        return 1
    fi
}

check_port_service() {
    local name=$1
    local port=$2
    
    if nc -z localhost "$port" 2>/dev/null; then
        echo "✅ $name: PORT OPEN"
        return 0
    else
        echo "❌ $name: PORT CLOSED"
        return 1
    fi
}

check_db_service() {
    local name=$1
    local container=$2
    
    if docker exec "$container" pg_isready -U postgres > /dev/null 2>&1; then
        echo "✅ $name: DATABASE READY"
        return 0
    else
        echo "❌ $name: DATABASE NOT READY"
        return 1
    fi
}

echo "--- HTTP Services ---"
check_http_service ".NET API" "http://localhost:8081/health"
check_http_service "Python API" "http://localhost:8001/health"

echo "--- Port Checks ---"
check_port_service "PostgreSQL Port" "5433"

echo "--- Database Check ---"
check_db_service "PostgreSQL Database" "neolant-postgres"

echo "=== Check Complete ==="
