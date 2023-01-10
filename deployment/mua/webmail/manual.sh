#!/bin/bash

deli="=========================================================="

echo """
# Start the webmail container follow roundcube official image
docker run -d \
    --name smtp_sc-webmail-roundcube \
    --network smtp_sc-network \
    -e ROUNDCUBEMAIL_DEFAULT_HOST=smtp_sc-mailbox-dovecot \
    -e 'ROUNDCUBEMAIL_SMTP_SERVER=smtp_sc-mta-submit-postfix' \
    -p 8000:80 \
    roundcube/roundcubemail:latest
"""

echo $deli

echo """
# Since our SMTP server is unauthenticated server. Webmail should communicate with
# them by plain relay. The default Roundcube is not plain relay. For enabling it,
# following below steps:

# Enable plain relay by add 2 configuration to config file.
# File: /var/www/html/config/config.docker.inc.php
\$config['smtp_user'] = '';
\$config['smtp_pass'] = '';

# Restart apache2 server
apache2ctl restart
"""
