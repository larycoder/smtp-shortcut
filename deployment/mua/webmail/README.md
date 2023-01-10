# Roundcube (webmail)

This is webmail server serving as mail client to connect to MSA and IMAP server.

Because everything is setup with docker. We propose 2 method to setup the Roundcube
webmail: manually setup or use automate script.

Good start points for reader:

- **manual.sh**: provide guideline allowing reader safely setup their own service.
- **start.sh**: automate script to start the webmail services.
- **clean.sh**: automate script to clear setup created by **start.sh**.

***Note***: carefully with another script than above scripts. Make sure you know
what you do and we do not guarantee for the bullet you shoot yourself.

External script for advance reader:

- **collect_configure.sh**: script provide dynamic setup information.
- **roundcube-conf.sh**: script provide fully setup content fitting to container.
