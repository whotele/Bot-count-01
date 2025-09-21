#!/bin/bash

BACKUP_NAME="vps_backup.tar.gz"
BACKUP_URL="https://transfer.sh/vps_backup.tar.gz"

restore_backup() {
  echo "🔄 Restoring backup..."
  if curl -s --fail "$BACKUP_URL" -o "$BACKUP_NAME"; then
    if tar -xzf "$BACKUP_NAME"; then
      echo "Backup restored."
    else
      echo "Failed to extract backup."
      return 1
    fi
  else
    echo "No previous backup found, starting fresh."
    return 1
  fi
}

backup_and_upload() {
  echo "Creating backup and uploading..."
  tar czf "$BACKUP_NAME" ./data ./scripts ./configs 2>/dev/null || {
    echo "Nothing to backup or folders do not exist."
    return 1
  }
  UPLOAD_LINK=$(curl --upload-file "$BACKUP_NAME" "https://transfer.sh/$BACKUP_NAME")
  echo "Backup uploaded: $UPLOAD_LINK"
  echo "$UPLOAD_LINK" > last_backup_url.txt
}

case "$1" in
  restore_backup) restore_backup ;;
  backup_and_upload) backup_and_upload ;;
  *)
    echo "Usage: $0 [restore_backup|backup_and_upload]"
    exit 1
    ;;
esac
