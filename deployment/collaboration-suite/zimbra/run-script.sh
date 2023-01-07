#!/bin/bash

echo """
# Depending on zimbra image of jorgedlcruz
# Password: root
docker run -d \
    --name smtp_sc-zimbra \
    --hostname smtp_sc-zimbra \
    --network smtp_sc-network \
    -e PASSWORD=root \
    --dns 127.0.0.1 --dns 8.8.8.8 \
    -p 80:8080 -p 7071:7071 \
    jorgedlcruz/zimbra:latest

docker run -d \
    --name smtp_sc-zimbra \
    --network smtp_sc-network \
    griffinplus/zimbra:latest
"""
