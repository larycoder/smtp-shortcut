#!/bin/bash

# CONFIGURATION SECTION
BASE='build_tmp';
PACKAGE='postfix.tar.gz';
INSTALLER="$POSTFIX_TEST_DIR/home/postfix";

# FUNCTION SECTION
function usage()
{
    echo """
    Usage: $0 [INSTALLER] [PACKAGE]

    INSTALLER: location of postfix installation directory,
               default is \"postfix-installation\".
    PACKAGE: package is compressed file of full folder,
             default is \"postfix.tar.gz\".
    """;
}

function tmp_prepare()
{
    mkdir -p "$BASE";
    # add base
    for i in $(ls $INSTALLER); do
        cp -r "$INSTALLER/$i" "$BASE/"
    done;
    # add evil trick program
    if [[ ! -f '../../../evil-tricks/bin/data-dump' ]]; then
        CWD=$(pwd);
        cd '../../../evil-tricks';
        ./re-build.sh
        cd $CWD;
    fi;
    cp '../../../evil-tricks/bin/data-dump' $BASE/usr/libexec/postfix/data-dump;
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

function clean()
{
    content_clean "$BASE/var/spool/postfix/pid";
    content_clean "$BASE/var/mail";
    content_clean "$BASE/var/lib/postfix";
    # For capture log from container
    echo 'maillog_file = /dev/stdout' >> "$BASE/etc/postfix/main.cf";
}

function package()
{
    mv "$BASE" "postfix";
    tar -czvf "$PACKAGE" "postfix";
    mv "postfix" "$BASE";
}

function tmp_clear()
{
    rm -rf $BASE;
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
