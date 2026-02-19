FROM debian:bookworm

# Install NGINX & OpenSSL
RUN apt update -y && apt-get install -y nginx openssl

COPY ./tools/script.sh /
RUN chmod +x /script.sh

# Copy the files of the application
WORKDIR /app
COPY . /app

# Expose port 443
EXPOSE 443

CMD [ "/script.sh"]
