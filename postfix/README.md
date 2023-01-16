# Postfix

This folder holds distributed source code of Postfix and modification patch to
provide SMTP shortcut

## Path details

1. postfix-3.6.7 : distributed source code of postfix.

## Building

Simplest (For advance, reading postfix manual document)

```
make
```

Enable position-independent executables

```
makefiles pie=yes <ARGUMENTS>
```

Mapping default parameter to internal folder path (In-case run without
installation)

```
# Create necessary folder
mkdir -p var/lib
mkdir -p var/mail
mkdir -p var/spool

# Regenerate makefile following new override parameters
make makefiles \
    command_directory=$(pwd)/bin \
    config_directory=$(pwd)/conf \
    daemon_directory=$(pwd)/libexec \
    data_directory=$(pwd)/var/lib \
    mail_spool_directory=$(pwd)/var/mail \
    meta_directory=$(pwd)/meta \
    sendmail_path=$(pwd)/bin/sendmail \
    shlib_directory=$(pwd)/lib

# Build Postfix
make
```

Install Postfix in interaction mode (Recommendation)

```
make install
```

## Create development environment

1. Build Postfix following root: "/home/hieplnc/postfix"
2. Install build package to a base (anywhere)
3. Create link from the base to root folder pointed during building process

```
# Regenerate makefile following new override parameters
make makefiles pie=yes \
    command_directory=/home/postfix/usr/sbin \
    config_directory=/home/postfix/etc/postfix \
    daemon_directory=/home/postfix/usr/libexec/postfix \
    data_directory=/home/postfix/var/lib/postfix \
    mail_spool_directory=/home/postfix/var/mail \
    mailq_path=/home/postfix/usr/bin/mailq \
    manpage_directory=/home/postfix/usr/local/man \
    meta_directory=/home/postfix/etc/postfix \
    newaliases_path=/home/postfix/usr/bin/newaliases \
    queue_directory=/home/postfix/var/spool/postfix \
    sendmail_path=/home/postfix/usr/sbin/sendmail \
    shlib_directory=/home/postfix/usr/lib/postfix

# Build Postfix
make

# Install to "./install" folder (using interactive mode to point there)
make install

# Link install to root configuration
cd /home/postfix
ln -sn <BASE_INSTALL> postfix
```

## Pre-process for running Postfix

Create account and groups

```
# User without home and login shell
useradd --no-create-home --shell /usr/bin/nologin postfix

# Add password for user (default: 1)
pwd postfix

# Group for drop mail
groupadd postdrop
```

## Run

For running postfix

```
./bin/postfix start
```

## Recovery

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
