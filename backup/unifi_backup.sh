#!/bin/bash

if [ "$(ls -A /config/data/backup/autobackup/)" ]; then
  # Sync autobackup with the device specific cloud backup (this ensures that
  # every device has it's last state available for inspection)
  rclone --config /var/rclone/rclone.conf sync \
    /config/data/backup/autobackup/ \
    gcs:unifi.komorowski.me/$SITE_NAME/$(hostname)

  # Sync the default cloud backup as well (this is used for auto restores)
  rclone --config /var/rclone/rclone.conf sync \
    gcs:unifi.komorowski.me/$SITE_NAME/$(hostname) \
    gcs:unifi.komorowski.me/$SITE_NAME/default
else
  # Restore from default backup
  rclone --config /var/rclone/rclone.conf sync \
    gcs:unifi.komorowski.me/$SITE_NAME/default \
    gcs:unifi.komorowski.me/$SITE_NAME/$(hostname)
fi
