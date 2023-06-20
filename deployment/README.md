# Setup guideline for deploying simple insecure local mail servers

Each subdirectory is guideline to deploy a specific component of mail servers
network. For simple mail servers network, please follow below deployment order:

0. Create docker network (following network/manual.sh)
1. Deploy MySQL (following mysql/README.md)
2. Deploy Mailbox (following mailbox/README.md)
3. Deploy MTA (main, relay, submission, data) (following mta/postfix/README.md)
```
# Example sequence of deployment (on dir: ./mta/postfix)
## Pre-configuration
export POSTFIX_TEST_DIR=<POSTFIX_DIR> # default value: /home/postfix
## Build package (if not yet having)
./build-package.sh
## Boot up data server
./start.sh EXT
## Boot up SMTP submit server
./start.sh SUBMIT
## Boot up SMTP receiver server
./start.sh MAIN
## Boot up N SMTP mta server (N: relay number, example: 0) (number of relay is unlimited)
./start.sh RELAY N
## Link relay pipelines
./link.sh smtp_sc-mta-submit-postfix smtp_sc-mta-relay-postfix-N # sub -> relay
./link.sh  smtp_sc-mta-relay-postfix-N smtp_sc-mta-postfix # relay -> dest
```
4. Deploy Webmail (following ./mua/webmial/README.md)

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

## Access mail system from webmail

1. Open webmail from URL: "localhost:8000"
2. Default users:
```
# user 0
username: admin@smtp-sc.domain
password: pass

# user1
username: hieplnc.m20ict@smtp-sc.domain
password: pass

# user2
username: lenhuchuhiep99@smtp-sc.domain
password: pass
```
