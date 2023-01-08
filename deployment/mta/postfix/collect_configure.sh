#!/bin/bash

export Database='mailserver';
export Subnet=$(docker network inspect smtp_sc-network -f '{{(index .IPAM.Config 0).Subnet}}');
