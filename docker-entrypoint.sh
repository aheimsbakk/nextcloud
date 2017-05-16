#!/bin/bash

NC_DIR=/var/www/nextcloud
CONF_FILE="$NC_DIR/config/config.php"

mkdir -p /var/www/nextcloud

if [ ! -e "$MC_DIR/version.php" ]; then
    cp -r /usr/src/nextcloud /var/www 
fi

if ! [ -f $CONF_FILE ]
then
    cat <<EOF > $CONF_FILE
<?php 
\$CONFIG = array ( 
  'enabledPreviewProviders' => array(
    'OC\Preview\Image',
    'OC\Preview\MP3',
    'OC\Preview\TXT',
    'OC\Preview\MarkDown',
    'OC\Preview\Movie',
    'OC\Preview\MSOffice2003',
    'OC\Preview\MSOffice2007',
    'OC\Preview\MSOfficeDoc',
    'OC\Preview\OpenDocument',
    'OC\Preview\PDF',
    'OC\Preview\StarOffice',
    'OC\Preview\SVG',
  ),
  'memcache.local' => '\OC\Memcache\APCu',
EOF

    # Add Redis if config file isn't created
    if [ "$REDIS_ENABLED" != "" ]
    then
        cat <<EOF >> $CONF_FILE
  'memcache.locking' => '\OC\Memcache\Redis',
  'redis' => array(
    'host' => '$REDIS_SERVER',
    'port' => $REDIS_PORT,
    ),
EOF
    fi

    # Add trusted domains
    if [ "$TRUSTED_DOMAINS" != "" ]
    then
        let "count = 0"
        echo "  'trusted_domains' => array (" >> $CONF_FILE
        echo "    0 => 'localhost'," >> $CONF_FILE
        for domain in $(echo $TRUSTED_DOMAINS | sed 's/,/ /g')
        do
            let "count += 1"
            echo "    $count => '$domain'," >> $CONF_FILE
        done
        echo "  )," >> $CONF_FILE    
    fi

    # Set overwrite protocol
    if [ "$OVERWRITEPROTOCOL" != "" ]
    then
        echo "  'overwriteprotocol' => 'https'," >> $CONF_FILE
    fi

    echo ");" >> $CONF_FILE
fi

/fix-permissions.sh

exec "$@"
