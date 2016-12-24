
# Supported tags and respective `Dockerfile` links

- `11`, `11.0`, `11.0.0` ([Dockerfile](https://github.com/aheimsbakk/nextcloud/blob/11.0.0/Dockerfile))
- `10`, `10.0`, `10.0.2` ([Dockerfile](https://github.com/aheimsbakk/nextcloud/blob/10.0.2/Dockerfile))
- `10.0.1` ([Dockerfile](https://github.com/aheimsbakk/nextcloud/blob/10.0.1/Dockerfile))
- `10.0.0` ([Dockerfile](https://github.com/aheimsbakk/nextcloud/blob/10.0.0/Dockerfile))
- `9`, `9.0`, `9.0.53` ([Dockerfile](https://github.com/aheimsbakk/nextcloud/blob/9.0.53/Dockerfile))


# Nextcloud 

From [Wikipedia on OwnCloud][wiki_owncloud]: *April 2016 Karlitschek and many of the top contributors left [OwnCloud][] Inc. Five weeks later they started [Nextcloud][], a fork of OwnCloud.*

This is a drop in replacement for the Owncloud docker. Based on Debian Jessie with [LibreOffice][] installed to be able to use the [document plugin][]. You can also enable locking with [Redis][] using environment variables.

Memcache with ACPu is enabled by default as showed in Nextcloud [configuring memory caching](https://docs.nextcloud.com/server/9/admin_manual/configuration_server/caching_configuration.html).

This Docker is installed as described in Nextclouds [source installation][] guide.


## :-o Caviats

- No HTTPS support

	To get a secure Nextcloud, use a HTTPS proxy.

- Not under `/var/www/html`

	Nextcloud lives under `/var/www/nextcloud`.

- No small size docker

    This docker isn't optimized for size, but for functionality.

- Redis and memcache only configured on clean install

	This docker does not modify `config/config.php` for existing installations. The same apply when upgrading this docker to a newer version.

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

**:-o Example caviats**

- All password is example password, use your own strong passwords.
- All volumes are stored in `/tmp`, use permanent storage folders.

### 1. [Redis](https://hub.docker.com/_/redis/)

Naming this docker `redis` we can use the default `REDIS_SERVER` name in the Nextcloud docker.

	docker run -d \
		--name redis \
		redis

### 2. [MariaDB](https://hub.docker.com/_/mariadb/)

Prepare MariaDB database dir with correct ownership.

	mkdir -p /tmp/nc_db
	chown 999.999 /tmp/nc_db

Start MariaDB with random passwords generated with [`apg`](http://linux.die.net/man/1/apg).

	docker run -d \
		-e MYSQL_ROOT_PASSWORD=ghoshfiart \
		-e MYSQL_DATABASE=nextcloud \
		-e MYSQL_USER=nextcloud \
		-e MYSQL_PASSWORD=EtlenubZee \
		-v /tmp/nc_db:/var/lib/mysql \
		--name=mariadb \
		mariadb

**:-? MariaDB not starting**

- Running Fedora/CentOS/RedHat for testing, disable SELinux temporary.

	`setenforce 0`

### 3. Nexcloud

Start Nextcloud linked to both Redis and MariaDB with separate `data` and `config` directory. Notice that port 80 is not mapped to local machine. It's done by the proxy.

	docker run -d \
		-e REDIS_ENABLED=true \
		-e OVERWRITEPROTOCOL=https \
		-v /tmp/nc_data:/var/www/nextcloud/data \
        -v /tmp/nc_config:/var/www/nextcloud/config \
		--link redis:redis \
		--link mariadb:mariadb \
		--name nc \
		aheimsbakk/nextcloud:9

### 4. HTTPS proxy

Start the ssl-proxy. This example uses my ssl-proxy, but use your favourite. If you go for this one, see [aheimsbakk/ssl-proxy](https://hub.docker.com/r/aheimsbakk/ssl-proxy/) for how to add your own certificate.

	docker run -d \
		-p 80:80 \
		-p 443:443 \
		--link nc:http \
		--name proxy \
		aheimsbakk/ssl-proxy:3.2


### 5. Start browser

Go to `http://localhost`, accept the self signed certificate. And configure Nextcloud.

Remember to choose MariaDB when configuring the admin user.

Enjoy.

[document plugin]: https://apps.owncloud.com/content/show.php/Documents?content=168711
[LibreOffice]: https://www.libreoffice.org
[Redis]: https://redis.io
[wiki_owncloud]: https://en.wikipedia.org/wiki/OwnCloud
[OwnCloud]: https://owncloud.com
[Nextcloud]: https://nextcloud.com
[source installation]: https://docs.nextcloud.com/server/9/admin_manual/installation/source_installation.html

