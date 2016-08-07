#!/bin/bash
set -e

NC_DIR=/var/www/nextcloud
CONF_FILE="$NC_DIR/config/config.php"

mkdir -p /var/www/nextcloud

if [ ! -e "$MC_DIR/version.php" ]; then
	cp -r /usr/src/nextcloud /var/www 
	chown -R www-data $NC_DIR
fi

# Add Redis if config file isn't created

if [ "$REDIS_ENABLED" != "" ]; then
    test -f $CONF_FILE || cat <<EOF > $CONF_FILE
<?php 
\$CONFIG = array ( 
    'memcache.local' => '\OC\Memcache\Redis',
    'memcache.locking' => '\OC\Memcache\Redis',
    'redis' => array(
        'host' => '$REDIS_SERVER',
        'port' => $REDIS_PORT,
        ),
);
EOF
chown www-data $CONF_FILE
fi

exec "$@"
