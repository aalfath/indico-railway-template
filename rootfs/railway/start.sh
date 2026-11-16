#!/bin/bash
set -e
export UWSGI_PROCESSES="${UWSGI_PROCESSES:-2}"

if [ -z "$DATABASE_URL" ]; then echo "DATABASE_URL is not set" >&2; exit 1; fi
if [ -z "$SECRET_KEY" ]; then echo "SECRET_KEY is not set" >&2; exit 1; fi

echo "Waiting for PostgreSQL..."
for i in $(seq 1 60); do
    psql "$DATABASE_URL" -qtAc 'SELECT 1' >/dev/null 2>&1 && break
    [ "$i" = 60 ] && { echo "PostgreSQL did not answer" >&2; exit 1; }
    sleep 2
done

if [ "$(psql "$DATABASE_URL" -qtAc "SELECT to_regclass('events.events') IS NOT NULL")" = "t" ]; then
    echo "Database found: applying migrations (indico db upgrade)..."
    indico db upgrade
else
    echo "Empty database: creating Indico's schema (indico db prepare)..."
    psql "$DATABASE_URL" -qc 'CREATE EXTENSION IF NOT EXISTS unaccent; CREATE EXTENSION IF NOT EXISTS pg_trgm;'
    indico db prepare
fi
indico db --all-plugins upgrade

echo "Starting Indico on port ${PORT}..."
exec uwsgi --ini /opt/indico/etc/uwsgi.ini
