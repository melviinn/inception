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
<br>

### Installation of Docker, Docker Compose, and Make (if not already installed)

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

```

<br>
<br>

## Makefile commands

#### Build the docker images and start the project

```bash
make
```

#### Remove all containers, networks, volumes, and images created by `docker-compose up`

```bash
make down 						# ==> this will launch docker compose down
```

#### Removes all docker images created by the Makefile

```bash
make clean-imgs
```

#### Removes all containers, networks, volumes, and images created by `docker-compose up` and restart the project

```bash
make re
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

#### Remove a specific docker image

```bash
docker rmi <IMAGE_ID>
```
