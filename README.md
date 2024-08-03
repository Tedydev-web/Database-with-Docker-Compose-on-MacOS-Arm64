Cài đặt MySQL, PHPMyAdmin, SQLServer 2022 với Docker Compose
#---------------------------------------------------------#
#Step 1: Tạo file deployment.yml với nội dung như trên
#---------------------------------------------------------#
#Step 2: Chạy các lệnh sau:

    - docker-compose -f deployment.yml down
    
    - docker-compose -f deployment.yml up -d
