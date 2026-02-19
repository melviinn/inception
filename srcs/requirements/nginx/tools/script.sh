#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'

log_ok()    { printf "%b\n" "${GREEN}[OK] $*"${NC};}

# --- Check if the environments var are specified (return if one is missing) ---
: "${DOMAIN_NAME:?missing DOMAIN_NAME environment variable}"

mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
	-keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt \
	-subj "/C=FR/ST=France/L=Paris/O=42\ School/OU=mduchauf/CN=${DOMAIN_NAME}" \
	>/dev/null 2>&1

cp -r ./conf/nginx.conf /etc/nginx/nginx.conf

log_ok "Successfully generated openssl certification & key"

exec nginx -g "daemon off;"
