#!/bin/bash

#ferma script se comando fallisce per evitare stati inconsistenti
set -e

echo "Starting MariaDB initialization..."

# Initialize MySQL data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing data directory..."
	#inizializza il database (prima volta)
	#se /var/lib/mysql e' vuota, database non parte, questo crea struttura base
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Start the server (no networking for setup)(maggior sicurezza)
echo "Starting temporary MariaDB server for setup..."
mysqld --skip-networking --socket=/run/mysqld/mysqld.sock --user=mysql &
pid="$!"

# Wait for MariaDB to be ready (altrimenti rischia di non creare database e/o utenti)
echo "Waiting for MariaDB to be ready..."
until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done
echo "MariaDB is ready!"

# Run setup SQL: create database and users
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Running setup SQL..."
    mysql --socket=/run/mysqld/mysqld.sock -u root << EOF #connessione senza password permessa durante setup
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    echo "Setup SQL completed."

    # Spegnimento pulito usando la nuova password appena impostata
    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
else

#vecchia versione
# Shut down temporary server
#echo "Shutting down temporary MariaDB..."
#mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

    echo "Database already exists, skipping setup."
    # Se esiste già, spegniamo il server temporaneo (usando la password) per riavviarlo normalmente
    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

# Wait for shutdown
wait "$pid" || true

# Start MariaDB normally (with networking)
echo "Initialization complete. Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock