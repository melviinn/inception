FROM debian:bookworm

RUN apt update -y && apt-get install -y mariadb-server

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf


COPY ./tools/script.sh /
RUN chmod +x /script.sh

# Launch script
CMD [ "/script.sh" ]
