FROM archlinux:base-devel
ADD postfix.tar.gz /home/
RUN useradd hieplnc && yes | pacman -Syy postfix-mysql pcre

# Unpack postfix to the system.
RUN rm -rf /etc/postfix && \
    rm -rf /var/lib/postfix && \
    rm -rf /var/spool/postfix && \
    ln -sn /home/postfix/etc/postfix /etc/ && \
    ln -sn /home/postfix/var/lib/postfix /var/lib/ && \
    ln -sn /home/postfix/var/spool/postfix /var/spool/ && \
    ln -sn /home/postfix/usr/libexec /usr/ && \
    for i in $(ls /home/postfix/usr/bin); do \
        rm "/usr/bin/$i"; \
        ln -sn "/home/postfix/usr/bin/$i" "/usr/bin/"; \
    done && \
    for i in $(ls /home/postfix/usr/sbin); do \
        rm "/usr/sbin/$i"; \
        ln -sn "/home/postfix/usr/sbin/$i" "/usr/sbin/"; \
    done

CMD postfix start-fg
