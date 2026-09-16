#!/usr/bin/env bash

set -euo pipefail

certificate=/tmp/homestead-mkcert.crt
key=/tmp/homestead-mkcert.key

openssl x509 -in "$certificate" -noout >/dev/null
openssl pkey -in "$key" -noout >/dev/null

for domain in "$@"; do
    install -m 0644 "$certificate" "/etc/ssl/certs/${domain}.crt"
    install -m 0600 "$key" "/etc/ssl/certs/${domain}.key"
done

rm -f "$certificate" "$key"

if command -v nginx >/dev/null 2>&1; then
    nginx -t
    systemctl reload nginx
fi

if command -v apache2ctl >/dev/null 2>&1 && systemctl is-active --quiet apache2; then
    apache2ctl configtest
    systemctl reload apache2
fi
