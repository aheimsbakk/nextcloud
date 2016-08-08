FROM debian:jessie

# Add Debian contrib and use ftp.uio.no
# FIXME: not for people outside Norway
RUN { \ 
        echo deb http://ftp.uio.no/debian jessie main; \
        echo deb http://ftp.uio.no/debian jessie-updates main; \ 
        echo deb http://security.debian.org jessie/updates main; \
        echo deb http://ftp.debian.org/debian jessie-backports main; \
    } > /etc/apt/sources.list

# update package cache
RUN apt-get update

# Reccomended packages from https://docs.nextcloud.com/server/9/admin_manual/installation/source_installation.html
RUN apt-get install -y wget bzip2 apache2 libapache2-mod-php5 php5-gd php5-json php5-mysql php5-curl php5-intl php5-mcrypt php5-imagick 

# Install database drivers
RUN apt-get install -y php5-sqlite php5-mysql php5-pgsql

# Auth and storage
RUN apt-get install -y php5-ldap php5-imap php5-gmp

# For server performance
RUN apt-get install -y php5-apcu php5-memcached php5-redis

# Installing libreoffice
RUN apt-get install -y libreoffice

# Install ffmpeg
RUN apt-get install -y -t jessie-backports ffmpeg

# Cleanup
RUN rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /etc/php5/mods-available/opcache-recommended.ini

RUN php5enmod opcache-recommended

# Nextcloud apache config
RUN { \
        echo 'Alias / "/var/www/nextcloud/"'; \
        echo 'ServerName localhost'; \
        echo '<Directory /var/www/nextcloud/>'; \
        echo '  Options +FollowSymlinks'; \
        echo '  AllowOverride All'; \
        echo ' <IfModule mod_dav.c>'; \
        echo '  Dav off'; \
        echo ' </IfModule>'; \
        echo ' SetEnv HOME /var/www/nextcloud'; \
        echo ' SetEnv HTTP_HOME /var/www/nextcloud'; \
        echo '</Directory>'; \
    } > /etc/apache2/sites-available/nextcloud.conf

RUN a2dissite 000-default
RUN a2ensite nextcloud

# Redirect Apache2 logs
RUN ln -sf /dev/stdout /var/log/apache2/other_vhosts_access.log
RUN ln -sf /dev/stderr /var/log/apache2/error.log

# Enable Apache2 modules
RUN a2enmod rewrite headers env dir mime

# REDIS
ENV REDIS_ENABLED ""
ENV REDIS_SERVER redis
ENV REDIS_PORT 6379

# Trusted domains
ENV TRUSTED_DOMAINS ""

# Change owerwrite protocol to https if you use HTTPS proxy
ENV OVERWRITEPROTOCOL ""

# Define Nexcloud version
ENV NEXTCLOUD_VERSION 9.0.53

# Set home
VOLUME /var/www/html

# Download and verify Nextcloud, as in https://github.com/docker-library/owncloud/blob/master/9.0/apache/Dockerfile
RUN wget -O nextcloud.tar.bz2 \
        "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" \
    && wget -O nextcloud.tar.bz2.asc \
        "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.tar.bz2.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
# gpg key from https://nextcloud.com/nextcloud.asc
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 28806A878AE423A28372792ED75899B9A724937A \
    && gpg --batch --verify nextcloud.tar.bz2.asc nextcloud.tar.bz2 \
    && rm -r "$GNUPGHOME" nextcloud.tar.bz2.asc \
    && tar -xjf nextcloud.tar.bz2 -C /usr/src/ \
    && rm nextcloud.tar.bz2

# Add entrypoint 
COPY docker-entrypoint.sh /

# Run entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["apache2ctl", "-DFOREGROUND"]

