# Hướng Dẫn Nâng Cao

## Mục Lục
1. [Quản Lý Dữ Liệu](#quản-lý-dữ-liệu)
2. [Bảo Mật](#bảo-mật)
3. [Hiệu Năng](#hiệu-năng)
4. [Backup Strategies](#backup-strategies)
5. [Troubleshooting](#troubleshooting)

## Quản Lý Dữ Liệu

### Import/Export Dữ Liệu Lớn MySQL
```bash
# Export database
docker exec mysql-container mysqldump -u root -p"${MYSQL_ROOT_PASSWORD}" database_name > export.sql

# Import database
docker exec -i mysql-container mysql -u root -p"${MYSQL_ROOT_PASSWORD}" database_name < import.sql

# Import file lớn
pv import.sql | docker exec -i mysql-container mysql -u root -p"${MYSQL_ROOT_PASSWORD}" database_name
```

### SQL Server Bulk Import
```bash
# Copy file vào container
docker cp data.bak sqlserver-container:/var/opt/mssql/data/

# Restore
docker exec -it sqlserver-container /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U sa -P "${SQL_SA_PASSWORD}" \
    -Q "RESTORE DATABASE [DB_NAME] FROM DISK = N'/var/opt/mssql/data/data.bak'"
```

### Redis Data Migration
```bash
# Dump RDB file
docker exec redis-container redis-cli SAVE

# Copy RDB file
docker cp redis-container:/data/dump.rdb ./backup/

# Restore
docker cp ./backup/dump.rdb redis-container:/data/
docker restart redis-container
```

## Bảo Mật

### MySQL Security
```bash
# Tạo user mới với IP restriction
CREATE USER 'newuser'@'172.%' IDENTIFIED BY 'password';
GRANT SELECT, INSERT ON database.* TO 'newuser'@'172.%';

# Enable SSL
docker exec mysql-container mysql -u root -p"${MYSQL_ROOT_PASSWORD}" \
    -e "ALTER USER 'root'@'%' REQUIRE SSL;"
```

### SQL Server Security
```bash
# Tạo login và user
CREATE LOGIN AppUser WITH PASSWORD = 'StrongPass123';
CREATE USER AppUser FOR LOGIN AppUser;
ALTER ROLE db_datareader ADD MEMBER AppUser;

# Enable encryption
ALTER DATABASE YourDB SET ENCRYPTION ON;
```

### Redis Security
```bash
# Thêm authentication
redis-cli CONFIG SET requirepass "your_password"

# Disable dangerous commands
rename-command FLUSHALL ""
rename-command CONFIG ""
```

## Hiệu Năng

### MySQL Performance Tuning
```bash
# Kiểm tra status
docker exec mysql-container mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" extended-status

# Optimize table
docker exec mysql-container mysqlcheck -o -A -u root -p"${MYSQL_ROOT_PASSWORD}"

# Analyze slow queries
docker exec mysql-container mysqldumpslow /var/log/mysql/slow-query.log
```

### SQL Server Performance
```sql
-- Kiểm tra top queries
SELECT TOP 10 
    total_worker_time/execution_count AS avg_cpu_time,
    execution_count,
    text
FROM sys.dm_exec_query_stats
CROSS APPLY sys.dm_exec_sql_text(sql_handle)
ORDER BY avg_cpu_time DESC;

-- Index maintenance
ALTER INDEX ALL ON TableName REBUILD;
```

### Redis Performance
```bash
# Memory analysis
docker exec redis-container redis-cli --bigkeys

# Monitoring commands
docker exec redis-container redis-cli MONITOR

# Latency doctor
docker exec redis-container redis-cli --latency-doctor
```

## Backup Strategies

### Automated Backup với Retention
```bash
#!/bin/bash
# backup_with_retention.sh

# Số ngày giữ backup
RETENTION_DAYS=30

# Backup MySQL
mysqldump_with_retention() {
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="./mysql/backup"
    
    # Tạo backup
    docker exec mysql-container mysqldump -u root -p"${MYSQL_ROOT_PASSWORD}" \
        --all-databases > "$BACKUP_DIR/full_backup_$TIMESTAMP.sql"
    
    # Xóa backup cũ
    find "$BACKUP_DIR" -name "full_backup_*.sql" -mtime +$RETENTION_DAYS -delete
}

# Backup SQL Server
sqlserver_backup_with_retention() {
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="./sqlserver/backup"
    
    # Backup all databases
    docker exec sqlserver-container /opt/mssql-tools/bin/sqlcmd \
        -S localhost -U sa -P "${SQL_SA_PASSWORD}" \
        -Q "BACKUP DATABASE [master] TO DISK='$BACKUP_DIR/master_$TIMESTAMP.bak'"
    
    # Xóa backup cũ
    find "$BACKUP_DIR" -name "*.bak" -mtime +$RETENTION_DAYS -delete
}
```

### Point-in-Time Recovery
```bash
# MySQL binary log
docker exec mysql-container mysqlbinlog \
    --start-datetime="2024-01-01 00:00:00" \
    --stop-datetime="2024-01-02 00:00:00" \
    /var/log/mysql/mysql-bin.000001 > recovery.sql

# SQL Server transaction log
RESTORE DATABASE [YourDB] 
FROM DISK = 'backup.bak'
WITH NORECOVERY;
RESTORE LOG [YourDB]
FROM DISK = 'log.trn'
WITH STOPAT = '2024-01-01 12:00:00';
```

## Troubleshooting

### Common Issues

1. **Container Không Thể Start**
```bash
# Kiểm tra port conflicts
sudo lsof -i :3306
sudo lsof -i :1433
sudo lsof -i :6379

# Kiểm tra volume permissions
ls -la ~/docker/mysql/data
sudo chown -R 999:999 ~/docker/mysql/data
```

2. **Memory Issues**
```bash
# Kiểm tra memory usage
docker stats

# Cleanup không gian
docker system prune -af
docker volume prune -f
```

3. **Network Issues**
```bash
# Kiểm tra network
docker network ls
docker network inspect mysql-network

# Recreate network
docker network rm mysql-network
docker network create mysql-network
```

### Debug Tools

1. **Container Logs**
```bash
# Tail logs
docker logs -f --tail 100 mysql-container

# Save logs to file
docker logs mysql-container > mysql.log 2>&1
```

2. **Process Monitoring**
```bash
# MySQL processes
docker exec mysql-container mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" processlist

# SQL Server processes
docker exec sqlserver-container /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U sa -P "${SQL_SA_PASSWORD}" \
    -Q "SELECT * FROM sys.dm_exec_sessions"
```

3. **Network Debug**
```bash
# Install network tools
docker exec -it mysql-container apt-get update
docker exec -it mysql-container apt-get install -y net-tools iputils-ping

# Test connectivity
docker exec -it mysql-container ping sqlserver-container
```

### Recovery Procedures

1. **Corrupt Database Recovery**
```bash
# MySQL
mysqlcheck -r -u root -p"${MYSQL_ROOT_PASSWORD}" database_name

# SQL Server
DBCC CHECKDB ([YourDB]) WITH REPAIR_ALLOW_DATA_LOSS
```

2. **Lost Root Password**
```bash
# MySQL
docker-compose down
docker-compose up -d mysql --skip-grant-tables

# SQL Server
docker-compose down
docker-compose up -d sqlserver -e "MSSQL_SETUP_SA_PASSWORD=NewPassword123"
```

3. **Volume Recovery**
```bash
# Backup volume
docker run --rm --volumes-from mysql-container \
    -v $(pwd):/backup alpine tar cvf /backup/volume_backup.tar /var/lib/mysql

# Restore volume
docker run --rm --volumes-from mysql-container \
    -v $(pwd):/backup alpine bash -c "cd / && tar xvf /backup/volume_backup.tar"
``` 