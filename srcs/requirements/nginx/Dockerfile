# Penultimate version of Alpine
FROM alpine:3.22

# Installer NGINX
RUN apk add --no-cache nginx

# Copier les fichiers de l'application
WORKDIR /app
COPY . /app

# Créer le dossier pour les logs et pid de nginx
RUN mkdir -p /var/cache/nginx /var/run

# Exposer le port 80
EXPOSE 80

# Lancer NGINX au premier plan
CMD ["nginx", "-g", "daemon off;"]
