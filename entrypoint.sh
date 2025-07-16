#!/bin/bash

# Chờ MySQL sẵn sàng trước khi chạy migrate + start
chmod +x /app/wait-for-it.sh
/app/wait-for-it.sh "$MYSQL_HOST:$MYSQL_PORT" -t 300 -- echo "MySQL is ready"

# Chạy migrate nếu cần
npm run migrate

# Khởi chạy ứng dụng
npm start
