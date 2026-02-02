#!/bin/bash

# Start the mariadb service
/etc/init.d/mariadb start

# Check if the database already exists
if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	DB_EXISTS=1
else
	DB_EXISTS=0
fi

if [ $DB_EXISTS -eq 0 ]; then
	# Create the database and user if they don't exist
	echo "Database ${MYSQL_DATABASE} does not exist. Creating..."
	mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
else
	echo "Database ${MYSQL_DATABASE} already exists. Skipping creation."
fi




















set -euo pipefail

: "${MYSQL_DATABASE:?missing MYSQL_DATABASE}"
: "${MYSQL_USER:?missing MYSQL_USER}"
: "${MYSQL_PASSWORD:?missing MYSQL_PASSWORD}"
: "${MYSQL_ROOT_PASSWORD:?missing MYSQL_ROOT_PASSWORD}"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Volume permissions (important with named volumes)
mkdir -p /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

first_init=0
if [ ! -d "/var/lib/mysql/mysql" ]; then
    first_init=1
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null
fi

if [ "$first_init" -eq 1 ]; then
    # Start in background only to run initialization SQL once
    mysqld_safe --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock &
    pid="$!"

    for i in {1..60}; do
        if mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done

    if ! mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent >/dev/null 2>&1; then
        echo "MariaDB failed to start (socket not ready)."
        exit 1
    fi

    # On fresh install, root has no password yet -> no -p here
    mysql --protocol=socket --socket=/run/mysqld/mysqld.sock -u root <<SQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL

    # Now root has a password -> use -p
    mysqladmin --protocol=socket --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid" || true
fi

# Normal start (foreground)
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock
