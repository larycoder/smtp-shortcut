# Postfix configuration

Postfix serves as ESMTP server relay which only forward message to endpoint
postfix configured.

Setup main.cf file:

```
# /etc/postfix/main.cf

readme_directory = /usr/share/doc/postfix/readme
inet_protocols = all
meta_directory = /etc/postfix
shlib_directory = /usr/lib/postfix
maillog_file = /dev/stdout

myhostname = smtp_sc-mta-relay-postfix
mydomain = smtp_sc-relay-domain
myorigin = $mydomain
relayhost = [smtp_sc-mta-postfix]:25

smtp_use_tls = yes
always_add_missing_headers = no
smtp_host_lookup = native,dns

mynetworks = <SUBNET>
```

Finally, reload postfix to update new configuration

```
# Then reload postfix reload to update new configuration file
postfix reload
```
