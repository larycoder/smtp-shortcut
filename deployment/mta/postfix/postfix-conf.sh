#!/bin/bash
# This file is supporter for main start.sh file.
# IF YOU DO NOT KNOW WHAT YOU ARE DOING, DO NOT RUN IT !!!
source ./collect_configure.sh > /dev/null;

# Usage:
# postfix-conf.sh <TYPE> <FILE>
#
# TYPE: MTA type (main, relay, submission).
# FILE: Absolute path to configuration file following MTA type.
#

TYPE=${1^^};
FILE=$2;

# List of file
main='/etc/postfix/main.cf';
master='/etc/postfix/master.cf';
sql_virtual_mailbox_domains='/etc/postfix/mysql-virtual-mailbox-domains.cf';
sql_virtual_mailbox_maps='/etc/postfix/mysql-virtual-mailbox-maps.cf';
sql_virtual_alias_maps='/etc/postfix/mysql-virtual-alias-maps.cf';
sql_virtual_email2email='/etc/postfix/mysql-virtual-email2email.cf';

function ALL_main_deafult()
{
    echo """
# Default
compatibility_level = 3.6
queue_directory = /var/spool/postfix
command_directory = /usr/sbin
daemon_directory = /usr/libexec/postfix
data_directory = /var/lib/postfix
mail_owner = postfix
unknown_local_recipient_reject_code = 550
debug_peer_level = 2
debugger_command =
         PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
         ddd \$daemon_directory/\$process_name \$process_id & sleep 5
sendmail_path = /usr/sbin/sendmail
newaliases_path = /usr/bin/newaliases
mailq_path = /usr/bin/mailq
setgid_group = postdrop
html_directory = no
manpage_directory = /usr/share/man
sample_directory = /etc/postfix
readme_directory = /usr/share/doc/postfix/readme
inet_protocols = all
meta_directory = /etc/postfix
shlib_directory = /usr/lib/postfix
maillog_file = /dev/stdout

smtp_use_tls = yes
always_add_missing_headers = no
smtp_host_lookup = native,dns
    """;
}

function MAIN_main_specify()
{
    echo """
# Specify
myhostname = smtp_sc-mta-postfix
mydomain = smtp-sc.domain
myorigin = \$mydomain

virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf, mysql:/etc/postfix/mysql-virtual-email2email.cf

mynetworks = $Subnet
virtual_transport = lmtp:inet:smtp_sc-mailbox-dovecot:24
mailbox_transport = lmtp:inet:smtp_sc-mailbox-dovecot:24
    """;
}

function MAIN_sql_virtual_mailbox_domains()
{
    echo """
user = root
password = root
hosts = smtp_sc-mysql
dbname = mailserver
query = SELECT 1 FROM virtual_domains WHERE name='%s'
    """;
}

function MAIN_sql_virtual_mailbox_maps()
{
    echo """
user = root
password = root
hosts = smtp_sc-mysql
dbname = mailserver
query = SELECT 1 FROM virtual_users WHERE email='%s'
    """;
}

function MAIN_sql_virtual_alias_maps()
{
    echo """
user = root
password = root
hosts = smtp_sc-mysql
dbname = mailserver
query = SELECT destination FROM virtual_aliases WHERE source='%s'
    """;
}

function MAIN_sql_virtual_email2email()
{
    echo """
user = root
password = root
hosts = smtp_sc-mysql
dbname = mailserver
query = SELECT email FROM virtual_users WHERE email='%s'
    """;
}

function RELAY_main_specify()
{
    echo """
# Specify
myhostname = smtp_sc-mta-relay-postfix
mydomain = localhost
myorigin = \$mydomain
mynetworks = $Subnet
relayhost = [smtp_sc-mta-postfix]:25
    """;
}

function SUBMIT_main_specify()
{
    echo """
# Specify
myhostname = smtp_sc-mta-submit-postfix
mydomain = localhost
myorigin = \$mydomain
mynetworks = $Subnet
relayhost = [smtp_sc-mta-relay-postfix]:25
    """;
}

function SUBMIT_master()
{
    echo """
# Activate submission port
smtp      inet  n       -       n       -       -       smtpd
pickup    unix  n       -       n       60      1       pickup
cleanup   unix  n       -       n       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
tlsmgr    unix  -       -       n       1000?   1       tlsmgr
rewrite   unix  -       -       n       -       -       trivial-rewrite
bounce    unix  -       -       n       -       0       bounce
defer     unix  -       -       n       -       0       bounce
trace     unix  -       -       n       -       0       bounce
verify    unix  -       -       n       -       1       verify
flush     unix  n       -       n       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       n       -       -       smtp
relay     unix  -       -       n       -       -       smtp
        -o syslog_name=postfix/\$service_name
showq     unix  n       -       n       -       -       showq
error     unix  -       -       n       -       -       error
retry     unix  -       -       n       -       -       error
discard   unix  -       -       n       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       n       -       -       lmtp
anvil     unix  -       -       n       -       1       anvil
scache    unix  -       -       n       -       1       scache
postlog   unix-dgram n  -       n       -       1       postlogd
submission inet n       -       y       -       -       smtpd
    """;
}

if [[ $TYPE == 'MAIN' ]]; then
    case $FILE in
        $main)
            ALL_main_deafult;
            MAIN_main_specify;
            ;;
        $sql_virtual_mailbox_domains)
            MAIN_sql_virtual_mailbox_domains;
            ;;
        $sql_virtual_mailbox_maps)
            MAIN_sql_virtual_mailbox_maps;
            ;;
        $sql_virtual_alias_maps)
            MAIN_sql_virtual_alias_maps;
            ;;
        $sql_virtual_email2email)
            MAIN_sql_virtual_email2email;
            ;;
    esac;
elif [[ $TYPE == 'RELAY' ]]; then
    case $FILE in
            $main)
                ALL_main_deafult;
                RELAY_main_specify;
                ;;
    esac;
elif [[ $TYPE == 'SUBMIT' ]]; then
    case $FILE in
            $main)
                ALL_main_deafult;
                SUBMIT_main_specify;
                ;;
            $master)
                SUBMIT_master;
                ;;
    esac;
else
    exit 1;
fi;
