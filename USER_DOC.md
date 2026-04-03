# User Documentation

## Services Overview

<!-- Descrizione dei servizi -->

## How to Start the Project

To start the infrastructure, run:

```
docker-compose up --build
```

## How to Stop the Project

To stop the infrastructure:

```
docker-compose down
```


## Access the Website

<!-- aggiornare quando configuro dominio -->
<!-- dominio, https -->

## Access the Admin Panel

<!-- aggiornare quando configuro wordpress -->
<!-- wordpress admin -->


## Credentials Management

All credentials are defined in the `.env` file located in the `srcs/` directory.

This includes:

* Database credentials
* WordPress administrator account
* WordPress user account

To modify credentials, edit the `.env` file before starting the project.

⚠️ Do not share this file publicly, as it contains sensitive information.


## Check Services Status

<!-- docker ps ecc -->
