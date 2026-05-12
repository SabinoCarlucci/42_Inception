*This project has been created as part of the 42 curriculum by scarlucc*

# Inception

## Description

This project consists in setting up a small infrastructure using Docker and Docker Compose.
The goal is to create multiple interconnected services (NGINX, WordPress, MariaDB) following strict rules.

## Project Architecture

The infrastructure is composed of three main services running in separate Docker containers:

* **NGINX**: acts as the only entry point, handling HTTPS requests (port 443).
* **WordPress + PHP-FPM**: processes dynamic content.
* **MariaDB**: stores the WordPress database.

### Data persistence

Two Docker volumes are used:

* One for the database (`mariadb_data`)
* One for the WordPress files (`wordpress_data`)

### Networking

All containers are connected through a custom Docker network (`inception_network`), allowing secure internal communication.

### Service communication

* NGINX communicates with WordPress (PHP-FPM) on port 9000.
* WordPress communicates with MariaDB on port 3306.


## Instructions

### Build and start the infrastructure

```bash
make
```

or manually:

```bash
docker compose -f srcs/docker-compose.yml up --build
```

### Stop containers

```bash
make down
```

### Remove containers and Docker volumes

```bash
make clean
```

### Completely reset the project

```bash
make fclean
```

### Rebuild everything

```bash
make re
```

### Access the website

Open:

```text
https://<login>.42.fr
```

Example:

```text
https://scarlucc.42.fr
```

The domain must be mapped inside `/etc/hosts`.

## Technical Choices

### MariaDB

MariaDB was installed manually using a Debian base image instead of using a prebuilt Docker image.
This approach follows the project requirement of building custom images and provides a deeper understanding of how database services are configured.


## Comparisons

### Virtual Machines vs Docker

Virtual machines emulate a complete operating system and require more resources.
Docker containers share the host kernel and are lighter, faster, and easier to deploy.

### Secrets vs Environment Variables

Environment variables are simple and convenient for development.
Docker secrets provide a more secure way to manage sensitive data such as passwords.

### Docker Network vs Host Network

Docker bridge networks isolate containers while still allowing communication between services.
Host networking removes isolation and is forbidden in this project.

### Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker itself.
Bind mounts directly map host directories into containers.

This project uses bind mounts to comply with the requirement of storing persistent data in:

`/home/<login>/data/`

## Resources

### Docker documentation

https://docs.docker.com/

### Docker Compose documentation

https://docs.docker.com/compose/

### NGINX documentation

https://nginx.org/en/docs/

### MariaDB documentation

https://mariadb.org/documentation/

### WordPress documentation

https://developer.wordpress.org/

### PHP-FPM documentation

https://www.php.net/manual/en/install.fpm.php

### Learning resources

#### Quick introduction to Docker
  https://youtu.be/Gjnup-PuquQ?si=efLqPMeDoFO7kQZR

#### More in depth guide to Docker
  https://www.youtube.com/watch?v=pg19Z8LL06w

#### Even more in depth
  https://www.youtube.com/watch?v=3c-iBn73dDE

#### Project guide
  https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok


## AI Usage

Artificial intelligence tools were used as learning support for:

- understanding Docker concepts
- debugging configuration issues
- improving documentation
- understanding networking and container communication

All code, configurations, and architecture decisions were reviewed, tested, and understood before integration into the project.

### Edit

Find .env file here: https://github.com/SabinoCarlucci/42_Inception_env
