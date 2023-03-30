#!/bin/bash

MAILBOX='/home/hieplnc/postfix/var/mail/';

echo "Run dovecot container..."
docker run -d \
    --network smtp_sc-network \
    --name 'smtp_sc-mailbox-dovecot' \
    --volume $MAILBOX:'/srv/mail' \
    dovecot/dovecot:latest

echo "";

echo "Waiting for server up...";
sleep 1;

echo "";

echo "Setup dovecot configuration...";

echo "";

main_conf='/etc/dovecot/dovecot.conf';
sql_conf='/etc/dovecot/dovecot-sql.conf.ext';

echo "Generate file: $main_conf"; FILE=$main_conf;
./dovecot-conf.sh $FILE > tmp.txt;
docker cp ./tmp.txt smtp_sc-mailbox-dovecot:/;
docker exec smtp_sc-mailbox-dovecot cp /tmp.txt $FILE;

echo "Generate file: $main_conf"; FILE=$sql_conf;
./dovecot-conf.sh $FILE > tmp.txt;
docker cp ./tmp.txt smtp_sc-mailbox-dovecot:/;
docker exec smtp_sc-mailbox-dovecot cp /tmp.txt $FILE;

rm tmp.txt;

echo "";

echo "Reload dovecot configuration...";
docker exec smtp_sc-mailbox-dovecot dovecot reload;

echo "";

echo "Done.";
