#!/bin/bash

# DATA SECTION
TARGET=''
RELAY=''

# FUNCTION SECTION
function usage()
{
    echo """
    Usage: $0 TARGET FORWARD

    The script re-configure target SMTP server to relay its
    mail to another SMTP server.

    [PARAMETERS]

    TARGET: name of SMTP container for relaying mail from.
    FORWARD: name of SMTP container for relaying mail to.
    """
}

function validate() # $1 - container name
{
    NAME=$1;
    for container in $(docker ps --format '{{.Names}}'); do
        if [[ $container == $NAME ]]; then
            echo "True";
            return;
        fi;
    done;
    echo "False";
}

function update() # $1 - target, $2 - forward
{
    TARGET=$1;
    FORWARD=$2;
    CONFIG="/etc/postfix/main.cf";
    RELAY_CMD="sed -i \"s/relayhost = \[.*\]/relayhost = \[$2\]/g\" $CONFIG";
    HOST_CMD="sed -i \"s/myhostname = .*/myhostname = $1/g\" $CONFIG";
    RELAY_EVAL="sed -n \"/relayhost/p\" $CONFIG"
    HOST_EVAL="sed -n \"/myhostname/p\" $CONFIG"
    docker exec $1 bash -c "$RELAY_CMD";
    docker exec $1 bash -c "$HOST_CMD";
    echo """New updated parameter:
    $(docker exec $1 bash -c "$RELAY_EVAL")
    $(docker exec $1 bash -c "$HOST_EVAL")
    """;
    echo "Reload new parameter...";
    docker exec $1 bash -c "postfix reload";
}

# MAIN SECTION
if [[ $# != 2 ]]; then
    usage;
    exit 0;
fi;

TARGET=$1;
FORWARD=$2;

if [[ $(validate $TARGET) == "False" ]]; then
    echo "Target container ($TARGET) is not existed";
    exit 0;
elif [[ $(validate $FORWARD) == "False" ]]; then
    echo "Forward container ($FORWARD) is not existed";
    exit 0;
fi;

echo "Updating container ($TARGET)...";
update $TARGET $FORWARD
echo "Done."
