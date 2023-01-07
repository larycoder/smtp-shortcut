# Postfix configuration

The postfix need to link to dovecot at port 24 for LMTP relay. The postfix need
to accept any mail sending from anywhere and forward it to dovecot.

Setup main.cf file:

```
# /etc/postfix/main.cf

readme_directory = /usr/share/doc/postfix/readme
inet_protocols = all
meta_directory = /etc/postfix
shlib_directory = /usr/lib/postfix
maillog_file = /dev/stdout

myhostname = smtp_sc-mta-postfix
mydomain = smtp-sc.domain
myorigin = $mydomain

smtp_use_tls = yes
always_add_missing_headers = no
smtp_host_lookup = native,dns

virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf, mysql:/etc/postfix/mysql-virtual-email2email.cf

mynetworks = <SUBNET>
virtual_transport = lmtp:inet:smtp_sc-mailbox-dovecot:24
mailbox_transport = lmtp:inet:smtp_sc-mailbox-dovecot:24
```

Setup of virtual mysql configuration file to integrate to MySQL database:

```
# File: /etc/postfix/mysql-virtual-mailbox-domains.cf
user = root
password = root
hosts = smtp_sc-mysql
dbname = mailserver
query = SELECT 1 FROM virtual_domains WHERE name='%s'

# File: /etc/postfix/mysql-virtual-mailbox-maps.cf
user = root
password = root
hosts = smtp_sc-mysql
dbname = mailserver
query = SELECT 1 FROM virtual_users WHERE email='%s'

# File: /etc/postfix/mysql-virtual-alias-maps.cf
user = root
password = root
hosts = smtp_sc-mysql
dbname = mailserver
query = SELECT destination FROM virtual_aliases WHERE source='%s'

# File: /etc/postfix/mysql-virtual-email2email.cf
user = root
password = root
hosts = smtp_sc-mysql
dbname = mailserver
query = SELECT email FROM virtual_users WHERE email='%s'
```

Finally, reload postfix to update new configuration

```
# Then reload postfix reload to update new configuration file
postfix reload
```

For testing (This is a bit tricky through several container, ask author for this)

```
# Add domain to database
## smtp_sc-mysql

INSERT INTO mailserver.virtual_domains (name) VALUES ('smtp-sc.domain');

# Generate mail password
## smtp_sc-mailbox-dovecot
doveadm pw -s SHA512-CRYPT

=> Should use directly result:
Password: pass
Hash value: {SHA512-CRYPT}$6$.yZhFbwHvpxiCx3.$eNrRN.eSs8I6AeKRTOvgPymo3fvXf.e4W4J4OpzlwUxkaRahH5pLDJv40Ms.T5bH5ncFpNcpY3vLTUsVa/6HS1

# Add mail new mail user to database
## smtp_sc-mysql
INSERT INTO mailserver.virtual_users (domain_id, password , email)
VALUES ('1', '$6$.yZhFbwHvpxiCx3.$eNrRN.eSs8I6AeKRTOvgPymo3fvXf.e4W4J4OpzlwUxkaRahH5pLDJv40Ms.T5bH5ncFpNcpY3vLTUsVa/6HS1', 'hieplnc.m20ict@smtp-sc.domain');

# Test postfix
## smtp_sc-postfix
postmap -q smtp-sc.domain mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
postmap -q hieplnc.m20ict@smtp-sc.domain mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf

=> If everything go right, you suppose to see result '1' returned.
```
