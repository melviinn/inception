FROM debian:bookworm

RUN apt update -y && apt-get install -y mariadb-server

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# COPY ./tools/script.sh /
# RUN chmod +x /script.sh
# CMD [ "/script.sh" ]
