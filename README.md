# SMTP Shortcut Project

## Pre-configuration

Because of history reason, test environment need to share postfix working
volume between MTAs containers. So it is necessary to run below script before
performing any build or test actions.

```
# Need root permission (all containers modify this dir as root user)
# Choose a directory for postfix central data (need to be absolute): <POSTFIX_DIR>
# From terminal with further actions, run:
export POSTFIX_TEST_DIR=<POSTFIX_DIR> # default value: /home/postfix
```

## Test environment setup

Following ./deployment/README.md

## Test procedure

1. Create test account on new created mailbox by dovecot
```
# Merely try to access to user account on webmail (following ./deployment/README.md)
# Webmail will request to dovecot and auto create necessary user account on mail spool.
# At least 2 accounts needed.
```
2. Build pipeline of relay server to simulate mail road (following ./deployment/README.md on MTA example)
3. Try to send multiple mail from source account to destination account (following ./evaluation/README.md) [unstable]
```
# Example of test procedure (inside dir: ./evaluation)
## Clean mail data
rm ./data/mail_*
## Generate list of 100 mail test of size 5Mb (for measure normal mail transfer)
./mail_gen NORM 100 5
## Send list of generated mail through submission server delay 1s between each mail
./mail_send 100 1
## Time record is reported by MTA through the log of container
docker logs -f smtp_sc-mta-submit-postfix # submit smtp server
docker logs -f smtp_sc-mta-postfix # receiver smtp server
docker logs -f smtp_sc-mta-ext-postfix # on-demand data server
## Content of mail could be seen on webmail
Content on account: hieplnc.m20ict@smtp-sc.domain
```

## Postfix re-build procedure

1. Postfix MTA program: ./postfix/README.md
2. Shortcut data server: ./evil-tricks/README.md
