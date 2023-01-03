# Configure Dovecot (Optional)

Default setup main configuration

Location: /etc/dovecot/dovecot.conf
```
## You should mount /etc/dovecot if you want to
## manage this file

mail_home=/srv/mail/%Lu
mail_location=maildir:~/Mail
mail_uid=1000
mail_gid=1000

protocols = imap pop3 submission sieve lmtp
login_trusted_networks = 172.17.0.0/16

first_valid_uid = 1000
last_valid_uid = 1000

passdb {
  driver = static
  args = password=pass
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
```

***NOTE*** If using "docker pull dovecot/dovecot" then default user password is
"pass". => we use mysql password if you integrate mysql database as below.

# External setup to link dovecot to MySQL database (aware of hard-code)

Update file: /etc/dovecot/dovecot.conf
```
# Checking user password from database instead of local static one

passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
```

Then create file: /etc/dovecot/dovecot-sql.conf.ext
```
# This file is used to connect dovecot to mysql database
driver = mysql
connect = host=172.17.0.4 dbname=mailserver user=root password=root
default_pass_scheme = SHA512-CRYPT
password_query = SELECT email as user, password FROM `mailserver`.`virtual_users` WHERE email='%u';
```

# Reload dovecot configuration
```
dovecot reload
```
