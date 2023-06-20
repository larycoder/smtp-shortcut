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

## Test configuration

- Following ./deployment/README.md

## Postfix re-build procedure

1. Postfix MTA program: ./postfix/README.md
2. Shortcut data server: ./evil-tricks/README.md
