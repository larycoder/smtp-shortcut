#!/bin/bash

IPv4Address=$(docker network inspect smtp_sc-network -f '{{(index .IPAM.Config 0).Subnet}}');

echo """
Script allow to collect necessary information to setup dovecot.

IPv4Subnet: $IPv4Address
"""
