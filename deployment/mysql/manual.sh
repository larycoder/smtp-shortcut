#!/bin/bash

deli="=============================================="

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

echo $deli

echo """
# Prepare MySql Schema following file: mailserver.sql
docker exec -i smtp_sc-mysql mysql -uroot -proot < ./mailserver.sql
"""

echo $deli

echo """
# Debugging MySql => we use PHPMyadmin
docker run -d --rm \
    --network smtp_sc-network \
    --name smtp_sc-phpmyadmin \
    -e PMA_HOST='smtp_sc-mysql' \
    -p 8080:80 \
    phpmyadmin/phpmyadmin:latest
"""

echo $deli

echo """
# Caching and log Mysql request (use mysql client connect to database as root)
# Enable general_log to \`general_log\` table
SET global log_output = 'table';

# Enable log
SET global general_log = 1;

# Query log and decode to utf-8
select a.*, convert(a.argument using utf8) from mysql.general_log a\\G;

# Disable log
SET global general_log = 0;
"""
