#!/bin/bash
set -e    # Exit immediately if a command exits with a non-zero status

# --- Colors / logging ---
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

log_info()  { printf "%b\n" "${BLUE}[INFO] $*${NC}"; }
log_ok()    { printf "%b\n" "${GREEN}[OK] $*${NC}"; }
log_warn()  { printf "%b\n" "${YELLOW}[WARN] $*${NC}"; }
log_error() { printf "%b\n" "${RED}[ERROR] $*${NC}" >&2; }

DATADIR="/var/lib/mysql"

# --- Read secrets from file (/run/secrets/...) ---
if [ -z "${MYSQL_PASSWORD:-}" ] && [ -n "${MYSQL_PASSWORD_FILE:-}" ]; then
  [ -f "$MYSQL_PASSWORD_FILE" ] || { log_error "Missing secret file: $MYSQL_PASSWORD_FILE"; exit 1; }
  MYSQL_PASSWORD="$(tr -d '\r\n' < "$MYSQL_PASSWORD_FILE")"
  export MYSQL_PASSWORD
fi

if [ -z "${MYSQL_ROOT_PASSWORD:-}" ] && [ -n "${MYSQL_ROOT_PASSWORD_FILE:-}" ]; then
  [ -f "$MYSQL_ROOT_PASSWORD_FILE" ] || { log_error "Missing secret file: $MYSQL_ROOT_PASSWORD_FILE"; exit 1; }
  MYSQL_ROOT_PASSWORD="$(tr -d '\r\n' < "$MYSQL_ROOT_PASSWORD_FILE")"
  export MYSQL_ROOT_PASSWORD
fi

# --- Check if the environments var are specified (return if one is missing) ---
: "${MYSQL_DATABASE:?missing MYSQL_DATABASE environment variable}"
: "${MYSQL_USER:?missing MYSQL_USER environment variable}"
: "${MYSQL_PASSWORD:?missing MYSQL_PASSWORD environment variable}"
: "${MYSQL_ROOT_PASSWORD:?missing MYSQL_ROOT_PASSWORD environment variable}"

# --- Create (if not exist) data directory and socket directory and gave correct permissions ---
mkdir -p /run/mysqld "$DATADIR"
chown -R mysql:mysql /run/mysqld "$DATADIR"

# --- Init SQL (DB/user) if the database does not already exist ---
is_db_created=0
if [ ! -d "$DATADIR/$MYSQL_DATABASE" ]; then
  is_db_created=1
fi

if [ "$is_db_created" -eq 1 ]; then
  mariadbd --silent-startup --skip-networking >/dev/null 2>&1 &
  pid="$!"

  # --- Wait for the database to be ready (timeout: 60s) ---
  for i in {1..60}; do
    if mysqladmin ping --silent >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  # --- Check if the database is ready after timeout ---
  mysqladmin ping --silent >/dev/null 2>&1 \
    || { log_error "MariaDB not ready after timeout"; exit 1; }

  # --- Create database and user, and set root password ---
  log_ok "Creating database/user..."
  mysql -u root <<SQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL

  # --- Temporarily shutdown the database to apply changes ---
  mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" -s shutdown >/dev/null 2>&1

  # --- Wait for the database process to exit ---
  wait "$pid"
else
  log_warn "Database '$MYSQL_DATABASE' already present. Skipping creation..."
fi

log_ok "Mariadb initilisation completed!"

# --- Start MariaDB in foreground ---
exec mariadbd --silent-startup
