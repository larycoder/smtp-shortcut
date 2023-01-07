# Webmail (Roundcube)

This is webmail server to connect to MSA and IMAP server.

# Extra configuration

## Authentication failed

Since our SMTP server is unauthenticated server. Webmail should communicate with
them by plain relay. The default Roundcube is not plain relay. For enabling it,
following below steps:

```
# Enable plain relay by add 2 configuration to config file.
# File: /var/www/html/config/config.docker.inc.php
$config['smtp_user'] = '';
$config['smtp_pass'] = '';

# Restart apache2 server
apache2ctl restart
```
