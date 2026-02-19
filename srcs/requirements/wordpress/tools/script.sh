#!/bin/bash
set -e

WP_PATH='/var/www/html'
DB_HOST='mariadb'
DB_PORT='3306'

GREEN='\033[0;32m'
NC='\033[0m'

log_ok()    { printf "%b\n" "${GREEN}[OK] $*${NC}"; }

# --- Check required environment variables ---
: "${DOMAIN_NAME:?Missing DOMAIN_NAME}"
: "${MYSQL_DATABASE:?Missing MYSQL_DATABASE}"
: "${MYSQL_USER:?Missing MYSQL_USER}"
: "${WP_CREDENTIALS_FILE:?Missing WP_CREDENTIALS_FILE}"

# --- Get MYSQL_PASSWORD from secret file ---
if [ "${MYSQL_PASSWORD_FILE:-}" ] && [ -f "${MYSQL_PASSWORD_FILE}" ]; then
  MYSQL_PASSWORD="$(tr -d '\r\n' < "${MYSQL_PASSWORD_FILE}")"
else
  : "${MYSQL_PASSWORD:?Missing MYSQL_PASSWORD or MYSQL_PASSWORD_FILE}"
fi

# --- Wait until MariaDB is ready ---
until mariadb-admin ping -h"${DB_HOST}" -P"${DB_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
  sleep 1
done

# --- Get WP admin credentials from secret file ---
if [ -z "${WP_ADMIN_USER:-}" ] && [ -f "${WP_CREDENTIALS_FILE}" ]; then
  WP_ADMIN_USER="$(grep -m1 '^WP_ADMIN_USER=' "${WP_CREDENTIALS_FILE}" | cut -d= -f2- | tr -d '\r\n')"
else
  : "${WP_ADMIN_USER:?Missing WP_ADMIN_USER or WP_CREDENTIALS_FILE}"
fi

if [ -z "${WP_ADMIN_EMAIL:-}" ] && [ -f "${WP_CREDENTIALS_FILE}" ]; then
  WP_ADMIN_EMAIL="$(grep -m1 '^WP_ADMIN_EMAIL=' "${WP_CREDENTIALS_FILE}" | cut -d= -f2- | tr -d '\r\n')"
else
  : "${WP_ADMIN_EMAIL:?Missing WP_ADMIN_EMAIL or WP_CREDENTIALS_FILE}"
fi

if [ -z "${WP_ADMIN_PASSWORD:-}" ] && [ -f "${WP_CREDENTIALS_FILE}" ]; then
  WP_ADMIN_PASSWORD="$(grep -m1 '^WP_ADMIN_PASSWORD=' "${WP_CREDENTIALS_FILE}" | cut -d= -f2- | tr -d '\r\n')"
else
  : "${WP_ADMIN_PASSWORD:?Missing WP_ADMIN_PASSWORD or WP_CREDENTIALS_FILE}"
fi

# --- Get WP secondary user credentials from secret file ---
if [ -z "${WP_USER:-}" ] && [ -f "${WP_CREDENTIALS_FILE}" ]; then
  WP_USER="$(grep -m1 '^WP_USER=' "${WP_CREDENTIALS_FILE}" | cut -d= -f2- | tr -d '\r\n')"
fi
: "${WP_USER:?Missing WP_USER}"

if [ -z "${WP_USER_EMAIL:-}" ] && [ -f "${WP_CREDENTIALS_FILE}" ]; then
  WP_USER_EMAIL="$(grep -m1 '^WP_USER_EMAIL=' "${WP_CREDENTIALS_FILE}" | cut -d= -f2- | tr -d '\r\n')"
fi
: "${WP_USER_EMAIL:?Missing WP_USER_EMAIL}"

if [ -z "${WP_USER_PASSWORD:-}" ] && [ -f "${WP_CREDENTIALS_FILE}" ]; then
  WP_USER_PASSWORD="$(grep -m1 '^WP_USER_PASSWORD=' "${WP_CREDENTIALS_FILE}" | cut -d= -f2- | tr -d '\r\n')"
fi
: "${WP_USER_PASSWORD:?Missing WP_USER_PASSWORD}"

# --- Create wp-config.php if it doesn't exist ---
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
  wp --allow-root --path="${WP_PATH}" config create \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${MYSQL_PASSWORD}" \
    --dbhost="${DB_HOST}:${DB_PORT}"
fi

# --- Install WordPress (only once) ---
if ! wp --allow-root --path="${WP_PATH}" --url="https://${DOMAIN_NAME}" core is-installed; then
  : "${DOMAIN_NAME:?Missing DOMAIN_NAME}"
  : "${WP_TITLE:?Missing WP_TITLE}"
  : "${WP_ADMIN_USER:?Missing WP_ADMIN_USER}"
  : "${WP_ADMIN_PASSWORD:?Missing WP_ADMIN_PASSWORD}"
  : "${WP_ADMIN_EMAIL:?Missing WP_ADMIN_EMAIL}"

  wp --allow-root --path="${WP_PATH}" core install \
    --url="https://${DOMAIN_NAME}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --skip-plugins --skip-themes

  # --- Create a second (non-admin) WordPress user ---
  if ! wp --allow-root --path="${WP_PATH}" user get "${WP_USER}" >/dev/null 2>&1; then
    wp --allow-root --path="${WP_PATH}" user create "${WP_USER}" "${WP_USER_EMAIL}" \
      --user_pass="${WP_USER_PASSWORD}" \
      --role=author
  fi
fi

log_ok "Wordpress installation is completed!"

exec php-fpm8.2 -F
