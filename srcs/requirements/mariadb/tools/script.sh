#!/bin/bash
set -euo pipefail

# Check si les variables d'environnement sont définies
: "${MYSQL_DATABASE:?missing MYSQL_DATABASE}"
: "${MYSQL_USER:?missing MYSQL_USER}"
: "${MYSQL_PASSWORD:?missing MYSQL_PASSWORD}"
: "${MYSQL_ROOT_PASSWORD:?missing MYSQL_ROOT_PASSWORD}"

# Préparation des dossiers nécessaires
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Check si c'est la première initialisation
first_init=0
if [ ! -d "/var/lib/mysql/mysql" ]; then
    first_init=1
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null
fi

if [ "$first_init" -eq 1 ]; then
    # Start temporaire (socket only) pour initialiser
    mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    pid="$!"

    # Wait until server is ready
    for i in {1..60}; do
        if mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done

    # Create database and user
    mysql --protocol=socket --socket=/run/mysqld/mysqld.sock -u root <<SQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL

    # Shutdown temporaire
    mysqladmin --protocol=socket --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid" || true
else
    echo "Database ${MYSQL_DATABASE} already exists. Skipping creation."
fi

# Démarrage normal en foreground (le conteneur reste UP)
exec mariadbd --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock
