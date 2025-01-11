#!/bin/bash

# Đọc biến môi trường
source ../.env

# Tạo thư mục backup nếu chưa tồn tại
mkdir -p backup

# Tên file backup với timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="backup/mysql_backup_$TIMESTAMP.sql"

# Thực hiện backup
docker exec mysql-container mysqldump \
    -u root \
    -p"${MYSQL_ROOT_PASSWORD:-TedyDev@2310}" \
    --all-databases \
    --single-transaction \
    --quick \
    --lock-tables=false \
    > "$BACKUP_FILE"

# Nén file backup
gzip "$BACKUP_FILE"

# Log kết quả
echo "Backup completed at $(date). File: ${BACKUP_FILE}.gz" >> backup/backup.log

# Xóa các file backup cũ hơn 7 ngày
find backup -name "mysql_backup_*.sql.gz" -mtime +7 -delete 