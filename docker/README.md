# Hướng Dẫn Sử Dụng Docker cho Database Development

## Mục Lục
1. [Tổng Quan](#tổng-quan)
2. [Cấu Trúc Thư Mục](#cấu-trúc-thư-mục)
3. [Cài Đặt Ban Đầu](#cài-đặt-ban-đầu)
4. [MySQL](#mysql)
5. [SQL Server](#sql-server)
6. [Redis](#redis)
7. [Backup & Restore](#backup--restore)
8. [Monitoring & Logs](#monitoring--logs)
9. [Xử Lý Sự Cố](#xử-lý-sự-cố)
10. [Tối Ưu Hiệu Năng](#tối-ưu-hiệu-năng)

## Tổng Quan

Hệ thống bao gồm 3 database chính:
- MySQL 8.0 (với PHPMyAdmin)
- SQL Server 2022
- Redis (latest)

Được tối ưu cho:
- MacOS ARM64 (M1/M2)
- 16GB RAM
- Có thể di chuyển dễ dàng giữa MacOS và Windows

## Cấu Trúc Thư Mục
```
docker/
├── mysql/                 # MySQL và PHPMyAdmin
│   ├── docker-compose.yml # Cấu hình container
│   ├── backup.sh         # Script backup
│   ├── backup/           # Thư mục chứa file backup
│   └── logs/             # Log của MySQL
├── sqlserver/            # Microsoft SQL Server
│   ├── docker-compose.yml
│   ├── backup.sh
│   ├── backup/
│   └── logs/
├── redis/               # Redis Cache
│   ├── docker-compose.yml
│   ├── backup/
│   └── logs/
└── .env                # Biến môi trường
```

## Cài Đặt Ban Đầu

### 1. Yêu Cầu Hệ Thống
- Docker Desktop cho MacOS
- Ít nhất 16GB RAM
- Ít nhất 40GB ổ cứng trống

### 2. Chuẩn Bị Môi Trường
```bash
# Clone repository
git clone <repository_url>
cd docker

# Tạo file .env
cp .env.example .env

# Tạo các thư mục cần thiết
mkdir -p mysql/logs mysql/backup
mkdir -p sqlserver/logs sqlserver/backup
mkdir -p redis/logs redis/backup
```

### 3. Cấu Hình Biến Môi Trường (.env)
```env
# MySQL
MYSQL_ROOT_PASSWORD=TedyDev@2310    # Mật khẩu root
MYSQL_DATABASE=master         # Database mặc định
MYSQL_USER=sa                # User mặc định
MYSQL_PASSWORD=TedyDev@2310        # Mật khẩu user
MYSQL_MAX_CONNECTIONS=1000         # Số kết nối tối đa
MYSQL_BUFFER_POOL_SIZE=4G          # Bộ nhớ đệm

# SQL Server
SQL_SA_PASSWORD=TedyDev@2310       # Mật khẩu SA
SQL_SERVER_MAX_MEMORY=4096         # Giới hạn RAM (MB)

# Redis
REDIS_MAX_MEMORY=2gb               # Giới hạn RAM
REDIS_MAX_CONNECTIONS=500          # Số kết nối tối đa
```

## Biến Môi Trường (.env)

### Common Configuration
```env
TZ=Asia/Ho_Chi_Minh              # Múi giờ
DATA_PATH_HOST=./data            # Thư mục chứa dữ liệu
```

### MySQL Configuration
```env
MYSQL_ROOT_PASSWORD=TedyDev@2310 # Mật khẩu root
MYSQL_DATABASE=master      # Database mặc định
MYSQL_USER=sa             # User mặc định
MYSQL_PASSWORD=TedyDev@2310     # Mật khẩu user
MYSQL_PORT=3306                 # Port MySQL
MYSQL_MAX_CONNECTIONS=1000      # Số kết nối tối đa
MYSQL_WAIT_TIMEOUT=3600        # Thời gian timeout (giây)
MYSQL_BUFFER_POOL_SIZE=4G      # Bộ nhớ đệm InnoDB
MYSQL_SSL_ENABLED=true         # Bật SSL
MYSQL_SSL_CERT=/certs/server-cert.pem  # Certificate
MYSQL_SSL_KEY=/certs/server-key.pem    # Private key
MYSQL_SSL_CA=/certs/ca.pem             # CA certificate
```

### PHPMyAdmin Configuration
```env
PMA_PORT=8088                  # Port PHPMyAdmin
PMA_MEMORY_LIMIT=512M         # Giới hạn bộ nhớ
PMA_UPLOAD_LIMIT=2048M        # Giới hạn upload
PMA_MAX_EXECUTION_TIME=600    # Thời gian thực thi tối đa
```

### SQL Server Configuration
```env
SQL_SA_PASSWORD=TedyDev@2310  # Mật khẩu SA
SQL_PORT=1433                # Port SQL Server
SQL_SERVER_MAX_MEMORY=4096   # Giới hạn RAM (MB)
SQL_COLLATION=Vietnamese_CI_AS # Collation
SQL_BACKUP_DIR=/backup       # Thư mục backup
SQL_LOG_DIR=/var/log/mssql   # Thư mục log
```

### Redis Configuration
```env
REDIS_PORT=6379              # Port Redis
REDIS_PASSWORD=TedyDev@2310  # Mật khẩu Redis
REDIS_MAX_MEMORY=2gb        # Giới hạn RAM
REDIS_MAX_CONNECTIONS=500   # Số kết nối tối đa
REDIS_SAVE_FREQUENCY="60 1" # Tần suất lưu RDB (60s nếu có >=1 thay đổi)
REDIS_LOG_LEVEL=warning    # Mức độ log
REDIS_MAXMEMORY_POLICY=allkeys-lru # Chính sách xóa key khi đầy bộ nhớ
```

### Backup Configuration
```env
BACKUP_RETENTION_DAYS=7     # Số ngày giữ backup
BACKUP_TIME="0 2 * * *"     # Lịch backup (2 AM mỗi ngày)
BACKUP_PATH=./backups       # Thư mục chứa backup
```

### SSL Certificates
```env
SSL_COUNTRY=VN             # Quốc gia
SSL_STATE=HoChiMinh        # Tỉnh/Thành phố
SSL_LOCALITY=HoChiMinh     # Địa phương
SSL_ORGANIZATION=TedyDev   # Tổ chức
SSL_ORGANIZATIONAL_UNIT=Development # Đơn vị
SSL_COMMON_NAME=localhost  # Tên miền
```

### Tạo SSL Certificates

Để tạo SSL certificates cho MySQL, chạy script sau:
```bash
#!/bin/bash
# generate_certs.sh

mkdir -p certs
cd certs

# Tạo CA key và certificate
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 365000 \
    -key ca-key.pem \
    -out ca.pem \
    -subj "/C=${SSL_COUNTRY}/ST=${SSL_STATE}/L=${SSL_LOCALITY}/O=${SSL_ORGANIZATION}/OU=${SSL_ORGANIZATIONAL_UNIT}/CN=${SSL_COMMON_NAME}"

# Tạo server key và certificate
openssl req -newkey rsa:2048 -nodes -days 365000 \
    -keyout server-key.pem \
    -out server-req.pem \
    -subj "/C=${SSL_COUNTRY}/ST=${SSL_STATE}/L=${SSL_LOCALITY}/O=${SSL_ORGANIZATION}/OU=${SSL_ORGANIZATIONAL_UNIT}/CN=${SSL_COMMON_NAME}"
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days 365000 \
    -CA ca.pem -CAkey ca-key.pem -set_serial 01 \
    -out server-cert.pem

# Set permissions
chmod 600 server-key.pem ca-key.pem
```

### Khởi Tạo Ban Đầu

1. Copy file `.env.example` thành `.env`:
```bash
cp .env.example .env
```

2. Tạo SSL certificates (nếu cần):
```bash
./generate_certs.sh
```

3. Tạo các thư mục cần thiết:
```bash
mkdir -p {mysql,sqlserver,redis}/{backup,logs}
mkdir -p certs
```

4. Khởi động services:
```bash
# Chỉ MySQL + PHPMyAdmin
cd mysql && docker-compose up -d

# Chỉ SQL Server
cd sqlserver && docker-compose up -d

# Chỉ Redis
cd redis && docker-compose up -d
```

## MySQL

### Khởi Động MySQL
```bash
cd mysql
docker-compose up -d
```

### Truy Cập
- MySQL:
  - Host: localhost
  - Port: 3306
  - User: root
  - Password: TedyDev@2310 (hoặc giá trị trong .env)

- PHPMyAdmin:
  - URL: http://localhost:8088
  - Server: mysql
  - User: root
  - Password: TedyDev@2310

### Lệnh Hữu Ích
```bash
# Kiểm tra logs
docker logs mysql-container

# Truy cập MySQL CLI
docker exec -it mysql-container mysql -uroot -p

# Restart container
docker-compose restart mysql

# Dừng MySQL
docker-compose stop mysql

# Xóa container và data
docker-compose down -v
```

## SQL Server

### Khởi Động SQL Server
```bash
cd sqlserver
docker-compose up -d
```

### Truy Cập
- Host: localhost
- Port: 1433
- User: sa
- Password: TedyDev@2310 (hoặc giá trị trong .env)

### Lệnh Hữu Ích
```bash
# Kiểm tra logs
docker logs sqlserver-container

# Truy cập SQL Server CLI
docker exec -it sqlserver-container /opt/mssql-tools/bin/sqlcmd -U sa -P TedyDev@2310

# Restart container
docker-compose restart sqlserver

# Dừng SQL Server
docker-compose stop sqlserver
```

## Redis

### Khởi Động Redis
```bash
cd redis
docker-compose up -d
```

### Truy Cập
- Host: localhost
- Port: 6379
- Không có authentication mặc định

### Lệnh Hữu Ích
```bash
# Kiểm tra logs
docker logs redis-container

# Truy cập Redis CLI
docker exec -it redis-container redis-cli

# Kiểm tra Redis info
docker exec -it redis-container redis-cli info

# Xóa tất cả keys
docker exec -it redis-container redis-cli FLUSHALL
```

## Backup & Restore

### MySQL Backup
```bash
# Backup thủ công
cd mysql
./backup.sh

# Lập lịch backup tự động (crontab)
0 2 * * * /path/to/mysql/backup.sh
```

### SQL Server Backup
```bash
# Backup thủ công
cd sqlserver
./backup.sh

# Restore database
docker exec -it sqlserver-container /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U sa -P TedyDev@2310 \
    -Q "RESTORE DATABASE [DBName] FROM DISK = N'/backup/backup_file.bak'"
```

### Redis Backup
Redis tự động lưu RDB snapshot mỗi 60 giây nếu có ít nhất 1 thay đổi.
File dump.rdb được lưu trong volume redis_data.

## Monitoring & Logs

### Kiểm Tra Tài Nguyên
```bash
# Xem tài nguyên sử dụng
docker stats

# Xem tất cả container
docker ps -a
```

### Xem Logs
```bash
# MySQL logs
tail -f mysql/logs/mysql.log

# SQL Server logs
tail -f sqlserver/logs/errorlog

# Redis logs
tail -f redis/logs/redis.log
```

## Xử Lý Sự Cố

### 1. Container Không Khởi Động
```bash
# Kiểm tra logs
docker logs <container_name>

# Kiểm tra status
docker ps -a

# Restart container
docker-compose restart <service_name>
```

### 2. Lỗi Kết Nối
- Kiểm tra ports đã được expose
- Kiểm tra network
- Kiểm tra credentials

### 3. Hết Bộ Nhớ
```bash
# Xóa unused images
docker system prune -a

# Xóa unused volumes
docker volume prune
```

## Tối Ưu Hiệu Năng

### MySQL
- Điều chỉnh `innodb_buffer_pool_size` trong .env
- Giảm `max_connections` nếu RAM thấp
- Tắt `performance_schema` nếu không cần

### SQL Server
- Điều chỉnh `MSSQL_MEMORY_LIMIT_MB`
- Sử dụng indexes hợp lý
- Regular maintenance jobs

### Redis
- Điều chỉnh `maxmemory`
- Sử dụng `maxmemory-policy` phù hợp
- Monitoring với redis-cli info

## Lưu Ý Quan Trọng
1. Luôn backup dữ liệu trước khi thay đổi cấu hình
2. Kiểm tra logs thường xuyên
3. Chỉ chạy các service cần thiết
4. Cập nhật images thường xuyên
5. Không public ports ra internet nếu không cần thiết

