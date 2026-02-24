_This project has been created as part of the 42 curriculum by mduchauf._

# Table of contents

- [Description](#description)
- [Instructions](#instructions)
  - [Quick start](#quick-start)
  - [Build & Start the project](#build-and-start-the-project)
- [Resources](#resources)
  - [Links](#links)
  - [AI utilisation](#ai-utilisation)
- [Project description](#project-description)

# <ins>Description</ins>

The **Inception** project is a **system administration** exercise whose main goal is to introduce the fundamentals of **containerization** using **Docker**.
The objective is to design, build, and deploy a small infrastructure composed of multiple services, each running in its own **Docker container**, and orchestrated using **Docker Compose**.

This project is carried out inside a **personal virtual machine** and focuses on understanding how modern applications are deployed in isolated, reproducible, and scalable environments.
Rather than using pre-built images, all services are built from **custom Dockerfiles**, ensuring full control over configuration, security, and behavior.

The infrastructure includes:

- An **NGINX** web server configured with **TLS1.3 (HTTPS only)**.
- A **WordPress** application running with **php-fpm**.
- A **MariaDB** database server.
- Persistent storage using **Docker named volumes**.
- A dedicated **Docker network** to isolate internal communications.

Special attention is given to security best practices, such as:

- Using environment variables and secrets instead of hard-coded credentials.
- Exposing only the required ports.
- Ensuring containers restart automatically in case of failure.

This project aims to provide a solid understanding of Docker concepts while highlighting the differences <ins>**between traditional virtual machines and container-based architectures**</ins>.

<br>
<br>

# <ins>Instructions</ins>

For full environment setup (prerequisites, host configuration, secrets, Docker permissions), see **[DEV_DOC.md](./DEV_DOC.md)**.

For runtime usage (services, access URLs, admin panel, checks), see **[USER_DOC.md](./USER_DOC.md)**.

## Quick start

1. Configure your domain in `/etc/hosts` so `<login>.42.fr` resolves locally.
2. Ensure Docker can store named volumes in `/home/<login>/data` (as required by the subject).
3. Fill `srcs/.env` and `secrets/` with your local values.

> Detailed steps are documented in **DEV_DOC.md**.

## Build & Start the project

To build all Docker images and start the containers:

```bash
make
```

This command will:

- Build the Docker images from your custom Dockerfiles.
- Start all services as defined in docker-compose.yml.
- Create the necessary Docker network and volumes.

<br>To stop all running containers without removing images or volumes:

```bash
make down
```

<br>To completely remove all containers, images, volumes and networks created:

```bash
make fclean
```

<br>Once the project is running, open your browser and go to:

[https://mduchauf.42.fr](https://mduchauf.42.fr) (replace `mduchauf` with your 42 login)

This will give you access to the WordPress website hosted on your NGINX container.

<br>
<br>

# <ins>Resources</ins>

## Links

#### This is the resources that I used to get started with the subjects and get all the requirements

- [Official Docker website](https://docs.docker.com)

- [List of Docker commands & instructions](https://gist.github.com/jpchateau/4efb6ed0587c1c0e37c3)

- [Youtube Docker tutorial](https://www.youtube.com/watch?v=pTFZFxd4hOI)

- [Docker secrets](https://docs.docker.com/engine/swarm/secrets/)

- [Docker volumes](https://docs.docker.com/storage/volumes/)

- [Mariadb installation](https://oleks.ca/2024/09/08/installation-de-mariadb-sur-debian/)

- [Wordpress installation](https://make.wordpress.org/cli/handbook/guides/installing/)

- [Wordpress utils wp config](https://developer.wordpress.org/cli/commands/config)

- [Wordpress utils wp core](https://developer.wordpress.org/cli/commands/core)

## AI Utilisation

- I used `AI` to help me find the right version of debian (just to be sure), and to find the right packages to install
- It also helped me to redact the `README` files and find the best explanations/structure for them
- It also give me some `utils function` in the `script` files (ex: checker for environment variables, cut credentials from secrets file and delete `\r\n` etc...)

<br>
<br>

# <ins>Project description</ins>

### Virtual Machines VS Docker:

Using Docker is lighter than having to embed a complete operating system. Here, the Docker container shares the machine's kernel (Linux, Windows, etc.) and only carries what is necessary (the application and its dependencies).

#### Comparatif VM et Docker:

| Criteria    | Virtual machine                         | Docker container           |
| :---------- | :-------------------------------------- | :------------------------- |
| Startup     | Minutes (full OS boot)                  | Seconds (single process)   |
| Disc size   | Gigabytes (full OS)                     | Megabytes (app only)       |
| RAM         | Reserved in blocks (e.g., 4 GB minimum) | Shared dynamically         |
| Isolation   | Complete (hardware hypervisor)          | Process (Linux namespaces) |
| Density     | 10-20 VMs per server                    | Hundreds of containers     |
| Portability | Average (proprietary VM format)         | Excellent (OCI standard)   |

=> [https://blog.stephane-robert.info/docs/conteneurs/moteurs-conteneurs/docker/](https://blog.stephane-robert.info/docs/conteneurs/moteurs-conteneurs/docker/)

---

### Secrets VS Environments Variables

The main difference between Docker secrets and environment variables is that a Docker secret can only be accessed by a service when explicitly granted a secrets attribute within the services top-level element. The secrets are then mounted as a file under /run/secrets/<secret_name> inside the container.
Environments variables are often available to as processes and it can be difficult to track access. They can also be printed in logs when debugging without your knowledge.

=> [https://docs.docker.com/compose/how-tos/use-secrets/](https://docs.docker.com/compose/how-tos/use-secrets/)

---

### Docker Network VS Host Network

| Type   | Isolation | Performance | Multi-host | Main use case                     |
| :----- | :-------- | :---------- | :--------- | :-------------------------------- |
| Bridge | ✅ Good   | ✅ Good     | ❌ No      | Development, multi-container apps |
| Host   | ❌ None   | ⚡ Maximum  | ❌ No      | Critical performance, monitoring  |

=> [https://blog.stephane-robert.info/docs/conteneurs/moteurs-conteneurs/docker/network/](https://blog.stephane-robert.info/docs/conteneurs/moteurs-conteneurs/docker/network/)

#### Bridge network (Docker network)

> In terms of Docker, a bridge network uses a software bridge which lets containers connected to the same bridge network communicate, while providing isolation from containers that aren't connected to that bridge network.<br>
> ==> [https://docs.docker.com/engine/network/drivers/bridge/](https://docs.docker.com/engine/network/drivers/bridge/)

#### Host Network

> If you use the host network mode for a container, that container's network stack isn't isolated from the Docker host (the container shares the host's networking namespace), and the container doesn't get its own IP-address allocated. For instance, if you run a container which binds to port 80 and you use host networking, the container's application is available on port 80 on the host's IP address.<br>
> ==> [https://docs.docker.com/engine/network/drivers/bridge/](https://docs.docker.com/engine/network/drivers/bridge/)

---

### Docker Volumes VS Bind Mounts

Volumes are the preferred mechanism for persisting data generated by and used by Docker containers. While bind mounts are dependent on the directory structure and OS of the host machine, volumes are completely managed by Docker. Volumes are a good choice for the following use cases:

- Volumes are easier to back up or migrate than bind mounts.
- You can manage volumes using Docker CLI commands or the Docker API.
- Volumes work on both Linux and Windows containers.
- Volumes can be more safely shared among multiple containers.
- New volumes can have their content pre-populated by a container or build.
- When your application requires high-performance I/O.

Volumes are not a good choice if you need to access the files from the host, as the volume is completely managed by Docker. Use bind mounts if you need to access files or directories from both containers and the host.

In our case we will use Docker Volumes cause we don't need to access the files from the host.

=> [https://docs.docker.com/engine/storage/volumes/](https://docs.docker.com/engine/storage/volumes/)
