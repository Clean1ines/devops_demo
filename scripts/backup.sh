#!/bin/bash
set -e

echo "=== PostgreSQL Backup ==="
BACKUP_DIR="./backups"
mkdir -p "$BACKUP_DIR"
FILENAME="neolant_backup_$(date +%Y%m%d_%H%M%S).sql"

docker exec neolant-postgres pg_dump -U postgres neolant_db > "$BACKUP_DIR/$FILENAME"
gzip "$BACKUP_DIR/$FILENAME"

echo "Backup created: $BACKUP_DIR/$FILENAME.gz"
ls -lh "$BACKUP_DIR/"
