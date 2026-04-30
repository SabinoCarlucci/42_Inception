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

## Starting the Project

To build and start all services:

```
docker-compose up --build
```

To run in background:

```
docker-compose up -d --build
```

---

## Stopping the Project

To stop the containers:

```
docker-compose down
```

To stop and remove volumes (⚠️ deletes all data):

```
docker-compose down -v
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

Then:

```
SHOW DATABASES;
```

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

---

## Troubleshooting

### Website not loading

* Check NGINX container logs
* Verify domain configuration

### Database connection errors

* Ensure MariaDB container is running
* Check environment variables

### Permission issues

* Verify ownership of mounted directories
* Ensure correct user (mysql / www-data)

---
