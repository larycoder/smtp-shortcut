#!/bin/bash

SMTP_SERVER='smtp_sc-domain';

echo """
Here, we use postfix as MTA in here.
"""

echo """
# Create postfix container:

docker run -d \
    --name 'smtp_sc-mta-postfix' \
    --network smtp_sc-network \
    -e SMTP_SERVER=${SMTP_SERVER} \
    -e SERVER_HOSTNAME='smtp_sc-mta-postfix' \
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
"""
