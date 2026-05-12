#!/bin/bash
set -e

WP_PATH="/var/www/html"

# Read password from secret file
#if [ -n "$WORDPRESS_DB_PASSWORD_FILE" ] && [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
#    WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
#    export WORDPRESS_DB_PASSWORD
#fi

echo "Setting up WordPress..."

# Download and configure WordPress if not present
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Downloading WordPress..."
    wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
    tar -xzf /tmp/wordpress.tar.gz -C /tmp
    rm /tmp/wordpress.tar.gz

    # Copy only missing files (avoid overwriting existing content)
    cp -rn /tmp/wordpress/* "$WP_PATH" || true
    rm -rf /tmp/wordpress

    # Fetch security salts from WordPress API
    WP_SALTS=$(wget -qO- https://api.wordpress.org/secret-key/1.1/salt/)

    # Create wp-config.php
    cat > "$WP_PATH/wp-config.php" << EOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', '${WORDPRESS_DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

\$table_prefix = '${WORDPRESS_TABLE_PREFIX:-wp_}';

${WP_SALTS}

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', __DIR__ . '/');

require_once ABSPATH . 'wp-settings.php';
EOF

    # Set secure permissions
    find "$WP_PATH" -type d -exec chmod 755 {} \;
    find "$WP_PATH" -type f -exec chmod 644 {} \;
    chown -R www-data:www-data "$WP_PATH"

    echo "WordPress setup complete."
else
    echo "WordPress already initialized, skipping setup."
fi

# Wait for MariaDB
echo "Waiting for MariaDB connection..."

until mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
	sleep 2
done

# Install WordPress if not already installed
if ! wp core is-installed --allow-root --path="$WP_PATH"; then
	echo "Installing WordPress..."

	wp core install \
		--allow-root \
		--path="$WP_PATH" \
		--url="https://${DOMAIN_NAME}" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL"

	wp user create \
		"$WP_USER" \
		"$WP_USER_EMAIL" \
		--user_pass="$WP_USER_PASSWORD" \
		--allow-root \
		--path="$WP_PATH"

	echo "WordPress installation completed."
else
	echo "WordPress already installed."
fi

echo "Starting PHP-FPM..."

#php-fpm prende il posto dello script bash come processo principale
exec php-fpm8.2 -F