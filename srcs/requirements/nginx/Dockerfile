FROM debian:bookworm

# Install NGINX & OpenSSL
RUN apt update -y && apt-get install -y nginx openssl

# Create the config file for SSL certification
RUN mkdir /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
	-keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt \
	-subj "/C=FR/ST=France/L=Paris/O=42\ School/OU=mduchauf/CN=mduchauf/"

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

# Copy the files of the application
WORKDIR /app
COPY . /app

# Expose port 443
EXPOSE 443

# Launch nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
