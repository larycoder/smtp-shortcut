#!/bin/bash

conf='/var/www/html/config/config.docker.inc.php';

echo "Run roundcube container...";
docker run -d \
    --name 'smtp_sc-webmail-roundcube' \
    --network 'smtp_sc-network' \
    -e ROUNDCUBEMAIL_DEFAULT_HOST='smtp_sc-mailbox-dovecot' \
    -e 'ROUNDCUBEMAIL_SMTP_SERVER=smtp_sc-mta-submit-postfix' \
    -p 8000:80 \
    roundcube/roundcubemail:latest;

echo "";

echo "Booting time..."
while true; do
    LOG=$(docker logs smtp_sc-webmail-roundcube 2>&1 >/dev/null | grep 'apache2 -D FOREGROUND');
    if [[ $LOG != '' ]]; then
        break;
    fi;
    sleep 1;
done;

echo "";

echo "Generate file: $conf"; FILE=$conf;
./roundcube-conf.sh $FILE > tmp.txt;
docker cp tmp.txt smtp_sc-webmail-roundcube:/;
docker exec smtp_sc-webmail-roundcube cp /tmp.txt $FILE;
rm tmp.txt;

echo "";

echo "Done.";
