# Developer Documentation

## Prerequisites

<!-- Docker, Docker Compose -->

## Project Setup

<!-- struttura directory -->


## Environment Configuration

<!-- .env, secrets -->
The project uses a `.env` file located in the `srcs/` directory to store environment variables.

This file contains configuration values such as:

* Domain name
* Database name and user
* Database passwords
* WordPress administrator credentials
* WordPress user credentials

Using environment variables allows:

* Avoiding hardcoding sensitive data in Dockerfiles
* Making the configuration flexible and reusable

Example variables:

* `DOMAIN_NAME`: domain used to access the website
* `MYSQL_DATABASE`: name of the WordPress database
* `MYSQL_USER`: database user
* `WP_ADMIN_USER`: WordPress administrator username

⚠️ Sensitive information should not be committed to the repository. In production, Docker secrets should be used instead.


## Build and Run

The project is orchestrated using Docker Compose.

The `docker-compose.yml` file defines:

* Three services: NGINX, WordPress, and MariaDB
* Two volumes for persistent data
* A custom Docker network for communication

Each service is built from its own Dockerfile located in:

* `requirements/nginx/`
* `requirements/wordpress/`
* `requirements/mariadb/`

To build and start the project:

```
docker-compose up --build
```

To stop the project:

```
docker-compose down
```


## Managing Containers

<!-- docker commands -->

## Data Persistence

<!-- aggiornare quando configuro volumi -->
<!-- volumi -->

## Project Structure

<!-- aggiornare quando creo cartelle -->
<!-- spiegazione srcs/requirements -->

## Project Structure

The project is organized into several directories to clearly separate concerns and services.

### Root directory

* `Makefile`: contains commands to build and manage the project.
* `README.md`: general project overview.
* `USER_DOC.md`: instructions for end users.
* `DEV_DOC.md`: technical documentation for developers.

### secrets/

This directory contains sensitive information such as database credentials and passwords.
These files must not be pushed to the Git repository.

### srcs/

This directory contains all Docker-related configuration.

* `.env`: environment variables (domain name, database user, etc.).
* `docker-compose.yml`: defines and connects all services.

### requirements/

Each service has its own directory containing everything needed to build its Docker image.

#### mariadb/

* `Dockerfile`: builds the MariaDB image.
* `conf/`: database configuration files.
* `tools/`: initialization scripts.

#### nginx/

* `Dockerfile`: builds the NGINX image.
* `conf/`: NGINX configuration files.
* `tools/`: setup scripts.

#### wordpress/

* `Dockerfile`: builds the WordPress + PHP-FPM image.
* `conf/`: PHP and WordPress configuration.
* `tools/`: initialization scripts.

