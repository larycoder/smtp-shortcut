#!/bin/bash

function usage()
{
    echo """
    Usage: $0 [MAIN | RELAY [NAME] | SUBMIT | EXT | ALL]

    MAIN: Clear main MTA container ('smtp_sc-mta-postfix')
    RELAY: Clear all relay MTA containers ('smtp_sc-mta-relay-postfix-xxx')
    SUBMIT: Clear submit MTA container ('smtp_sc-mta-submit-postfix')
    EXT: Clear external data resource containers ('smtp_sc-mta-ext-postfix')
    ALL: Clear all MTA containers

    [Options]

    NAME: container tail name of relay server. By default, without specific name,
    all relay servers will be deleted.
    """;
}

function confirm()
{
    echo -n """
    Warning:
    This script is not safety. Do you want to continue ? [N/y] """;

    read answer;
    answer=${answer:0:1};

    if [[ ${answer^^} == 'N' || $answer == '' ]];
    then
        echo "OK stop here";
        exit 0;
    elif [[ ${answer^^} == 'Y' ]];
    then
        echo "Continue";
        echo "";
    else
        echo "Could not recognize answer...";
        exit 1;
    fi;
}

function clear_container()
{
    echo "Stop container...";
    docker stop $1;

    echo "";

    echo "Remove container...";
    docker rm $1;

    echo "";

    echo "Done.";
}

if [[ $1 == 'MAIN' ]]; then
    confirm;
    clear_container 'smtp_sc-mta-postfix';
elif [[ $1 == 'RELAY' ]]; then
    confirm;
    if [[ $2 != '' ]]; then
        clear_container "smtp_sc-mta-relay-postfix-$2";
    else
        HEAD='smtp_sc-mta-relay-postfix';
        for container in $(docker ps --format '{{.Names}}' | grep "$HEAD"); do
            clear_container "$container";
        done;
        echo "Clear all relay containers...";
    fi;
elif [[ $1 == 'SUBMIT' ]]; then
    confirm;
    clear_container "smtp_sc-mta-submit-postfix";
elif [[ $1 == 'EXT' ]]; then
    confirm;
    clear_container 'smtp_sc-mta-ext-postfix';
elif [[ $1 == 'ALL' ]]; then
    confirm;
    clear_container 'smtp_sc-mta-postfix';
    clear_container 'smtp_sc-mta-submit-postfix';
    clear_container 'smtp_sc-mta-ext-postfix';
    # Relay group containers
    HEAD='smtp_sc-mta-relay-postfix';
    for container in $(docker ps --format '{{.Names}}' | grep "$HEAD"); do
        clear_container "$container";
    done;
    echo "Clear all relay containers...";
else
    echo "Could not recognize option...";
    usage;
    exit 1;
fi
