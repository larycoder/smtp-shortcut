#!/bin/bash

export Database='mailserver';
export Subnet=$(docker network inspect smtp_sc-network -f '{{(index .IPAM.Config 0).Subnet}}');
export ODD_EXT_HOST='smtp_sc-mta-ext-postfix';
export ODD_EXT_PORT='8081';
