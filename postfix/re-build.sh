#!/bin/bash

BASE=$(pwd);
SRC="$1";
TARGET=$2;
BUILD_TARGET=$TARGET;
if [[ $TARGET == '' ]]; then
    TARGET='/';
    BUILD_TARGET='//'; # go around of postfix builder error with root
fi;

#### AUXILIARY FUNCTIONS ####
usage()
{
    echo """
    Usage: $0 <PATH_TO_POSTFIX_SOURCE> [<PATH_TO_POSTFIX_TEST_DIR>]

    Automate script to build postfix from source and deploy to target.
    Default target values is '/'.
    Noting that this script need to be run by root user.

    Current target: $TARGET
    Current source: $SRC

    """;
}

pre_config()
{
    make -f Makefile.init makefiles pie=yes \
        'CCARGS=-DHAS_MYSQL -I/usr/include/mysql' \
        'AUXLIBS=-L/usr/lib/ -lmysqlclient -lz -lm' \
        command_directory=/home/postfix/usr/sbin \
        config_directory=/home/postfix/etc/postfix \
        daemon_directory=/home/postfix/usr/libexec/postfix \
        data_directory=/home/postfix/var/lib/postfix \
        mail_spool_directory=/home/postfix/var/mail \
        mailq_path=/home/postfix/usr/bin/mailq \
        manpage_directory=/home/postfix/usr/local/man \
        meta_directory=/home/postfix/etc/postfix \
        newaliases_path=/home/postfix/usr/bin/newaliases \
        queue_directory=/home/postfix/var/spool/postfix \
        sendmail_path=/home/postfix/usr/sbin/sendmail \
        shlib_directory=/home/postfix/usr/lib/postfix;
}

install() # TARGET = $1
{
    make non-interactive-package install_root=$1;
}

error_check()
{
    if [[ $? != 0 ]]; then
        echo "Got ERROR !!!";
        exit 1;
    fi;
}

#### MAIN SCRIPTS ####
usage;

if [[ $# != 2 && $# != 1 ]]; then
    exit 1;
fi;

echo """

Press <Ctrl+C> to cancel or any key for continue...
""";
read nouse;

echo "Check parameters...";
if [[ ! -d $SRC || ! -d $TARGET ]]; then
    echo "Invalid source or target parameter !!!"
    exit 1;
fi;

if [[ $TARGET != '/' ]]; then
    echo "Link TARGET to '/home/postfix'...";
    ln -s $TARGET/home/postfix /home/postfix;
    error_check;
fi;

cd $SRC;
pre_config;
install $BUILD_TARGET;
cd $BASE;

if [[ $TARGET != '/' ]]; then
    echo "Remove TARGET from '/home/postfix' (if error please remove manually)...";
    rm /home/postfix;
    error_check;
fi;
