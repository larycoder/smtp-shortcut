#!/bin/bash

echo """
# Follow roundcube official image
docker run -d \
    --name smtp_sc-webmail-roundcube \
    --network smtp_sc-network \
    -e ROUNDCUBEMAIL_DEFAULT_HOST=smtp_sc-mailbox-dovecot \
    -e 'ROUNDCUBEMAIL_SMTP_SERVER=smtp_sc-mta-submit-postfix' \
    -p 8000:80 \
    roundcube/roundcubemail:latest
"""
