FROM ubuntu:noble AS add-apt-repositories

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y wget gnupg ca-certificates \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg \
 && echo 'deb [signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ noble-pgdg main' \
    > /etc/apt/sources.list.d/pgdg.list

FROM ubuntu:noble

LABEL maintainer="sameer@damagehead.com"

ENV PG_APP_HOME="/etc/docker-postgresql" \
    PG_VERSION=17 \
    PG_USER=postgres \
    PG_HOME=/var/lib/postgresql \
    PG_RUNDIR=/run/postgresql \
    PG_LOGDIR=/var/log/postgresql \
    PG_CERTDIR=/etc/postgresql/certs

ENV PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin \
    PG_DATADIR=${PG_HOME}/${PG_VERSION}/main

COPY --from=add-apt-repositories /usr/share/keyrings/postgresql.gpg /usr/share/keyrings/postgresql.gpg

COPY --from=add-apt-repositories /etc/apt/sources.list.d/pgdg.list /etc/apt/sources.list.d/pgdg.list

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y acl sudo locales \
      postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
      postgresql-${PG_VERSION}-postgis-3 postgresql-${PG_VERSION}-pgvector \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && locale-gen en_US.UTF-8 \
 && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
 && ln -sf ${PG_DATADIR}/postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf \
 && ln -sf ${PG_DATADIR}/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
 && ln -sf ${PG_DATADIR}/pg_ident.conf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf \
 && rm -rf ${PG_HOME} \
 && rm -rf /var/lib/apt/lists/*

COPY runtime/ ${PG_APP_HOME}/

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 5432/tcp

WORKDIR ${PG_HOME}

ENTRYPOINT ["/sbin/entrypoint.sh"]
