*This project has been created as part of the 42 curriculum by scarlucc.*

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


## Instructions (to be completed)

<!-- Quando scrivo docker compose -->
<!-- Come buildare e avviare il progetto -->

## Technical Choices

### MariaDB

MariaDB was installed manually using a Debian base image instead of using a prebuilt Docker image.
This approach follows the project requirement of building custom images and provides a deeper understanding of how database services are configured.


## Comparisons (to be completed)

* Virtual Machines vs Docker
* Secrets vs Environment Variables
* Docker Network vs Host Network
* Docker Volumes vs Bind Mounts

## Resources (to be completed)

<!-- Documentazione + come hai usato AI -->
* Quick introduction to Docker
https://youtu.be/Gjnup-PuquQ?si=efLqPMeDoFO7kQZR

