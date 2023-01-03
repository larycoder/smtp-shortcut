#!/bin/bash

echo """
# We use dovecot command to pull corresponding mailbox image to docker
docker pull dovecot/dovecot
""";

echo """
# For running mailbox container
docker run -d \
    --name 'smtp_sc-mailbox-dovecot' \
    dovecot/dovecot:latest
"""

echo """
# For further setup of dovecot
Following file: ./dovecot-conf-guide.md
"""
