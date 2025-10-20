#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Detect Ubuntu codename (bionic/focal/jammy/noble...)
. /etc/os-release
CODENAME="${UBUNTU_CODENAME:-jammy}"

# Prereqs
apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates \
    software-properties-common \
    gnupg \
    dirmngr \
    curl

# Add Ondřej PHP PPA (using add-apt-repository handles keys on modern Ubuntu)
add-apt-repository -y ppa:ondrej/php

# Optionally other PPAs (apache2/nginx) can be added similarly in their respective Dockerfiles if needed
apt-get update
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
