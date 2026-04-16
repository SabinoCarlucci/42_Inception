# Developer Documentation

## Prerequisites

<!-- Docker, Docker Compose -->

## Project Setup

.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   └── tools/
        └── wordpress/
            ├── Dockerfile
            ├── .dockerignore
            ├── conf/
            └── tools/


## Environment Configuration

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

The project uses bind mounts to ensure data persistence on the host machine.

According to the project requirements, all data must be stored in:
`/home/<login>/data/`

Two directories are used:

* `/home/<login>/data/mariadb`: stores the database files
* `/home/<login>/data/wordpress`: stores the WordPress website files

These directories are mounted into the containers:

* MariaDB: `/var/lib/mysql`
* WordPress: `/var/www/html`
* NGINX: `/var/www/html` (read-only access to website files)

This ensures that:

* Data is preserved even if containers are stopped or removed
* The host machine has direct access to the stored data


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

