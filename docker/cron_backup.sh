#!/bin/bash

# Đường dẫn tới thư mục docker
DOCKER_DIR="/Users/tedydev/Workhome/Code/GitHub/Database-with-Docker-Compose-on-MacOS-Arm64/docker"

# Di chuyển vào thư mục docker
cd $DOCKER_DIR

# Ghi log thời gian bắt đầu
echo "=== Backup started at $(date) ===" >> "$DOCKER_DIR/backup.log"

# Thực thi backup script
./backup.sh >> "$DOCKER_DIR/backup.log" 2>&1

# Xóa các backup cũ hơn 7 ngày
find "$DOCKER_DIR/backups" -mtime +7 -delete

# Ghi log thời gian kết thúc
echo "=== Backup completed at $(date) ===" >> "$DOCKER_DIR/backup.log"
