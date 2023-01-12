# Postfix

This folder holds distributed source code of Postfix and modification patch to
provide SMTP shortcut

## Path details

1. postfix-3.6.7 : distributed source code of postfix.

## Building tool

Simplest (For advance, reading postfix manual document)

```
make
```

## Recovery tool

### Git

Do not commit files generated during building phase. Using follow command to
clear all uncommitted files and folders:

```
# Tracked file
git reset --hard HEAD

# Untracked file
git clean -f -d
```

### Make

Original distributed source code provide convenient make function to clean
all files leftover by building process.

```
 make tidy
```
