#!/bin/bash

# strict mode
set -euo pipefail

LOCAL_BACKUP_DIR="/config/data/backup/autobackup"
REMOTE_BACKUP_DIR="gcs:$GOOGLE_CLOUD_STORAGE_BUCKET/$SITE_NAME"

REMOTE_BACKUP_DIR_DEVICE="$REMOTE_BACKUP_DIR/$RESIN_DEVICE_NAME_AT_INIT"
REMOTE_BACKUP_DIR_DEFAULT="$REMOTE_BACKUP_DIR/default"

rclone_sync () {
  echo "Syncing $1 to $2..."
  rclone --config /var/rclone/rclone.conf sync $1 $2
  echo "Done"
}

# Create the local backup directory, if it doesn't exist yet
mkdir -p $LOCAL_BACKUP_DIR

while true
do
  if [[ "$(ls -A $LOCAL_BACKUP_DIR)" ]]; then
    # Skip backup if files have not changed
    if [[ ${BACKUP_HASH:-} == "$(ls -A $LOCAL_BACKUP_DIR | shasum)" ]]; then
      continue
    fi

    # Sync autobackup with the device specific cloud backup (this ensures that
    # every device has its last state available for inspection)
    rclone_sync $LOCAL_BACKUP_DIR $REMOTE_BACKUP_DIR_DEVICE

    # Sync the default cloud backup as well (this is used for auto restores)
    rclone_sync $REMOTE_BACKUP_DIR_DEVICE $REMOTE_BACKUP_DIR_DEFAULT

    # Save the state
    BACKUP_HASH=$(ls -A $LOCAL_BACKUP_DIR | shasum)
  else
    # Restore from default backup
    rclone_sync $REMOTE_BACKUP_DIR_DEFAULT $LOCAL_BACKUP_DIR
  fi

  sleep 300
done
