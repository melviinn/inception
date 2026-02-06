FROM debian:bookworm

# Install MariaDB
RUN apt update -y && apt-get install -y mariadb-server

# Create the config file for MariaDB and copy it to the container
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/script.sh /
RUN chmod +x /script.sh


CMD [ "/script.sh" ]
