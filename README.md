# Hướng Dẫn Cài Đặt MySQL, PHPMyAdmin và SQL Server 2022 với Docker Compose

## Mô Tả
#### Hướng dẫn này sẽ giúp bạn cài đặt MySQL, PHPMyAdmin và SQL Server 2022 trên macOS sử dụng Docker Compose.

## Các Bước Cài Đặt

### Bước 1: Tạo File `deployment.yml`

#### Tạo một file có tên `deployment.yml` và thêm nội dung sau vào file:

```
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: my_database
      MYSQL_USER: user
      MYSQL_PASSWORD: user_password
    ports:
      - "3306:3306"
    networks:
      - my_network

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    environment:
      PMA_HOST: mysql
      PMA_PORT: 3306
    ports:
      - "8080:80"
    networks:
      - my_network

  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: sqlserver
    environment:
      SA_PASSWORD: "YourStrong!Passw0rd"
      ACCEPT_EULA: "Y"
    ports:
      - "1433:1433"
    networks:
      - my_network

networks:
  my_network:
    driver: bridge

```

### Bước 2: Chạy Các Lệnh Docker Compose

#### Dừng và xóa các container hiện tại
```
docker-compose -f deployment.yml down
```
#### Khởi động lại các container
```
docker-compose -f deployment.yml up -d
```

### Ghi Chú
#### MySQL: Cơ sở dữ liệu MySQL với thông tin cấu hình như root_password, my_database, user, và user_password.
#### PHPMyAdmin: Giao diện web để quản lý MySQL.
#### SQL Server 2022: Cơ sở dữ liệu SQL Server với mật khẩu YourStrong!Passw0rd.

