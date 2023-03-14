#!/bin/bash

echo """
# We use dovecot command to pull corresponding mailbox image to docker
docker pull dovecot/dovecot
""";

echo """
# For running mailbox container
docker run -d \
    --network smtp_sc-network \
    --name 'smtp_sc-mailbox-dovecot' \
    --volume <MAILBOX>:'/srv/mail' \
    dovecot/dovecot:latest
"""

echo """
# For further setup of dovecot
Following file: ./dovecot-conf-guide.md
"""
