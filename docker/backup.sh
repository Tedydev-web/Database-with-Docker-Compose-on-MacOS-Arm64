#!/bin/bash
set -e

# Load environment variables
source .env

# Tạo backup với mã hóa
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/$BACKUP_DATE"
mkdir -p "$BACKUP_DIR"

echo "🚀 Bắt đầu quá trình backup..."

# MySQL Backup với compression và mã hóa
echo "📦 Đang backup MySQL databases..."
docker exec mysql-container mysqldump \
    --single-transaction \
    --quick \
    --routines \
    --triggers \
    --events \
    -u root -p"$MYSQL_ROOT_PASSWORD" \
    --all-databases | gzip | openssl enc -aes-256-cbc -salt -k "$BACKUP_ENCRYPTION_KEY" \
    > "$BACKUP_DIR/mysql.sql.gz.enc"

# SQL Server Backup
echo "📦 Đang backup SQL Server databases..."
docker exec sqlserver-container /opt/mssql-tools/bin/sqlcmd \
    -S localhost \
    -U sa \
    -P "$SQL_SA_PASSWORD" \
    -Q "BACKUP DATABASE [master] TO DISK = '/backup/sqlserver_backup.bak' WITH COMPRESSION, STATS = 10"

# Mã hóa SQL Server backup
openssl enc -aes-256-cbc -salt -k "$BACKUP_ENCRYPTION_KEY" \
    < "./sqlserver/backup/sqlserver_backup.bak" \
    > "$BACKUP_DIR/sqlserver_backup.bak.enc"

# Backup cấu hình
echo "📦 Đang backup cấu hình..."
tar czf - mysql/conf.d sqlserver/scripts phpmyadmin/nginx .env | \
    openssl enc -aes-256-cbc -salt -k "$BACKUP_ENCRYPTION_KEY" \
    > "$BACKUP_DIR/config.tar.gz.enc"

# Tạo checksum
find "$BACKUP_DIR" -type f -exec sha256sum {} \; > "$BACKUP_DIR/checksums.txt"

echo "✅ Backup hoàn tất! Location: $BACKUP_DIR" 