#!/bin/bash

echo """
# Setup MySQL as centralized configuration mail servers
# Username: root
# Password: root

docker run -d \
    --network smtp_sc-network \
    --name smtp_sc-mysql \
    -e MYSQL_ROOT_PASSWORD='root' \
    mysql:latest
"""

echo """
# Prepare MySql Schema following file: mailserver.sql
docker exec -i smtp_sc-mysql mysql -uroot -proot < ./mailserver.sql
"""

echo """
# Debugging MySql => we use PHPMyadmin
docker run -d --rm \
    --network smtp_sc-network \
    --name smtp_sc-phpmyadmin \
    -e PMA_HOST='smtp_sc-mysql' \
    -p 8080:80 \
    phpmyadmin/phpmyadmin:latest
"""
