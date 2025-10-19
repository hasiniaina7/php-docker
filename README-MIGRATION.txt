# PHP 8.2 on Ubuntu 22.04 (Jammy) for jtreminio/php-docker fork

This patch set replaces the deprecated `phusion/baseimage` and Ubuntu 18.04 (bionic)
assumptions with a clean Ubuntu 22.04 (jammy) base and uses Ondřej Surý's PHP PPA
to install PHP 8.2 and modules.

## Files included
- Dockerfile-env
- Dockerfile-php-cli
- Dockerfile-php-fpm
- files/base_packages.sh     (adds PPA dynamically)
- files/php/bin_install_modules.sh (installs PHP 8.2 + optional modules when available)
- files/php/bin_clean_directories.sh
- files/php/php.ini, files/php/fpm.conf (basic defaults; adjust as needed)

## How to build locally

1. Replace the corresponding files in your repo with the ones in this ZIP.
2. Build the environment base (optional):
   docker build -f Dockerfile-env -t local/php-env:22.04 .

3. Build CLI (PHP 8.2):
   docker build -f Dockerfile-php-cli --build-arg PHP_VER=8.2 -t local/php:8.2-cli .
   # Smoke test:
   docker run --rm local/php:8.2-cli php -v

4. Build FPM (PHP 8.2):
   docker build -f Dockerfile-php-fpm --build-arg PHP_VER=8.2 -t local/php:8.2-fpm .
   # Smoke test:
   docker run --rm -p 9000:9000 local/php:8.2-fpm php -i | head -n 20

## Integrating with RADIUSdesk
In RADIUSdesk/docker/Dockerfile-build-radiusdesk, change:
    FROM jtreminio/php:8.1
to:
    FROM local/php:8.2-fpm   # (or your pushed registry tag)

Also remove any `ENV PHP_INI_SCAN_DIR=:/p/...` lines that depended on jtreminio's symlink trick,
as modules are installed & enabled directly via apt packages here.

## Notes
- Optional modules are attempted individually; ones unavailable on jammy will be skipped gracefully.
- If you need Nginx/Apache images from PPA, add their PPAs using `add-apt-repository -y ppa:ondrej/nginx` or `/apache2`
  in their respective Dockerfiles, using the same codename-detection strategy.
