# Mailbox (Dovecot)

Dovecot provides IMAP and LDA servers which is used to build up a mail-spool.
In this project, we leverage Dovecot server as destination for all mailbox users.

Because everything is setup with docker. We propose 2 method to setup the Dovecot
mail-spool: manually setup or use automate script.

Good start points for reader:

- **manual.sh**: provide guideline allowing reader safely setup their own service.
- **start.sh**: automate script to start the services.
- **clean.sh**: automate script to clear setup created by **start.sh**.

***Note***: carefully with another script than above scripts. Make sure you know
what you do and we do not guarantee for the bullet you shoot yourself.

External script for advance reader:

- **collect_configure.sh**: script provide dynamic setup information.
- **dovecot-conf.sh**: script provide fully setup content fitting to container.
