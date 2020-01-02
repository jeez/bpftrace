#!/system/bin/env sh

SYSROOT=$(realpath $(dirname $_))
source "${SYSROOT}/setup.sh" > /dev/null
exec "$@"
