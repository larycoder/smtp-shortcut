#!/bin/bash

echo """
Here, we use postfix as MTA. Note that:

SMTP_SERVER = relay server
"""

echo """
# Create postfix mailbox container:
docker run -d \
    --name 'smtp_sc-mta-postfix' \
    --network smtp_sc-network \
    -e SMTP_SERVER='localhost' \
    -e SERVER_HOSTNAME='smtp_sc-mta-postfix' \
    juanluisbaptiste/postfix:latest

# Create postfix relay container:
docker run -d \
    --name 'smtp_sc-mta-relay-postfix' \
    --network smtp_sc-network \
    -e SMTP_SERVER='smtp_sc-mta-postfix' \
    -e SERVER_HOSTNAME='smtp_sc-mta-relay-postfix' \
    juanluisbaptiste/postfix:latest

# Create postfix submit container:
docker run -d \
    --name 'smtp_sc-mta-submit-postfix' \
    --network smtp_sc-network \
    -e SMTP_SERVER='smtp_sc-mta-relay-postfix' \
    -e SERVER_HOSTNAME='smtp_sc-mta-submit-postfix' \
    juanluisbaptiste/postfix:latest
"""

echo """
# For integrating with MySQL
docker exec -i smtp_sc-mta-postfix bash -c 'apk update && apk add postfix-mysql'
"""

echo """
# Extra setup
For endpoint postfix, following file: ./postfix-conf-guide.md
For intermediate postfix, following file: ./postfix-relay-conf-guide.md
For submit postfix, following file: ./postfix-submit-conf-guide.md
"""
