#!/usr/bin/env bash
set -euo pipefail
set -x

PHP_VER="${1:-8.2}"

# Supprime dossiers d’extensions des anciennes ABI PHP (si présents)
rm -rf \
	/usr/lib/php/20131226 \
	/usr/lib/php/20151012 \
	/usr/lib/php/20160303 \
	/usr/lib/php/20170718 \
	/usr/lib/php/20180731 \
	/usr/lib/php/20190902 \
	/usr/lib/php/20200930 \
	/usr/lib/php/20210902 || true

# Nettoie /etc/php des versions non ciblées
for v in 5.6 7.0 7.1 7.2 7.3 7.4 8.0 8.1; do
	if [[ "$v" != "${PHP_VER}" ]]; then
		rm -rf "/etc/php/${v}" || true
	fi
done

exit 0
