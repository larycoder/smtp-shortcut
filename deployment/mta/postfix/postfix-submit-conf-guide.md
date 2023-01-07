# Postfix configuration

Postfix serves as Submitting server which only check and send message to relay
postfix configured.

Setup main.cf file:

```
# /etc/postfix/main.cf

readme_directory = /usr/share/doc/postfix/readme
inet_protocols = all
meta_directory = /etc/postfix
shlib_directory = /usr/lib/postfix
maillog_file = /dev/stdout

myhostname = smtp_sc-mta-submit-postfix
mydomain = smtp_sc-submit-domain
myorigin = $mydomain
relayhost = [smtp_sc-mta-relay-postfix]:25

smtp_use_tls = yes
always_add_missing_headers = no
smtp_host_lookup = native,dns

mynetworks = <SUBNET>
```

Setup master.cf file to enable submission

```
# /etc/postfix/master.cf
submission inet n - y - - smtpd
```

Finally, reload postfix to update new configuration

```
# Then reload postfix reload to update new configuration file
postfix reload
```
