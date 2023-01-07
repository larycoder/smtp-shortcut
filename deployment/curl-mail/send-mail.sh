#!/bin/bash

SMTP_SERVER="smtp_sc-mta-relay-postfix"
SMTP_PORT="25"

SEND_MAILBOX="smtp_sc-mailbox-dovecot"
RECV_MAILBOX="smtp_sc-mailbox-dovecot"

SEND_NAME="hieplnc.m20ict@smtp_sc-domain"
RECV_NAME="lenhuchuhiep99@smtp_sc-domain"

PASS="pass"

echo """
# For debugging purpose:
add '-v' option to all curl command
"""

echo """
##################################################
"""

echo """
# send mail (postfix - MTA server)
curl --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
    --mail-from "\'$SEND_NAME\'" \
    --mail-rcpt "\'$RECV_NAME\'" \
    --user "$SEND_NAME:$PASS" \
    --upload-file mail.txt
"""

echo """
##################################################
"""

echo """
# list all mail folder (test imap server)
curl imap://$SEND_MAILBOX/\* \
    -u $SEND_NAME:$PASS

# generic command sender to IMAP
curl imap://$SEND_MAILBOX -u $SEND_NAME:$PASS -X '<COMMAND>'

# counting mailbox email number
curl imap://$SEND_MAILBOX \
    -X 'STATUS INBOX (MESSAGES)' \
    -u $SEND_NAME:$PASS

# fetch mail by uid
curl 'imap://$SEND_MAILBOX/inbox;uid=<UID>' \
    -u $SEND_NAME:$PASS
"""
