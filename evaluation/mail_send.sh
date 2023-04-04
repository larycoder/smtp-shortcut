#!/bin/bash

# DATA SECTION
MAIL_NUM=$1;
MAIL_TIME=$2;
MAIL_PATH='data';

CONTAINER="smtp_sc-mta-submit-postfix";
SENDER="admin@smtp-sc.domain";
RECEIVER="hieplnc.m20ict@smtp-sc.domain";

# FUNCTION SECTION
function usage()
{
    echo """
    Usage: $0 <NUMBER> <TIME>

    NUMBER: number of mail send to mail submission.
    TIME: the delay time between each send (second).

    **NOTE**:
    - Each sender will be a background process and sent
      in parallel.
    - Mail get from \"data\" directory and decided by
      MIN(mail_in_dir, mail_number).
    """;
}

function send() # <MAIL_PATH>
{
    cat $1 | docker exec -i $CONTAINER \
        sendmail -f $SENDER $RECEIVER;
}

# MAIN SECTION
if [[ $# != 2 ]]; then
    usage;
    exit 1;
fi;

for i in $(seq 1 $MAIL_NUM); do
    MY_PATH="$MAIL_PATH/mail_$i";
    if [[ -f $MY_PATH ]]; then
        echo "[SEND] mail path: $MY_PATH";
        send $MY_PATH &
        echo "[SLEP] time: $MAIL_TIME";
        sleep $MAIL_TIME;
    fi;
done;
echo "[MESG] Done.";
