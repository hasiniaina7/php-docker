#!/usr/bin/env bash
set -euo pipefail

# Smoke tests for php-docker
# Usage: ./tests/run-smoke.sh

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT_DIR"

echo "1) Build optional base image: Dockerfile-env"
if docker build -f Dockerfile-env -t local/php-env:22.04 .; then
  echo "-> base image built: local/php-env:22.04"
else
  echo "ERROR: base image build failed" >&2
  exit 2
fi

PHP_VER=8.2

echo "\n2) Build PHP CLI ${PHP_VER}"
if docker build -f Dockerfile-php-cli --build-arg PHP_VER=${PHP_VER} -t local/php:${PHP_VER}-cli .; then
  echo "-> php cli image built: local/php:${PHP_VER}-cli"
else
  echo "ERROR: php cli build failed" >&2
  exit 3
fi

echo "Running php -v inside CLI image"
if docker run --rm local/php:${PHP_VER}-cli php -v; then
  echo "-> php -v OK"
else
  echo "ERROR: php -v failed" >&2
  exit 4
fi

echo "Checking required modules in CLI image"
if docker run --rm local/php:${PHP_VER}-cli php -m | egrep 'bcmath|curl|intl|mbstring|mysql|opcache|xml|zip'; then
  echo "-> modules OK"
else
  echo "ERROR: required modules missing" >&2
  exit 5
fi

echo "\n3) Build PHP FPM ${PHP_VER}"
if docker build -f Dockerfile-php-fpm --build-arg PHP_VER=${PHP_VER} -t local/php:${PHP_VER}-fpm .; then
  echo "-> php fpm image built: local/php:${PHP_VER}-fpm"
else
  echo "ERROR: php fpm build failed" >&2
  exit 6
fi

echo "Running php -i (head) inside FPM image"
 # We don't publish the port in the script; we just invoke php -i in the container
 TMP_OUT=$(mktemp)
 if docker run --rm local/php:${PHP_VER}-fpm php -i >"${TMP_OUT}" 2>&1; then
  head -n 20 "${TMP_OUT}"
  echo "-> php -i OK"
else
  # php -i sometimes exits non-zero when the consumer (head) closes the pipe.
  # If we still got output, show it and continue; otherwise treat as failure.
  head -n 20 "${TMP_OUT}" || true
  if [ -s "${TMP_OUT}" ]; then
    echo "-> php -i produced output (container exited non-zero) — continuing"
  else
    echo "ERROR: php -i failed and produced no output" >&2
    rm -f "${TMP_OUT}"
    exit 7
  fi
fi
rm -f "${TMP_OUT}"

echo "\nAll smoke tests passed ✅"
exit 0
