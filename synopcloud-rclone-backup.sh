#!/bin/bash

function log() {
    echo "`date '+%Y/%m/%d %H:%M:%S'` INFO  : $*"
}

# Ensure VOLUMENAME is set
if [ -z "$VOLUMENAME" ]; then
    log "VOLUMENAME is not set. Exiting."
    exit 1
fi

# Remove osascript and replace with a simple log
log "Backup starting!"

# Ensure the script is run as root (Docker runs as root by default)
if [ "$EUID" -ne 0 ]; then
  log "Please run as root"
  exit 0
fi

# Perform the rclone sync operations
log "rclone is syncing - the crypted data"
rclone sync --delete-excluded \
    --config /root/.config/rclone/rclone.conf \
    --exclude '.DS_Store' \
    --exclude "@eaDir/**" \
    --exclude 'MUSIC/' \
    --exclude 'book/' \
    --exclude 'emulator/' \
    $VOLUMENAME secret: --drive-chunk-size 128M --transfers 8

log "rclone is syncing music - no crypted data"
rclone sync --delete-excluded \
    --config /root/.config/rclone/rclone.conf \
    --exclude '.DS_Store' \
    --exclude "@eaDir/**" \
    $VOLUMENAME/MUSIC pcloud:musique --transfers 8

log "Backup clone completed!"
