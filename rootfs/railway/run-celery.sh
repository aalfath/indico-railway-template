#!/bin/bash
# Celery worker with the beat scheduler embedded (-B), started by uWSGI.
exec indico celery worker -B --concurrency="${CELERY_CONCURRENCY:-2}" \
    --schedule=/opt/indico/tmp/celerybeat-schedule --loglevel=INFO
