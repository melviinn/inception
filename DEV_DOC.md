This file must describe how a developer can:
◦ Set up the environment from scratch (prerequisites, configuration files, se-
crets).
◦ Build and launch the project using the Makefile and Docker Compose.
◦ Use relevant commands to manage the containers and volumes.
◦ Identify where the project data is stored and how it persists.

# Developer Documentation

## Prerequisites

1. Ensure that your user has the necessary permissions to run sudo commands.
2. Docker, Docker Compose and Make must be installed on your system.

<br>

### Installation of Docker, Docker Compose, Make and configuration of permissions

1. Install Docker & Docker Compose

```bash
# For Ubuntu
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
```

2. Install Make

```bash
# For Ubuntu
sudo apt-get install -y build-essential
```

3. Add your user to the Docker group to run Docker commands without sudo (optional but recommended)

```bash
sudo usermod -aG docker $USER		# Add the current user to the docker group
newgrp docker						# Apply the new group membership without logging out and back in
```

4. To access your website via `https://<login>.42.fr`, you must map the domain to your local machine.

Edit `/etc/hosts` and add the following line (replace `<login>` with your 42 login):

```bash
127.0.0.1 <login>.42.fr
```

Example (for `mduchauf`):

```bash
127.0.0.1 mduchauf.42.fr
```

You can edit the file with:

```bash
sudo nano /etc/hosts
```

Or append the line directly:

```bash
echo "127.0.0.1 <login>.42.fr" | sudo tee -a /etc/hosts
```

5. Create the data directory for the named volumes and set the correct permissions

```bash
sudo mkdir -p /home/<login>/data/mariadb /home/<login>/data/wordpress
sudo chown -R <login>:<login> /home/<login>/data
```

Replace `<login>` with your 42 login.

<br>
<br>

### Setup configuration files and secrets

1. Clone the repository to your local machine and navigate into the project directory.

```bash
git clone git@github.com:melviinn/inception.git inception
cd inception
```

3. Create and configure any necessary configuration files and secrets as per the project requirements. This may include setting up environment variables, database credentials, etc.

```bash
mkdir -p secrets/
touch secrets/db_password
touch secrets/db_root_password
touch secrets/wp_credentials
touch srcs/.env
```

4. Edit the `.env` file to include any necessary environment variables (e.g., database credentials, API keys, etc.).

```txt
# Example .env file
DOMAIN_NAME=

# MYSQL Configuration
MYSQL_DATABASE=
MYSQL_USER=
MYSQL_PASSWORD_FILE=/run/secrets/...
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/...

# Wordpress Configuration
WP_TITLE=
WP_CREDENTIALS_FILE=/run/secrets/...
```

You also need to add the actual secrets (e.g., database passwords, WordPress credentials) to the respective files in the `secrets/` directory. Make sure to keep these secrets secure and do not commit them to version control.

wp_credentials file should contain the following format:

```txt
# Example wp_credentials file
WP_ADMIN_USER=
WP_ADMIN_PASSWORD=
```

Other secrets fils should only contain the respective password for root or normal user, for example:

```txt
# Example db_password file
my_secure_db_password
```

<br>
<br>

## Makefile commands

#### Build the docker images and start the project

```bash
make
```

#### Stop and remove all container, networks... `docker-compose up`

```bash
make down 						# ==> this will launch docker compose down
```

#### Removes all docker containers, networks, volumes, and images created by `docker-compose up`

```bash
make fclean
```

#### Removes all containers, networks, volumes, and images created by `docker-compose up` and restart the project

```bash
make re
```

#### Display information about the current state of Docker images, containers, and volumes

```bash
make infos
```

#### You also have cleanup commands to remove only containers, volumes, or images:

```bash
make clean-containers
make clean-volumes
make clean-imgs
```

<br>
<br>

## Commands utils

#### List all dockers containers

```bash
docker ps -a
```

#### List all dockers images

```bash
docker images
```

#### List all dockers volumes

```bash
docker volume ls
```

#### View logs of a specific container

```bash
docker logs <CONTAINER_NAME_OR_ID>
# Example:
docker logs wordpress
```

#### Remove a specific docker image

```bash
docker rmi <IMAGE_ID>
```
