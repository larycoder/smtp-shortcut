FROM archlinux:base-devel
RUN (useradd hieplnc) && (yes | pacman -Syy postfix-mysql pcre);
ADD postfix.tar.gz /home/
CMD /home/postfix/usr/sbin/postfix start-fg
