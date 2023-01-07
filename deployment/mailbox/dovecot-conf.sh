#!/bin/bash
# This file is supporter for main start.sh file.
# IF YOU DO NOT KNOW WHAT YOU ARE DOING, DO NOT RUN IT !!!
source ./collect_configure.sh > /dev/null;

if [[ $1 == '/etc/dovecot/dovecot.conf' ]]; then
    echo """
## You should mount /etc/dovecot if you want to
## manage this file

mail_home=/srv/mail/%Lu
mail_location=maildir:~/Mail
mail_uid=1000
mail_gid=1000

protocols = imap pop3 submission sieve lmtp
login_trusted_networks = $Subnet

first_valid_uid = 1000
last_valid_uid = 1000

passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}

ssl=yes
ssl_cert=<cert.pem
ssl_key=<key.pem

namespace {
  inbox = yes
  separator = /
}

service lmtp {
  inet_listener {
    port = 24
  }
}

listen = *, ::

log_path=/dev/stdout
info_log_path=/dev/stdout
debug_log_path=/dev/stdout
    """;
elif [[ $1 == '/etc/dovecot/dovecot-sql.conf.ext' ]];
then
    echo """
# This file is used to connect dovecot to mysql database
driver = mysql
connect = host=smtp_sc-mysql dbname=$Database user=root password=root
default_pass_scheme = SHA512-CRYPT
password_query = SELECT email as user, password FROM \`virtual_users\` WHERE email='%u';
    """;
fi;
