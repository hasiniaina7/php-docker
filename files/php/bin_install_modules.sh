#!/usr/bin/env bash
set -euo pipefail
set -x

PHP_VER="${1:-8.2}"
export DEBIAN_FRONTEND=noninteractive

# On suppose que le PPA ondrej/php a déjà été ajouté dans le Dockerfile.
apt-get update

# Modules *de base* indispensables
read -r -d '' MODULES_DEFAULT <<EOF || true
php${PHP_VER}-bcmath
php${PHP_VER}-cli
php${PHP_VER}-curl
php${PHP_VER}-intl
php${PHP_VER}-mbstring
php${PHP_VER}-mysql
php${PHP_VER}-opcache
php${PHP_VER}-xml
php${PHP_VER}-zip
EOF

# Modules *optionnels* (essayés un par un; on n'échoue pas s’ils n’existent pas)
read -r -d '' MODULES_OPTIONAL <<EOF || true
php${PHP_VER}-amqp
php${PHP_VER}-apcu
php${PHP_VER}-gd
php${PHP_VER}-igbinary
php${PHP_VER}-imagick
php${PHP_VER}-mailparse
php${PHP_VER}-memcached
php${PHP_VER}-mongodb
php${PHP_VER}-oauth
php${PHP_VER}-raphf
php${PHP_VER}-redis
php${PHP_VER}-soap
php${PHP_VER}-solr
php${PHP_VER}-sqlite3
php${PHP_VER}-uuid
php${PHP_VER}-xdebug
php${PHP_VER}-zmq
EOF

# Installe les modules de base
apt-get install -y --no-install-recommends ${MODULES_DEFAULT}

# Installe les optionnels si disponibles
for pkg in ${MODULES_OPTIONAL}; do
  if apt-cache show --no-all-versions "$pkg" >/dev/null 2>&1; then
    apt-get install -y --no-install-recommends "$pkg" || true
  else
    echo "==> Skip module (introuvable): $pkg"
  fi
done

# Nettoyage
apt-get -y --purge autoremove || true
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/{man,doc}
