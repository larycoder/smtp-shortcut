#!/bin/bash

# CONFIGURE SECTION
SUBMIT_HOST='smtp_sc-mta-submit-postfix';
DELIVER_HOST='smtp_sc-mta-postfix';
TAG='DELIVER\|SUBMIT\|SUBJECT';

LOG=$1;
LOG_CLEAN="echo -n '' > $LOG";

# FUNCTION SECTION
function usage()
{
    echo """
    Usage: $0 <LOG_FILE>

    LOG_FILE: path to log file to save collected log.
    """;
}

function clean()
{
    if [[ ! -f $LOG ]]; then
        usage;
        echo "";
        echo "The log file ($LOG) is not valid file.";
        exit 1;
    fi;
    eval $LOG_CLEAN;
}

function collect() # <HOST> <TAG>
{
    HOST=$1;
    TAG=$2;

    docker logs $HOST | grep "\[$TAG\]" | \
        sed "s/^.*warning: \[/[/g" >> $LOG;
}

# MAIN SECTION
if [[ $# != 1 ]]; then
    usage;
    exit 1;
fi;

clean;
collect $SUBMIT_HOST $TAG;
collect $DELIVER_HOST $TAG;
