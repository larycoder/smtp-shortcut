#!/bin/bash

function usage()
{
    echo """
    Usage: $0 [MAIN | RELAY | SUBMIT | ALL]

    MAIN: Clear main MTA container ('smtp_sc-mta-postfix')
    RELAY: Clear relay MTA container ('smtp_sc-mta-relay-postfix')
    SUBMIT: Clear submit MTA container ('smtp_sc-mta-submit-postfix')
    ALL: Clear all MTA containers

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
    clear_container 'smtp_sc-mta-relay-postfix';
elif [[ $1 == 'SUBMIT' ]]; then
    confirm;
    clear_container 'smtp_sc-mta-submit-postfix';
elif [[ $1 == 'ALL' ]]; then
    confirm;
    clear_container 'smtp_sc-mta-postfix';
    clear_container 'smtp_sc-mta-relay-postfix';
    clear_container 'smtp_sc-mta-submit-postfix';
else
    echo "Could not recognize option...";
    usage;
    exit 1;
fi