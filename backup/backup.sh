#!/bin/bash

set -e

source "$(dirname "$0")/backup.conf"

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
DEST="$BACKUP_DIR/$DATE"

echo "=== ServerOps Backup ==="
echo "Ziel: $DEST"
echo

mkdir -p "$DEST"

echo "[1/5] Apache-Konfiguration sichern"
sudo tar -czf "$DEST/apache-config.tar.gz" "$APACHE_DIR"

echo "[2/5] Tinyproxy-Konfiguration sichern"
sudo tar -czf "$DEST/tinyproxy-config.tar.gz" "$TINYPROXY_DIR"

echo "[3/5] App-Verzeichnis sichern"
tar -czf "$DEST/app.tar.gz" "$APP_DIR"

echo "[4/5] WordPress-Dateien sichern"
sudo tar -czf "$DEST/wordpress-files.tar.gz" "$WORDPRESS_DIR"

echo "[5/5] WordPress-Datenbank sichern"
sudo mariadb-dump "$DB_NAME" > "$DEST/wordpress.sql"

sudo chown -R mario:mario "$DEST"

echo
echo "Backup abgeschlossen."
echo "Gespeichert unter:"
echo "$DEST"
