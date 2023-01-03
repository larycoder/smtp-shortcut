# Postfix configuration

Postfix serves as ESMTP server relay which only forward message to endpoint
postfix configured. Note that in 

Setup main.cf file (aware of hard-code):

```
# Note that setup is still hard-code address
# /etc/postfix/main.cf

readme_directory = /usr/share/doc/postfix/readme
inet_protocols = all
meta_directory = /etc/postfix
shlib_directory = /usr/lib/postfix
maillog_file = /dev/stdout

myhostname = smtp_sc-mta-relay-postfix
mydomain = smtp_sc-relay-domain
myorigin = $mydomain
relayhost = [172.17.0.3]:25

smtp_use_tls = yes
always_add_missing_headers = no
smtp_host_lookup = native,dns

mynetworks = 172.17.0.0/16
```

Finally, reload postfix to update new configuration

```
# Then reload postfix reload to update new configuration file
postfix reload
```
