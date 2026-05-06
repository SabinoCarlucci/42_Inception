# User Documentation

## Overview

This project provides a small web infrastructure composed of three services:

* **NGINX**: acts as the only entry point and serves the website over HTTPS (port 443)
* **WordPress (PHP-FPM)**: handles the application logic and generates dynamic content
* **MariaDB**: stores the website data (posts, users, settings)

All services run in separate Docker containers and communicate through a private Docker network.

---

## Available Services

| Service   | Role                          | Port |
| --------- | ----------------------------- | ---- |
| NGINX     | Web server (HTTPS only)       | 443  |
| WordPress | PHP application (via PHP-FPM) | 9000 |
| MariaDB   | Database server               | 3306 |

---

## NGINX Configuration

NGINX acts as the only entry point to the infrastructure and serves the website over HTTPS.

It is configured to:

- Listen on port 443 (HTTPS only)
- Use a self-signed SSL certificate
- Serve files from the WordPress volume
- Forward PHP requests to the WordPress container via FastCGI

### FastCGI Communication

NGINX communicates with WordPress using:
```
fastcgi_pass wordpress:9000;
```

This works because all containers are on the same Docker network, where:

- `wordpress` is the service name
- Docker provides automatic DNS resolution

### Shared Volume

NGINX and WordPress share the same volume:
```
/var/www/html
```

This allows:

- WordPress to write files
- NGINX to serve them

Without this shared volume, the website would not work.

---

## Starting the Project

To build and start all services:

```
docker compose up --build
```

To run in background:

```
docker compose up -d --build
```

### First Startup Behavior (Wordpress)

On first startup:

- WordPress files are downloaded
- `wp-config.php` is generated
- Database connection is configured

On subsequent restarts:

- Setup is skipped if files already exist
- Existing data is preserved via Docker volumes

---

## Stopping the Project

To stop the containers:

```
docker compose down
```

To stop and remove volumes (⚠️ deletes all data):

```
docker compose down -v
```

### Cleaning Persistent Data (Troubleshooting)

In some cases (e.g., failed initialization, wrong credentials, corrupted database), containers may not start correctly even after fixing the configuration.

This happens because data is stored persistently on the host machine.

To completely reset the environment:

1. Stop all containers:

```
docker-compose down
```

2. Remove database and website data (⚠️ this will permanently delete all stored data):

```
sudo rm -rf /home/<login>/data/mariadb/*
sudo rm -rf /home/<login>/data/wordpress/*
```

3. Restart the project:

```
docker-compose up --build
```

This forces the containers to reinitialize from scratch.

⚠️ Use this only during development or troubleshooting, as all data will be lost.


---

## Accessing the Website

Once the project is running, open a browser and go to:

```
https://<your_login>.42.fr
```

Example:

```
https://scarlucc.42.fr
```

Make sure your domain is correctly mapped to your local IP (via `/etc/hosts`).

### Local Domain Configuration

You must map your domain to your local machine by editing:
```
/etc/hosts
```


Example:
```
127.0.0.1 <your_login>.42.fr
```


Without this step, the website will not be reachable.

---

## Accessing the WordPress Admin Panel

The admin panel is available at:

```
https://<your_login>.42.fr/wp-admin
```

Use the administrator credentials defined in the `.env` file.

---

## Managing Credentials

Credentials are stored in two places:

### 1. Environment variables (`.env`)

Located in:

```
srcs/.env
```

Contains:

* Database name and user
* WordPress admin credentials
* Domain name

### 2. Secret files (recommended)

Located in:

```
secrets/
```

Examples:

* `db_password.txt`
* `db_root_password.txt`

⚠️ These files must not be pushed to Git.

---

## Checking Service Status

### View running containers

```
docker ps
```

---

### View logs

```
docker logs <container_name>
```

Examples:

```
docker logs mariadb
docker logs wordpress
docker logs nginx
```

---

### Access a container

```
docker exec -it <container_name> bash
```

Example:

```
docker exec -it mariadb bash
```

---

## Verifying the Database

Inside the MariaDB container:

```
mysql -u root -p
```
When prompted, type root password, then to verify that the database is properly initialized::

```
SHOW DATABASES;
```
The expected output should include the WordPress database defined in the .env file.

To check database content:

```
USE <database_name>; SHOW TABLES;
```

```
SELECT user, host FROM mysql.user;
```

This allows verification that the database and users have been correctly created.

---

## Data Persistence

All data is stored on the host machine in:

```
/home/<login>/data/
```

Directories:

* `mariadb/`: database files
* `wordpress/`: website files

This ensures that data is not lost when containers are stopped or removed.

### Volume Verification

To verify that data is correctly stored using Docker volumes:

1. List volumes:

```bash
docker volume ls
```

2. Inspect the MariaDB volume:

```bash
docker volume inspect <volume_name>
```

Ensure that the mount point corresponds to:

```
/home/<login>/data/
```

This confirms that the project complies with the requirement of storing persistent data on the host machine.


---

## Troubleshooting

### Website not loading

* Check NGINX container logs
* Verify domain configuration

### 403 Forbidden Error (NGINX)

If you see a 403 Forbidden error, it is usually caused by incorrect file permissions.

Example error in logs:
```
Permission denied
```

#### Fix

Inside the WordPress container:
```
docker exec -it wordpress bash
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
```


Then restart the project:
```
docker compose down
docker compose up
```

This ensures that NGINX can read WordPress files correctly.

### Database connection errors

* Ensure MariaDB container is running
* Check environment variables

### Permission issues

* Verify ownership of mounted directories
* Ensure correct user (mysql / www-data)

### Network Debugging (Advanced)

If services cannot communicate with each other (e.g., WordPress cannot connect to MariaDB), you can perform network checks from inside containers.

1. Access the WordPress container
```
docker exec -it wordpress bash
```

2. Install temporary debugging tools
```
apt update && apt install -y iputils-ping netcat-openbsd
```

3. Test connectivity to MariaDB

Check DNS and network:
```
ping mariadb
```

Check if the database port is reachable:
```
nc -zv mariadb 3306
```

Expected result:
```
Connection to mariadb (...) 3306 port succeeded!
```

Note:
These tools are installed only temporarily and will be removed when the container is rebuilt.

---
