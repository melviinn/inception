# Table of contents

- [Prerequisites](#prerequisites)
  - [Required installation](#installation-of-docker-docker-compose-make-and-configuration-of-permissions)
  - [Config files & secrets](#setup-configuration-files-and-secrets)
  - [Docker named volumes](#data-persistence-for-volumes)
- [Makefile commands](#makefile-commands)
- [Commands utils](#commands-utils)

# Developer Documentation

## Prerequisites

1. Ensure that your user has the necessary permissions to run sudo commands.
<!-- 2. Docker, Docker Compose and Make must be installed on your system. -->

<br>

### Installation of Docker, Docker Compose, Make and configuration of permissions

1. Install Docker & Docker Compose

```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
```

2. Install Make

```bash
sudo apt-get install -y build-essential
```

3. Add your user to the Docker group to run Docker commands without sudo (optional but recommended)

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

> [Docker post installation](https://docs.docker.com/engine/install/linux-postinstall/)

4. To access your website via `https://<login>.42.fr`, you must configure `/etc/hosts`.

The first lines of `/etc/hosts` should be:

```bash
127.0.0.1	localhost <login>.42.fr
127.0.1.1	inception
```

> The second line is important for `sudo` hostname resolution.
> Without it, you may get errors like: `sudo: unable to resolve host inception`.

You can edit the file manually:

```bash
sudo nano /etc/hosts
```

Or replace the first two lines automatically (while keeping the rest of the file unchanged):

```bash
{ printf "127.0.0.1\tlocalhost <login>.42.fr\n127.0.1.1\tinception\n"; tail -n +3 /etc/hosts; } | sudo tee /etc/hosts > /dev/null
```

Replace `<login>` with your 42 login.

> Instead of hardcoding the domain in `/etc/hosts` with 'inception' or 'login' you can use variables like `$USER` or `$(hostname)` to make it more dynamic, but for simplicity and clarity, we will use hardcoded values in this project.

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
touch secrets/db_password secrets/db_root_password secrets/wp_credentials
touch srcs/.env
```

4. Edit the `.env` file to include any necessary environment variables (e.g., database credentials, API keys, etc.).

```txt
# Example .env file
DOMAIN_NAME=

# MYSQL Configuration
MYSQL_DATABASE=
MYSQL_USER=

# Wordpress Configuration
WP_TITLE=
```

You also need to add the actual `secrets` (e.g., database passwords, WordPress credentials) to the respective files in the `secrets/` directory. Make sure to keep these secrets secure and `do not commit them` to version control.

`wp_credentials` file should contain the following format:

```txt
# Example wp_credentials file
WP_ADMIN_USER=
WP_ADMIN_EMAIL=
WP_ADMIN_PASSWORD=

WP_USER=
WP_USER_EMAIL=
WP_USER_PASSWORD=
```

Other secrets fils should only contain the respective password for `root` or normal `user`, for example:

```txt
# Example db_password file
my_secure_db_password
```

```txt
# Example db_root_password file
my_secure_db_root_password
```

<br>
<br>

### Data persistence for volumes

The project uses `Docker named volumes` to persist data for the `MariaDB database` and `WordPress`. The volumes are defined in the `docker-compose.yml` file as follows:

```yaml
volumes:
  mariadb:
    name: mariadb_data
    driver: local
  wordpress:
    name: wordpress_data
    driver: local
```

To specifically store the data on your local machine `(/home/<login>/data)`, you have to configure the file `/etc/docker/daemon.json` and create the data directory with the correct permissions.

Create the data directory for the `named volumes` and set the correct permissions:

```bash
sudo mkdir -p /home/<login>/data/docker
sudo chown -R $USER:$USER /home/<login>/data/docker
```

Replace `<login>` with your 42 login.

Configure Docker to use the correct data directory for volumes:

```bash
sudo nano /etc/docker/daemon.json
```

And add the following content (replace `<login>` with your 42 login):

```json
{
  "data-root": "/home/<login>/data"
}
```

You then need to restart the Docker daemon for the changes to take effect:

```bash
sudo systemctl restart docker
```

This configuration ensures that all Docker data, including volumes, are stored in the specified directory on your local machine. The MariaDB and WordPress data will be persisted in the `mariadb_data` and `wordpress_data` volumes, which are located within the `/home/<login>/data` directory. (This ensure the data are in the right directory and that we don't use bind mounts, which are not allowed in this project)

> [Docker daemon](https://docs.docker.com/engine/daemon/)

## Makefile commands

#### Build the docker images and start the project

```bash
make
```

#### Stop and remove all containers created by `docker-compose up` without removing volumes or images

```bash
make down
```

#### Removes all `containers, networks, volumes, and images` created by `docker-compose up`

```bash
make fclean
```

#### Removes all docker's `data` and `cache`

```bash
make full-clean
```

#### Removes all `containers, networks, volumes, and images` created by `docker-compose up` and `restart` the project

```bash
make re
```

#### Display `informations` about the current state of Docker `images, containers, volumes, docker system usage and volumes mountpoints`

```bash
make infos
```

#### Display `logs` for all the `active containers`

```bash
make logs
```

#### Display `volumes mountpoints`

```bash
make inspect-vlm
```

#### You also have `cleanup` commands to remove only `containers, volumes, images or cache`:

```bash
make clean-containers
make clean-volumes
make clean-imgs
make clean-cache
```

<br>
<br>

## Commands utils

#### List all `dockers containers`

```bash
docker ps -a
```

#### List all `dockers images`

```bash
docker images
```

#### List all `dockers volumes`

```bash
docker volume ls
```

#### View `logs` of a `specific container`

```bash
docker logs <CONTAINER_NAME_OR_ID>
# Example:
docker logs wordpress
```

#### View `logs` for all `running container`

```bash
docker compose logs
```

#### `Remove` a specific `docker image`

```bash
docker rmi <IMAGE_ID>
```

#### Inspect a `specific volume`

```bash
docker volume inspect <volume_name>
```

#### View the docker `disk usage`

```bash
docker system df
```

#### Display `system informations` about docker

```bash
docker system info
```
