#!/usr/bin/env bash
set -euo pipefail
PHP_VER="${1:-8.2}"
# Basic cleanup to keep images small
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
