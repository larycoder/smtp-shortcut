# Test sending mail

For examining activity of mail receiving in postfix, we can inject fake mail to
postfix and look on incoming queue location to capture result. This document
guides the reader to do this process.

## Detect incoming queue location

The root directory could be saw in postfix configuration. Applying follow command
to show it:
```
postconf -d | grep queue_directory

======
Example result:

queue_directory = /home/postfix/var/spool/postfix
```

Main target queue is incoming queue. This queue is actually a directory and hold
the inbound mail as the files. So simplest method to track queue is look on
updated file in this directory.
```
# Go to main target location
cd $queue_directory/incoming

# Track file in directory
watch -n1 'ls -l'
```

## Prepare knowledge

There are 2 types of mailbox: UNIX account and virtual account. We focus on UNIX
one. The local mailbox is defined in parameter: $mail_spool_directory

```
mail_spool_directory = /home/postfix/var/mail
```

Since we use UNIX account user. We should use existed one as main recipient. Below
is example of mail detail information:

```
# sender: user1@smtp-sc.domain
# recipient: user2@stmp-sc.domain
# data:
Subject: Test mail

Hi there !

This mail is test mail.

Bye
```

## Method 1: telnet

We connect directly to SMTP server and send command to forward **TEST MAIL**
from user1 to user2.

```
# Open connection to SMTP server
telnet localhost 25

# Feed command to server
ehlo smtp-sc.domain
mail from: user1@smtp-sc.domain
rcpt to: user2@smtp-sc.domain
data
Subject: Test mail

Hi there !

This mail is test mail.

Bye
.
quit
```

## Method 2: local mail injection

This method use postfix local mail sender **sendmail** to send mail to dev
postfix.

```
sendmail -f user1@smtp-sc.domain user2@smtp-sc.domain << EOF
Subject: Test mail send by sendmail tool

Hello receiver !


This mail is test mail.

Bye !
EOF
```

Send on-demand data mail

```
sendmail -f user1@smtp-sc.domain user2@smtp-sc.domain << EOF
X-Data-Ondemand: host/id
Subject: Test mail send by sendmail tool

Hello receiver !


This mail is test mail.

Bye !
EOF
```

