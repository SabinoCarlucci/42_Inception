FROM debian:bookworm

# Install PHP-FPM and required extensions
RUN apt-get update && apt-get install -y \
# motore PHP-FPM (esegue codice PHP)
	php8.2-fpm \
# permette connessione database
	php8.2-mysql \
#consente richieste HTTP (API, plugin, download)
	php8.2-curl \
#gestione immagini (resize, thumbnail, ecc)
	php8.2-gd \
#supporto internalizzazione (lingue, formati)
	php8.2-intl \
#gestione stringhe multibyte (UTF-8, caratteri speciali)
	php8.2-mbstring \
#supporto protocollo SOAP (Simple Object Access Protocol)
#scambio messaggi strutturati tra app via internet, tramite HTTP
	php8.2-soap \
# parsing XML (RSS feed, API, config)
	php8.2-xml \
# gestione file zip (plugin, temi, upload)
	php8.2-zip \
# scaricare WordPress
	wget \
# alternativa a wget / richieste HTTP
	curl \
#client MySQL/MariaDB
	mariadb-client \
&& ln -s /usr/sbin/php-fpm8.2 /usr/local/bin/php-fpm \
&& rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create WordPress directory
WORKDIR /var/www/html

# Copy PHP-FPM configuration (correct version)
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/

# Copy and set permissions for setup script
COPY tools/setup_wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup_wordpress.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup_wordpress.sh"]