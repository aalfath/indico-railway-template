# Indico on Railway

A Railway template for [Indico](https://getindico.io), CERN's open-source event management system for conferences, meetings and lectures (agendas, registration, abstracts, timetables, room booking).

**Version:** Indico 3.3.14, from the official image `getindico/indico:3.3.14@sha256:df0bc650a64834b30572a151dfb30fa43efb622d021b4b2cccd3bc6969301278`, pinned by version and digest in the [`Dockerfile`](Dockerfile).

## What it deploys

| Service | Source | Notes |
|---|---|---|
| **Indico** | this repo (`Dockerfile`) | uWSGI web server on `PORT` 8000, plus the Celery worker and beat scheduler attached to it, so both share the file-storage volume at `/opt/indico/data` (attachments in `archive/`, customisations in `custom/`). Health check: `/healthz` |
| **Postgres** | Railway PostgreSQL | Indico's database. The `unaccent` and `pg_trgm` extensions are created on first start |
| **Redis** | Railway Redis | Cache (db 0) and Celery broker (db 1) |

On the first start the container creates Indico's schema (`indico db prepare`). On every later start it applies migrations (`indico db upgrade` and the plugins' upgrades), so version updates need no manual step.

## First login

Open the service's public URL right after the deploy. Indico shows a one-time **bootstrap** page that creates the first administrator account. Whoever completes it becomes admin, so do it straight away.

New sign-ups need an admin's approval by default (`LOCAL_MODERATION=true`).

## Variables

Set by the template, no prompts:

| Variable | Value | Purpose |
|---|---|---|
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | PostgreSQL connection |
| `REDIS_URL` | `${{Redis.REDIS_URL}}` | Redis connection (cache and Celery) |
| `SECRET_KEY` | generated | Signs sessions and tokens. Don't change it after the first start |
| `BASE_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Indico's public URL. Indico answers 404 to any other host, so change this when you add a custom domain |
| `PORT` | `8000` | Port uWSGI listens on |

Optional, add them to the Indico service when you need them:

| Variable | Default | Purpose |
|---|---|---|
| `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_USE_TLS` / `SMTP_USE_SSL` | none (`localhost:25`) | Outgoing mail. Without SMTP Indico can't send registration, password-reset or notification emails |
| `NO_REPLY_EMAIL` | `noreply@` + your domain | Sender address |
| `SUPPORT_EMAIL` | same as `NO_REPLY_EMAIL` | Receives Indico's error reports; set a real inbox |
| `PUBLIC_SUPPORT_EMAIL` | none | Support address shown to users |
| `DEFAULT_TIMEZONE` / `DEFAULT_LOCALE` | `UTC` / `en_GB` | Instance defaults |
| `LOCAL_REGISTRATION` / `LOCAL_MODERATION` | `true` / `true` | Allow sign-ups / require admin approval for them |
| `INDICO_PLUGINS` | `previewer_code,payment_manual` | Comma-separated plugins from `indico-plugins` (installed in the image) |
| `ENABLE_ROOMBOOKING` | `true` | Room booking module |
| `UWSGI_PROCESSES` / `CELERY_CONCURRENCY` | `2` / `2` | Web and worker processes |

Not included: LaTeX-based PDF generation (for example the book of abstracts). Indico runs LaTeX in a Podman container, which needs privileged mode that Railway doesn't offer, so those PDF options are unavailable.

## Updates

Railway notifies everyone who deployed this template when a change is merged to `main` here. Each version bump is listed in [`CHANGELOG.md`](CHANGELOG.md), breaking changes first. Read it, back up the Postgres database and the volume, then apply the update from your Railway dashboard. Migrations run automatically on the next start.

## Files

- `Dockerfile`: the pinned upstream image plus the wrapper below.
- `rootfs/etc/indico.conf`: Indico's config, read from environment variables.
- `rootfs/etc/uwsgi.ini`, `rootfs/etc/logging.yaml`: web server and logging (to Railway's logs).
- `rootfs/railway/`: `entrypoint.sh` (volume ownership, drop to the `indico` user), `start.sh` (wait for Postgres, prepare or migrate, start uWSGI), `run-celery.sh`, `wsgi.py` (adds `/healthz`).

Indico is MIT-licensed, © CERN. This wrapper isn't affiliated with the Indico project.
