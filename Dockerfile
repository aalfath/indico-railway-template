# Indico on Railway: the official getindico/indico image, pinned by version and digest,
# plus a small wrapper (config read from environment variables, one start script,
# Celery worker + beat attached to uWSGI so they share the file-storage volume).
FROM getindico/indico:3.3.14@sha256:df0bc650a64834b30572a151dfb30fa43efb622d021b4b2cccd3bc6969301278

USER root

ENV VIRTUAL_ENV=/opt/indico/.venv \
    PATH=/opt/indico/.venv/bin:$PATH \
    INDICO_CONFIG=/opt/indico/etc/indico.conf \
    XDG_CACHE_HOME=/opt/indico/cache \
    PORT=8000

COPY --chown=indico:indico rootfs/etc/ /opt/indico/etc/
COPY --chown=indico:indico rootfs/railway/ /opt/indico/railway/

RUN chmod 755 /opt/indico/railway/*.sh \
 && mkdir -p /opt/indico/data \
 && chown indico:indico /opt/indico/data

WORKDIR /opt/indico
EXPOSE 8000

# Runs as root only long enough to fix the volume's ownership, then drops to the indico user.
ENTRYPOINT ["/opt/indico/railway/entrypoint.sh"]
