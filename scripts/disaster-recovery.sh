#!/bin/bash
set -e

START_TIME=$(date +%s)
echo "=== Neolant DISASTER RECOVERY SCENARIO ==="
echo "Timestamp: $(date)"
echo ""

echo "[1] INITIATING SYSTEM RESET..."
docker-compose -f deploy/docker-compose.yml down --remove-orphans
docker volume rm deploy_postgres_data --force 2>/dev/null || true
rm -rf postgres_data/ 2>/dev/null || true
echo "✅ System reset complete"

echo "[2] STARTING FRESH POSTGRESQL..."
docker-compose -f deploy/docker-compose.yml up -d postgres
sleep 15

echo "[3] CREATING SERVER-LEVEL ROLES..."
if ! docker exec neolant-postgres psql -U postgres -t -c "SELECT 1 FROM pg_roles WHERE rolname = 'app_user'" | grep -q 1; then
    docker exec neolant-postgres psql -U postgres -c "CREATE ROLE app_user WITH LOGIN PASSWORD 'app_password';"
fi
if ! docker exec neolant-postgres psql -U postgres -t -c "SELECT 1 FROM pg_roles WHERE rolname = 'ldap_auth'" | grep -q 1; then
    docker exec neolant-postgres psql -U postgres -c "CREATE ROLE ldap_auth WITH LOGIN PASSWORD 'ldap_secure_password_2025';"
fi
echo "✅ Server-level roles ready"

echo "[4] CREATING CLEAN DATABASE..."
docker exec neolant-postgres psql -U postgres -c "DROP DATABASE IF EXISTS neolant_db;" 2>/dev/null || true
docker exec neolant-postgres psql -U postgres -c "CREATE DATABASE neolant_db;"
echo "✅ Clean database created"

echo "[5] RESTORING FROM BACKUP..."
BACKUP_FILE=$(ls -t ./backups/*.gz 2>/dev/null | head -1)
if [ -z "$BACKUP_FILE" ]; then
    echo "❌ No backup files found! Creating emergency backup..."
    ./scripts/backup.sh
    BACKUP_FILE=$(ls -t ./backups/*.gz | head -1)
fi
gunzip -c "$BACKUP_FILE" | docker exec -i neolant-postgres psql -U postgres -d neolant_db
echo "✅ Database restored successfully"

echo "[6] RESTARTING ALL SERVICES..."
docker-compose -f deploy/docker-compose.yml up -d --force-recreate
sleep 30

echo "[7] VALIDATING RECOVERY..."
curl -sk https://localhost/api/dotnet/health | jq .
curl -sk https://localhost/api/python/health | jq .
curl -sk https://localhost/api/dotnet/industrial-objects | jq '.[:2]'
echo "✅ Recovery validation complete"

END_TIME=$(date +%s)
RECOVERY_TIME=$((END_TIME - START_TIME))

echo ""
echo "🎉 DISASTER RECOVERY SUCCESSFUL!"
echo "System restored in $RECOVERY_TIME seconds"
echo "==================================="
