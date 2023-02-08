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

# Upgrade file during modification of source code
make upgrade

# Link install to root configuration
cd /home/postfix
ln -sn <BASE_INSTALL> postfix
```

## Pre-process for running Postfix

Create account and groups (not recommendation)

```
# User without home and login shell
useradd --no-create-home --shell /usr/bin/nologin postfix

# Add password for user (default: 1)
pwd postfix

# Group for drop mail
groupadd postdrop

# Update installation directories to follow new created user and group
chown -R postfix:postdrop $INSTALL
```

Update installation to follow current user for easier log tracking

```
# Update owner
chown -R $(whoami):$(id -gn) $INSTALL

# Update new mail owner in main.cf configuration
main_owner = $(whoami)

# Update user and group in main.cf
mail_owner = $(whoami)
```

## Configuration

Create virtual users for postfix

```
# File: main.cf

## Configure virtual users
virtual_mailbox_domains = smtp-sc.domain
virtual_mailbox_base = /home/postfix/var/mail
virtual_mailbox_maps = hash:/home/postfix/etc/postfix/virtualmaps

## UNIX user who manage virtual mail
virtual_uid_maps = static:$USER_ID
virtual_gid_maps = static:$GROUP_ID

# File: virtualmaps
user1@smtp-sc.domain user1
user2@smtp-sc.domain user2

# Generate new hash table for virtual file
postmap /home/postfix/etc/postfix/virtualmaps
```

For receiving log from STDOUT, update main.cf

```
maillog_file = /dev/stdout
```

Enable debug verbose (add -v), update master.cf

```
smtp      inet  n       -       n       -       -       smtpd -v
```

## Run

For running postfix in foreground mode

```
# Enable environment
source ./postfix-activate.sh

# start foreground mode postfix
postfix start-fg

# For stop postfix (another terminal)
postfix stop
```

## Postfix Inspect

For inspecting mail queue

```
# Inspect
> mailq
> sendmail -bp
> postqueue -p
> postcat -vq $QUEUE_ID

# Flush mail
> postfix flush

# Delete all mail
> postsuper -d ALL
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
