#!/bin/bash
# Railway mounts volumes as root: give the data folder to the indico user, then drop privileges.
set -e
DATA=/opt/indico/data
mkdir -p "$DATA/archive" "$DATA/custom"
if [ "$(stat -c %U "$DATA")" != "indico" ] || [ "$(stat -c %U "$DATA/archive")" != "indico" ]; then
    chown -R indico:indico "$DATA"
fi
exec setpriv --reuid=indico --regid=indico --init-groups env HOME=/opt/indico /opt/indico/railway/start.sh "$@"
