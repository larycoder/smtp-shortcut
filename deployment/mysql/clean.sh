#!/bin/bash
echo -n """
This script is used to clear all setup made by start script !!!

Warning:
This script is not safety. Do you want to continue ? [N/y] """;

read answer;
answer=${answer:0:1};

if [[ ${answer^^} == 'N' ]];
then
    echo "OK stop here";
    exit 0;
elif [[ ${answer^^} == 'Y' ]];
then
    echo "Continue";
else
    echo "Could not recognize answer...";
    exit 1;
fi;

echo "Stop container...";
docker stop smtp_sc-phpmyadmin smtp_sc-mysql;

echo "";

echo "Remove container...";
docker rm smtp_sc-phpmyadmin smtp_sc-mysql;

echo "";

echo "Done.";
