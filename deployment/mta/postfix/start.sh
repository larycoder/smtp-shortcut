#!/bin/bash

# CONFIGURATION SECTION
POSTFIX_HOME='/home/postfix';
POSTFIX_TARGET='/home/postfix';

# LEGACY SECTION
function usage()
{
    echo """
    Usage: $0 [MAIN | RELAY | SUBMIT]

    MAIN: start mailbox SMTP server (smtp_sc-mta-postfix)
    RELAY: start relay SMTP server (smtp_sc-mta-relay-postfix)
    SUBMIT: start submission SMTP server (smtp_sc-mta-submit-postfix)
    """;
}

function generate_file() # <TYPE> <FILE> <DOCKER_NAME>
{
    echo "Generate file: $2"; TYPE=$1; FILE=$2; DOC_NAME=$3;
    ./postfix-conf.sh $TYPE $FILE > tmp.txt;
    docker cp ./tmp.txt $DOC_NAME:/;
    docker exec $DOC_NAME cp /tmp.txt $FILE;
}

main='/etc/postfix/main.cf';
master='/etc/postfix/master.cf';
sql_virtual_mailbox_domains='/etc/postfix/mysql-virtual-mailbox-domains.cf';
sql_virtual_mailbox_maps='/etc/postfix/mysql-virtual-mailbox-maps.cf';
sql_virtual_alias_maps='/etc/postfix/mysql-virtual-alias-maps.cf';
sql_virtual_email2email='/etc/postfix/mysql-virtual-email2email.cf';

TYPE=${1^^};

SMTP_SERVER='localhost';
NAME='smtp_sc-mta-postfix';
XTR_CONFIG='';

if [[ $TYPE == 'MAIN' ]]; then
    NAME='smtp_sc-mta-postfix';
    SMTP_SERVER='localhost';

    PROG='/usr/libexec/postfix/virtual';
    MAILBOX='/var/mail';
    XTR_CONFIG=" \
        --volume $POSTFIX_HOME$PROG:$POSTFIX_TARGET$PROG \
        --volume $POSTFIX_HOME$MAILBOX:$POSTFIX_TARGET$MAILBOX \
    ";
elif [[ $TYPE == 'RELAY' ]]; then
    NAME='smtp_sc-mta-relay-postfix';
    SMTP_SERVER='smtp_sc-mta-postfix';
elif [[ $TYPE == 'SUBMIT' ]]; then
    NAME='smtp_sc-mta-submit-postfix';
    SMTP_SERVER='smtp_sc-mta-relay-postfix';

    PROG='/usr/libexec/postfix/cleanup';
    DATA='/var/spool/postfix/data';
    XTR_CONFIG=" \
        --volume $POSTFIX_HOME$PROG:$POSTFIX_TARGET$PROG \
        --volume $POSTFIX_HOME$DATA:$POSTFIX_TARGET$DATA \
    ";
else
    echo "Could not recognize option...";
    usage;
    exit 1;
fi;

echo "Run container [$NAME]...";
if [[ $TYPE == 'SUBMIT' || $TYPE == 'MAIN' ]]; then
    docker run -d $XTR_CONFIG \
        --name $NAME \
        --network 'smtp_sc-network' \
        -e SMTP_SERVER=$SMTP_SERVER \
        -e SERVER_HOSTNAME=$NAME \
        postfix-dummy:v1;
else
    docker run -d $XTR_CONFIG \
        --name $NAME \
        --network 'smtp_sc-network' \
        -e SMTP_SERVER=$SMTP_SERVER \
        -e SERVER_HOSTNAME=$NAME \
        juanluisbaptiste/postfix:latest;
fi;

echo "";

echo "Booting time...";
while true; do
    LOG=$(docker logs $NAME | grep 'starting the Postfix mail system')
    if [[ $LOG != "" ]]; then
        break;
    fi;
    sleep 1;
done;

echo "";

echo "Pre-configuration...";
if [[ $TYPE == 'MAIN' ]]; then
    docker exec $NAME bash -c 'chown -R postfix /home/postfix';
    docker exec $NAME bash -c 'chown -R 1000 /home/postfix/var/mail';
elif [[ $TYPE == 'SUBMIT' ]]; then
    docker exec $NAME bash -c 'chown -R postfix /home/postfix';
else
    docker exec $NAME bash -c 'apk update && apk add postfix-mysql';
fi;

echo "";

echo "Setup configuration file [TYPE: $TYPE]...";
if [[ $TYPE == 'MAIN' ]]; then
    generate_file $TYPE $main $NAME;
    generate_file $TYPE $sql_virtual_mailbox_domains $NAME;
    generate_file $TYPE $sql_virtual_mailbox_maps $NAME;
    generate_file $TYPE $sql_virtual_alias_maps $NAME;
    generate_file $TYPE $sql_virtual_email2email $NAME;
elif [[ $TYPE == 'RELAY' ]]; then
    generate_file $TYPE $main $NAME;
elif [[ $TYPE == 'SUBMIT' ]]; then
    generate_file $TYPE $main $NAME;
    generate_file $TYPE $master $NAME;
fi;
rm tmp.txt;

echo "";

echo "Reload postfix at: $NAME";
if [[ $TYPE == 'SUBMIT' ]]; then
    docker restart $NAME;
else
    docker exec $NAME postfix reload;
fi

echo "";

echo "Done.";
