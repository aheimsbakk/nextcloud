
# Supported tags and respective `Dockerfile` links

- `9`, `9.0`, `9.0.53` ([Dockerfile](https://github.com/aheimsbakk/nextcloud/blob/master/Dockerfile))
- `latest` ([Dockerfile](https://github.com/aheimsbakk/nextcloud/blob/master/Dockerfile))


# Nextcloud 

From [Wikipedia on OwnCloud][wiki_owncloud]: *April 2016 Karlitschek and many of the top contributors left [OwnCloud][] Inc. Five weeks later they started [Nextcloud][], a fork of OwnCloud.*

This is a drop in replacement for the Owncloud docker. Based on Debian Jessie with [LibreOffice][] installed to be able to use the [document plugin][]. You can also enable configuration for [Redis][] with environment variables.

This Docker is installed as described in Nextclouds [source installation][] guide.


## :-o Caviats

- No HTTPS support

	To get a secure Nextcloud, use a HTTPS proxy.

- No `/var/www/html`

	Nextcloud lives under `/var/www/nextcloud`.


## :-| Environment variables

- `REDIS_ENABLED`=

	Default no value. If set to a value, Redis configuration is added to Nexcloud configuration at first run.

- `REDIS_SERVER`=`redis`

	Name of the Redis server to connect to. Defaults to `redis` and expects that this docker is linked to a container with link name redis.

- `REDIS_PORT`=`6379`

	Redis server port. Defaults to Redis default port.

- `TRUSTED_DOMAINS`=

	Set a trusted domains on first run. Use a comma separated list for more domains. See Nexcloud [trusted domain](https://docs.nextcloud.com/server/9/admin_manual/installation/installation_wizard.html#trusted-domains-label) for more information.

- `OVERWRITEPROTOCOL`=

	Set to `https` if you're using a HTTPS proxy. See Nextcloud [reverse proxy configuration](https://docs.nextcloud.com/server/9/admin_manual/configuration_server/reverse_proxy_configuration.html) for more information.


## :-) Example

Example to start Nextcloud with

- Redis enabled
- MariaDB backend
- External storage for config, data
- HTTPS proxy 

### 1. Redis

	docker run -d --name redis redis

### 2. MariaDB

### 3. Nexcloud

	docker run -d -p 80:80 -e REDIS_ENABLED=true --link redis:redis --name nc aheimsbakk/nextcloud:9

### 4. HTTPS proxy


[document plugin]: https://apps.owncloud.com/content/show.php/Documents?content=168711
[LibreOffice]: https://www.libreoffice.org
[Redis]: https://redis.io
[wiki_owncloud]: https://en.wikipedia.org/wiki/OwnCloud
[OwnCloud]: https://owncloud.com
[Nextcloud]: https://nextcloud.com
[source installation]: https://docs.nextcloud.com/server/9/admin_manual/installation/source_installation.html

