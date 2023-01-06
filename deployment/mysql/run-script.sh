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
