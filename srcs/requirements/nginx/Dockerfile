FROM debian:bookworm

# Install NGINX & OpenSSL
RUN apt update -y && apt-get install -y nginx openssl \
	&& rm -rf /var/lib/apt/lists/*

COPY ./tools/script.sh /
RUN chmod +x /script.sh

# Copy the files of the application for the script to access the files it needs
WORKDIR /app
COPY . /app

CMD [ "/script.sh"]
