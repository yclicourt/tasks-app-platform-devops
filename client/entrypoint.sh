#!/bin/sh

set -e

echo "Configurando frontend..."
echo "API = ${VITE_API_URL_PLACEHOLDER}"

sed -i "s|API_URL: null|API_URL: \"${VITE_API_URL_PLACEHOLDER}\"|g" \
    /usr/share/nginx/html/config.js

echo "Contenido de config.js:"
cat /usr/share/nginx/html/config.js

exec "$@"