#!/bin/bash
# This file is supporter for main start.sh file.
# IF YOU DO NOT KNOW WHAT YOU ARE DOING, DO NOT RUN IT !!!
source ./collect_configure.sh > /dev/null;

if [[ $1 == '/var/www/html/config/config.docker.inc.php' ]];then
    echo """
<?php
  \$config['db_dsnw'] = 'sqlite:////var/roundcube/db/sqlite.db?mode=0646';
  \$config['db_dsnr'] = '';
  \$config['smtp_user'] = '';
  \$config['smtp_pass'] = '';
  \$config['imap_host'] = 'smtp_sc-mailbox-dovecot:143';
  \$config['smtp_host'] = 'smtp_sc-mta-submit-postfix:587';
  \$config['temp_dir'] = '/tmp/roundcube-temp';
  \$config['skin'] = 'elastic';
  \$config['plugins'] = array_filter(array_unique(array_merge(\$config['plugins'], ['archive', 'zipdownload'])));
?>
    """;
fi
