#!/bin/bash

PMA_PORT=8080
SQL_PORT=33006

echo "Start mysql server...";
docker run -d \
    --network smtp_sc-network \
    -p $SQL_PORT:3306 \
    --name smtp_sc-mysql \
    -e MYSQL_ROOT_PASSWORD='root' \
    mysql:latest;

echo "";

echo "Waiting for everything up.";
while true; do
    LOG=$(docker logs smtp_sc-mysql 2>&1 >/dev/null | grep -e '/var/run/mysqld/mysqld.sock' | grep 'port: 3306')
    if [[ $LOG != '' ]]; then
        break;
    fi;
    sleep 1;
done;
sleep 1;

docker exec -i smtp_sc-mysql mysql -uroot -proot < ./mailserver.sql

echo "";

echo "Start phpmyadmin server...";
docker run -d --rm \
    --network smtp_sc-network \
    --name smtp_sc-phpmyadmin \
    -e PMA_HOST='smtp_sc-mysql' \
    -p $PMA_PORT:80 \
    phpmyadmin/phpmyadmin:latest;

echo "Done.";
