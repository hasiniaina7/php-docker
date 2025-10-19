#!/usr/bin/env bash
set -euo pipefail

PHP_VER="${1:-8.2}"
export DEBIAN_FRONTEND=noninteractive

MODULES_DEFAULT="
    php${PHP_VER}-bcmath
    php${PHP_VER}-cli
    php${PHP_VER}-curl
    php${PHP_VER}-fpm
    php${PHP_VER}-intl
    php${PHP_VER}-mbstring
    php${PHP_VER}-mysql
    php${PHP_VER}-opcache
    php${PHP_VER}-xml
    php${PHP_VER}-zip
"

MODULES_OPTIONAL="
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
"

# Install base + optional (ignore failures for exotic modules not available on jammy)
apt-get install -y --no-install-recommends ${MODULES_DEFAULT}

# Try optional ones individually to avoid the whole install failing if one is missing
for pkg in ${MODULES_OPTIONAL}; do
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    apt-get install -y --no-install-recommends "$pkg" || echo "Skipping optional module $pkg"
  else
    echo "Optional module $pkg not found in apt-cache, skipping"
  fi
done
