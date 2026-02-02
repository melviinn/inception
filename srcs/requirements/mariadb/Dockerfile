FROM debian:bookworm

RUN apt update -y && apt-get install -y mariadb-server

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

EXPOSE 3306

# Copy script and give execution rights
COPY ./tools/script.sh /
RUN chmod +x /script.sh

# Launch script
CMD [ "/script.sh" ]
