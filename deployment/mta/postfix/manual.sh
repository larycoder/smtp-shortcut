#!/bin/bash

echo """
Here, we use postfix as MTA. Note that:

SMTP_SERVER = relay server
"""

echo """
# Build injectable modification postfix image
docker build -t postfix-dummy:v1 .
"""

echo """
# Create postfix injectable mailbox container:
docker run -d \
    --name 'smtp_sc-mta-postfix' \
    --volume <POSTFIX_HOME>/<INJECT_PROGRAM>:/home/postfix/<INJECT_PROGRAM> \
    --volume <POSTFIX_HOME>/<INJECT_QUEUE>:/home/postfix/<INJECT_QUEUE> \
    --volume <POSTFIX_HOME>/<INJECT_MAILBOX>:/home/postfix/<INJECT_MAILBOX> \
    --network smtp_sc-network \
    -e SMTP_SERVER='smtp_sc-mta-relay-postfix' \
    -e SERVER_HOSTNAME='smtp_sc-mta-submit-postfix' \
    postfix-dummy:v1

# Create postfix relay container:
docker run -d \
    --name 'smtp_sc-mta-relay-postfix' \
    --network smtp_sc-network \
    -e SMTP_SERVER='smtp_sc-mta-postfix' \
    -e SERVER_HOSTNAME='smtp_sc-mta-relay-postfix' \
    juanluisbaptiste/postfix:latest

# Create postfix injectable submit container:
docker run -d \
    --name 'smtp_sc-mta-submit-postfix' \
    --volume <POSTFIX_HOME>/<INJECT_PROGRAM>:/home/postfix/<INJECT_PROGRAM> \
    --volume <POSTFIX_HOME>/<INJECT_QUEUE>:/home/postfix/<INJECT_QUEUE> \
    --network smtp_sc-network \
    -e SMTP_SERVER='smtp_sc-mta-relay-postfix' \
    -e SERVER_HOSTNAME='smtp_sc-mta-submit-postfix' \
    postfix-dummy:v1

# Create postfix injectable external resource container:
docker run -d \
    --name 'smtp_sc-mta-postfix' \
    --volume <POSTFIX_HOME>/<INJECT_QUEUE>:/home/postfix/<INJECT_QUEUE> \
    --network smtp_sc-network \
    -e SMTP_SERVER='smtp_sc-mta-relay-postfix' \
    -e SERVER_HOSTNAME='smtp_sc-mta-submit-postfix' \
    -e POSTFIX_PROG='data-dump' \
    postfix-dummy:v1

# Update owner for proper running of injectable submit
docker exec $NAME bash -c 'chown -R postfix /home/postfix';
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
For external resource postfix, following file: ./postfix-ext-conf-guide.md
"""
