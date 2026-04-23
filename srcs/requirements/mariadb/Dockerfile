#penultima versione stabile
FROM debian:bookworm

#installa mariaDB
RUN apt-get update && apt-get install -y mariadb-server \
	#pulisci cache apt per ridurre dimensione immagine
    && rm -rf /var/lib/apt/lists/*

# crea cartelle
RUN mkdir -p /var/run/mysqld \
	#change owner, per evitare problemi con permessi
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld

#copia da... a... 
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/
	#copia il file init.sh da tools e mettilo nell'immagine docker in /init.sh
	#serve perche' container non vede file nel pc, serve metterli in immagine
COPY ./tools/init.sh /init.sh
	#rendi script eseguibile dando permessi
RUN chmod +x /init.sh

#documenta porta indicata nella traccia (solo documentazione)
EXPOSE 3306

#dopo creazione container, lancia comando per avviare script
CMD ["/init.sh"]