# Postfix configuration

We implement own external resource server to allow postfix to craw mail body.
For configuration, there are no special for now. Make sure to link "data-dump"
program to "/home/postfix/usr/libexec/postfix/data-dump" so that the container
is injected with newest modification.

# TODO

1. Update external resource protocol

