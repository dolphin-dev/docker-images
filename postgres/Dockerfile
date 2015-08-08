FROM postgres:latest

MAINTAINER dolphindev <oze@digital-globe.co.jp>

ADD init-database.sh /docker-entrypoint-initdb.d/

RUN echo "host all all 172.17.0.1/16 trust" >> /var/lib/postgresql/data/pg_hba.conf

RUN echo "host all all 192.168.59.0/24 trust" >> /var/lib/postgresql/data/pg_hba.conf 
