#!/bin/bash

# Đọc biến môi trường
source ../.env

# Tạo thư mục backup nếu chưa tồn tại
mkdir -p backup

# Tên file backup với timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="/backup/sqlserver_backup_$TIMESTAMP.bak"

# Thực hiện backup trong container
docker exec sqlserver-container /opt/mssql-tools/bin/sqlcmd \
    -S localhost \
    -U sa \
    -P "${SQL_SA_PASSWORD:-TedyDev@2310}" \
    -Q "BACKUP DATABASE [master] TO DISK = N'$BACKUP_FILE' WITH NOFORMAT, NOINIT, NAME = 'master-full', SKIP, NOREWIND, NOUNLOAD, STATS = 10"

# Log kết quả
echo "Backup completed at $(date). File: $BACKUP_FILE" >> backup/backup.log

# Xóa các file backup cũ hơn 7 ngày
find backup -name "sqlserver_backup_*.bak" -mtime +7 -delete 