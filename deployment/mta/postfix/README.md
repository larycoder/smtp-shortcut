# Postfix

Postfix is outstanding ESMTP server serving for receive, relay and save mail.
In this project, Postfix is used as MSA, MTA and MDA gateway servers.

Because everything is setup with docker. We propose 2 method to setup the Postfix
servers: manually setup or use automate script.

Good start points for reader:

- **manual.sh**: provide guideline allowing reader safely setup their own service.
- **start.sh**: automate script to start the services.
- **clean.sh**: automate script to clear setup created by **start.sh**.
- **link.sh**: automate script to link SMTP containers together by relay mechanic.

***Note***: carefully with another script than above scripts. Make sure you know
what you do and we do not guarantee for the bullet you shoot yourself.

External script for advance reader:

- **collect_configure.sh**: script provide dynamic setup information.
- **postfix-conf.sh**: script provide fully setup content fitting to container.

# Multi-relay configuration

The initialize script is not designed to connect several relay container together.
For doing that and build-up relay pipeline system, please applying **link.sh**
script. Example for a pipeline from **Submission** to **Mailbox** through 3 relay
nodes:

```
# Diagram
Submission --> Relay-0 --> Relay-1 --> Relay-2 --> Mailbox

# Configure
./link.sh Submission Relay-0
./link.sh Relay-0 Relay-1
./link.sh Relay-1 Relay-2
./link.sh Relay-2 Mailbox
```

# Extra

For building dummy postfix docker image which could be used to inject modified
postfix for running, follow below steps:

```
# Build docker images

docker build -f <dockerfile> -t <image_name>:<image_tag> .            # template

docker build -f Dockerfiles/Dockerfile.arch -t postfix-dummy:v1 .     # example
docker build -f Dockerfiles/Dockerfile.debian -t postfix-dummy:v1 .   # example
```

This image is necessary to run MTA submit service since this service is modified
to parse "X-Data-Ondemand".
