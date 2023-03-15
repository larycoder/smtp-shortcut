# Postfix

Postfix is outstanding ESMTP server serving for receive, relay and save mail.
In this project, Postfix is used as MSA, MTA and MDA gateway servers.

Because everything is setup with docker. We propose 2 method to setup the Postfix
servers: manually setup or use automate script.

Good start points for reader:

- **manual.sh**: provide guideline allowing reader safely setup their own service.
- **start.sh**: automate script to start the services.
- **clean.sh**: automate script to clear setup created by **start.sh**.

***Note***: carefully with another script than above scripts. Make sure you know
what you do and we do not guarantee for the bullet you shoot yourself.

External script for advance reader:

- **collect_configure.sh**: script provide dynamic setup information.
- **postfix-conf.sh**: script provide fully setup content fitting to container.

# Extra

For building dummy postfix docker image which could be used to inject modified
postfix for running, follow below steps:

```
# Build docker images
docker build -t <image_name>:<image_tag> .  # template
docker build -t postfix-dummy:v1 .          # example
```

This image is necessary to run MTA submit service since this service is modified
to parse "X-Data-Ondemand".
