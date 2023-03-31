#!/bin/bash

# CONFIGURATION SECTION
SOURCE='../../../postfix/postfix-3.6.7';
TARGET='postfix-installation';
BASE='code_builder';

# FUNCTION SECTION
function usage()
{
    echo """
    Usage: $0 [SOURCE] [TARGET]

    SOURCE: location of postfix source directory,
               default is \"$SOURCE\".
    TARGET: location of postfix installer,
             default is \"$TARGET\".
    """;
}

# Remove all content but not directory itself
function content_clean() # $1 path-to-dir
{
    for i in $(ls -a $1); do
        if [[ $i != '.' && $i != '..' ]]; then
            rm -rf "$1/$i";
        fi;
    done;
}

function start()
{
    content_clean $TARGET
    docker run --rm -d \
        --volume $SOURCE:/home
        -t --name $BASE debian:buster bash
}

function end()
{
    ;
}

# MAIN
if [[ $# != 0 && $# != 2 ]]; then
    usage;
    exit 0;
fi;

if [[ $# == 2 ]]; then
    INSTALLER=$1;
    PACKAGE=$2;
fi;

tmp_prepare;
clean;
package;
tmp_clear;
