#!/bin/bash
ocpath='/var/www/nextcloud'
htuser='apache'
htgroup='apache'
rootuser='root'

printf "Creating possible missing Directories\n"
mkdir -p $ocpath/data
mkdir -p $ocpath/assets
mkdir -p $ocpath/updater

printf "chmod Files and Directories\n"
find ${ocpath} -type f -print0 -maxdepth 1 | xargs -0 chmod 0640
find ${ocpath} -type d -print0 -maxdepth 1 | xargs -0 chmod 0750

printf "chown Directories\n"
chown ${rootuser}:${htgroup} ${ocpath}/.
chown ${htuser}:${htgroup} ${ocpath}/data
find ${ocpath} ! -path */nextcloud/data/* -print0 | xargs -0 chown -R ${htuser}:${htgroup}

chmod +x ${ocpath}/occ

printf "chmod/chown .htaccess\n"
if [ -f ${ocpath}/.htaccess ]
 then
  chmod 0644 ${ocpath}/.htaccess
  chown ${rootuser}:${htgroup} ${ocpath}/.htaccess
fi
if [ -f ${ocpath}/data/.htaccess ]
 then
  chmod 0644 ${ocpath}/data/.htaccess
  chown ${rootuser}:${htgroup} ${ocpath}/data/.htaccess
fi
