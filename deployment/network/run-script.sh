#!/bin/bash

deli="=============================================="

echo """
# Note about docker network configuration
## For bridge
- We could not setup network of bridge network.
- Default network: {"Subnet": "172.17.0.0/16", "Gateway": "172.17.0.1"}
"""

echo """
$deli
"""

echo """
# Create docker network for host
docker network create -d bridge smtp_sc-network

# Create docker network for swarm
docker network create -d overlay --attachable smtp_sc-network

# Remove docker network
docker network rm
"""

echo """
$deli
"""

echo """
# Useful inspect commands
docker network ls
docker network inspect
"""
