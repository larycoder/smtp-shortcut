#!/bin/bash

export Database='mailserver';
export Subnet=$(docker network inspect smtp_sc-network -f '{{(index .IPAM.Config 0).Subnet}}');

# Mail format
#export mail_location='maildir:~/Mail'; # directory format
export mail_location='mbox:~/Mail'; # unix file format
