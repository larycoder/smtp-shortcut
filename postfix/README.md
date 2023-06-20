# Postfix

This folder holds distributed source code of Postfix and modification patch to
provide SMTP shortcut

## Path details

Postfix-3.6.7 : distributed source code of postfix.

## Build requirement

1. Mysql client library: supporting mysql communication with postfix
```
# Re-configure postfix source to point to mysql header
# No need if running automate build script
make -f Makefile.init makefiles \
    'CCARGS=-DHAS_MYSQL -I/usr/include/mysql' \
    'AUXLIBS=-L/usr/lib/ -lmysqlclient -lz -lm'
```

## Build procedure

1. Guarantee of clean source code
```
cd ./postfix-3.6.7
make tidy
```

2. Re-build postfix
```
# Manually, not yet having document
# Following postfix INSTALL document and hint in README-RAW.md

# Automatic
./re-build.sh postfix-3.6.7 <ABSOLUTE_POSTFIX_TEST_DIR>
```
