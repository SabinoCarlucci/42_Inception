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

### WordPress Service

The WordPress service is built using PHP-FPM and does not include a web server.

At startup, a setup script:

* Downloads WordPress if not already present
* Creates the `wp-config.php` file using environment variables
* Sets correct file permissions
* Installs WordPress automatically after checking if it's already installed
* Creates the administrator account
* Creates an additional user account

PHP-FPM runs as the main process and listens on port 9000, allowing NGINX to communicate with it.

#### WordPress Environment Variables

Additional WordPress installation settings are defined in the .env file.

Example:

WP_TITLE=inception

WP_ADMIN_USER=scarlucc42
WP_ADMIN_PASSWORD=1234
WP_ADMIN_EMAIL=scarlucc@student.42.fr

WP_USER=user42
WP_USER_EMAIL=user42@student.42.fr
WP_USER_PASSWORD=123

#### PHP Extensions

The WordPress container requires several PHP extensions to function correctly:

* `php-fpm`: executes PHP code and handles requests from NGINX
* `php-mysql`: enables communication with the MariaDB database
* `php-curl`: allows HTTP requests (used by plugins and APIs)
* `php-gd`: handles image processing (thumbnails, resizing)
* `php-intl`: provides internationalization support
* `php-mbstring`: manages multibyte strings (UTF-8 encoding)
* `php-soap`: supports SOAP protocol (used by some plugins)
* `php-xml`: processes XML data (RSS feeds, APIs)
* `php-zip`: enables handling of compressed files (themes, plugins)

Additional tools:

* `wget` and `curl` are used to download WordPress and external resources.

These extensions ensure compatibility with WordPress core features and plugins.

#### WordPress and Database Connection

WordPress connects to the MariaDB container using environment variables defined in the `.env` file.

The connection parameters are injected into the `wp-config.php` file at container startup:

* `DB_NAME`: database name
* `DB_USER`: database user
* `DB_PASSWORD`: database password
* `DB_HOST`: hostname of the database server

The `DB_HOST` is set to `mariadb`, which corresponds to the name of the MariaDB service in `docker-compose.yml`.

Docker automatically resolves this name to the correct container IP through the internal network.

This allows WordPress to communicate with the database without exposing any ports externally.

The connection flow is:

WordPress (PHP-FPM) → Docker Network → MariaDB (port 3306)

### Internal Networking

Docker provides an internal DNS system that allows containers to communicate using service names.

For example:

* The WordPress container connects to MariaDB using:
  * `DB_HOST=mariadb`

Docker automatically resolves `mariadb` to the correct container IP address.

This removes the need for manual IP management and ensures stable communication between services.

### Connection Testing

To verify connectivity between containers:

```
docker exec -it wordpress bash
apt update && apt install -y netcat-openbsd
nc -zv mariadb 3306
```


A successful connection confirms that:

* The Docker network is working
* The database service is reachable

Note: This test only checks network connectivity, not authentication.

### MariaDB Service

The MariaDB service is built from a custom Dockerfile.

* The base image is Debian.
* MariaDB server is installed manually.
* An initialization script (`init.sh`) is used to:

  * Start the database service
  * Create the WordPress database
  * Create a database user
  * Set the root password

Additional setup is required to ensure MariaDB runs correctly inside a container.

* The directory `/var/run/mysqld` is created manually because it may not exist in the container environment.
* Ownership is assigned to the `mysql` user using `chown`, as MariaDB does not run as root.
* Package manager cache is removed to reduce the image size.

Configuration files are placed in `/etc/mysql/mariadb.conf.d/`, following MariaDB's modular configuration structure.

### MariaDB Configuration and Initialization

The MariaDB service uses two different types of files:

* Configuration file (`50-server.cnf`): defines how the database server behaves (networking, ports, file locations).
* Initialization script (`init.sh`): executed at container startup to initialize and configure the database.

The configuration file is manually created and copied into the container, following MariaDB's modular configuration system.

The initialization script ensures that:

* The database is initialized if needed
* The server is started temporarily for setup
* Users and databases are created safely
* The server is restarted in normal mode

A waiting mechanism is used to ensure that MariaDB is fully ready before executing SQL commands.