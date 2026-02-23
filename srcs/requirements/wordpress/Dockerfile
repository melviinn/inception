FROM debian:bookworm

# Install the required dependencies
RUN apt update -y && apt-get install -y wget\
	php8.2\
	tar\
	php-fpm\
	php-mysql\
	mariadb-client\
	&& rm -rf /var/lib/apt/lists/*

# Install WordPress files into /var/www/html
RUN mkdir -p /var/www/html
RUN wget https://fr.wordpress.org/wordpress-6.9.1-fr_FR.tar.gz -O /tmp/wp.tar.gz \
	&& tar -xzf /tmp/wp.tar.gz -C /var/www \
	&& mv /var/www/wordpress/* /var/www/html/ \
	&& rm -rf /var/www/wordpress /tmp/wp.tar.gz

# Download the wp CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Give permissions and give access to the command 'wp'
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# Listen on port 9000 for php-fpm and remove the allowed clients restriction
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|g' /etc/php/8.2/fpm/pool.d/www.conf \
    && sed -i '/^listen\.allowed_clients\s*=/d' /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/script.sh /
RUN chmod +x /script.sh

CMD [ "/script.sh" ]
