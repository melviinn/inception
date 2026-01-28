# Penultimate version of Alpine
FROM alpine:3.22

# Installer NGINX
RUN apk add --no-cache nginx openssl

# Creer le fichier de confif
RUN mkdir /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
	-keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt \
	-subj "/C=FR/ST=France/L=Paris/O=42\ School/OU=mduchauf/CN=mduchauf/"

# COPY ./conf/nginx.conf /etc/nginx/conf.d/nginx.conf
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
# COPY ./conf/default.conf /etc/nginx/conf.d/default.conf


# Copier les fichiers de l'application
WORKDIR /app
COPY . /app

# Exposer le port 443
EXPOSE 443

# Lancer NGINX au premier plan
CMD ["nginx", "-g", "daemon off;"]
