# How to test the legit of mail servers ?

We could not know if the mail server work wrong. We will need the method to
validate it. We need a small mail client to test our server. We could use curl
for this job.

Basic curl commend for sending SMTP mail:

```
curl --url 'smtps://<mail-server>:<mail-port>' --ssl-reqd \
  --mail-from '<sender-name>@<mailbox-domain>' \
  --mail-rcpt '<receier-name>@<mailbox-domain>' \
  --user '<sender-name>@<mailbox-domain>:<account-password>' \
  --upload-file mail.txt
```

Basic curl commend to read mail in mailbox:

1. Get specific mail

```
curl imap://<mailbox-domain>/<mailbox-name>;UID=<letter-id>
```

2. List mail

```
curl imap://<mailbox-domain>/<mailbox-name>
```

3. List mail of user who has password

```
curl imap://<mailbox-domain>/<mailbox-name> -u <USER_NAME>:<USER_PASSWORD>
```
