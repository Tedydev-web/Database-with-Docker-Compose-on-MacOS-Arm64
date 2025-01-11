#!/bin/bash
set -e

source .env

echo "🔍 Kiểm tra health các services..."

check_mysql() {
    echo "Checking MySQL..."
    docker exec mysql-container mysqladmin ping -h localhost -u root -p"$MYSQL_ROOT_PASSWORD" || return 1
}

check_sqlserver() {
    echo "Checking SQL Server..."
    docker exec sqlserver-container /opt/mssql-tools/bin/sqlcmd \
        -S localhost -U sa -P "$SQL_SA_PASSWORD" \
        -Q "SELECT @@VERSION" || return 1
}

check_prometheus() {
    echo "Checking Prometheus..."
    curl -s http://localhost:9090/-/healthy || return 1
}

check_grafana() {
    echo "Checking Grafana..."
    curl -s http://localhost:3000/api/health || return 1
}

check_elasticsearch() {
    echo "Checking Elasticsearch..."
    curl -s http://localhost:9200/_cluster/health || return 1
}

# Run all checks
check_mysql
check_sqlserver
check_prometheus
check_grafana
check_elasticsearch

echo "✅ Tất cả services đều hoạt động bình thường!" 