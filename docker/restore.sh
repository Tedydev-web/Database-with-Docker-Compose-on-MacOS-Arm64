#!/bin/bash

# Restore MySQL
echo "Restoring MySQL databases..."
docker exec -i mysql-container mysql -u root -p${MYSQL_ROOT_PASSWORD} < ./mysql/backup/mysql_backup_YYYYMMDD_HHMMSS.sql

# Restore SQL Server
echo "Restoring SQL Server databases..."
docker exec sqlserver-container /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U sa -P ${SQL_SA_PASSWORD} \
    -Q "RESTORE DATABASE [YourDatabase] FROM DISK = '/backup/sqlserver_backup_YYYYMMDD_HHMMSS.bak'"

echo "Restore completed!" 