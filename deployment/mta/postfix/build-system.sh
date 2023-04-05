#!/bin/bash

# CONFIGURE SECTION
SUBMIT_HOST='smtp_sc-mta-submit-postfix';
RELAY_HOST='smtp_sc-mta-relay-postfix-<NUM>';
MAIN_HOST='smtp_sc-mta-postfix';

NUM=$1;

# FUNCTION SECTION
function usage()
{
    echo """
    Usage: $0 <RELAY_NUM>

    RELAY_NUM: number of expected relay in pipeline.

    NOTE:
    - This script is for single host building only.
    """;
}

function prepare_machines()
{
    echo "";
    echo "######### CLEAR ALL #########";
    ./clean.sh ALL;

    echo "";
    echo "######### START SUBMIT #########";
    ./start.sh SUBMIT;

    echo "";
    echo "######### START MAIN #########";
    ./start.sh MAIN;


    for i in $(seq 1 $NUM); do
        echo "";
        echo "######### START RELAY $i #########";
        ./start.sh RELAY $i
    done;
}

function link_machines()
{
    PREV=${RELAY_HOST/'<NUM>'/'1'};
    for i in $(seq 2 $NUM); do
        echo "";
        echo "######### LINK HOST ($PREV) TO (${RELAY_HOST/'<NUM>'/$i}) #########";
        ./link.sh $PREV ${RELAY_HOST/'<NUM>'/$i};
        PREV="${RELAY_HOST/'<NUM>'/$i}";
    done;

    echo "";
    echo "######### LINK HOST ($SUBMIT_HOST) TO (${RELAY_HOST/'<NUM>'/'1'}) #########";
    ./link.sh $SUBMIT_HOST ${RELAY_HOST/'<NUM>'/'1'};

    echo "";
    echo "######### LINK HOST (${RELAY_HOST/'<NUM>'/"$NUM"}) TO ($MAIN_HOST) #########";
    ./link.sh ${RELAY_HOST/'<NUM>'/"$NUM"} $MAIN_HOST;
}

# MAIN SECTION
if [[ $# != 1 ]]; then
    usage;
    exit 1;
fi;

prepare_machines;
link_machines;
