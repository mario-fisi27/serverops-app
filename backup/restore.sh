#!/bin/bash

set -e

BACKUP_BASE="/home/mario/backups"

echo "=== ServerOps Restore ==="
echo

echo "Verfügbare Backups:"
ls -1 "$BACKUP_BASE"

echo
read -p "Welches Backup soll verwendet werden? " BACKUP_NAME

BACKUP_DIR="$BACKUP_BASE/$BACKUP_NAME"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Fehler: Backup-Ordner nicht gefunden."
    exit 1
fi

echo
echo "Backup gewählt:"
echo "$BACKUP_DIR"

echo
echo "Was möchtest du wiederherstellen?"
echo "1 = Apache"
echo "2 = Tinyproxy"
echo "3 = App"
echo "4 = WordPress-Dateien"
echo "5 = WordPress-Datenbank"
echo "6 = Alles"

read -p "Auswahl: " CHOICE

restore_apache() {
    echo "Apache wird wiederhergestellt..."
    sudo tar -xzf "$BACKUP_DIR/apache-config.tar.gz" -C /
    sudo apachectl configtest
    sudo systemctl reload httpd
    echo "Apache Restore abgeschlossen."
}

restore_tinyproxy() {
    echo "Tinyproxy wird wiederhergestellt..."
    sudo tar -xzf "$BACKUP_DIR/tinyproxy-config.tar.gz" -C /
    sudo systemctl restart tinyproxy
    echo "Tinyproxy Restore abgeschlossen."
}

restore_app() {
    echo "App wird wiederhergestellt..."
    tar -xzf "$BACKUP_DIR/app.tar.gz" -C /
    echo "App Restore abgeschlossen."
}

restore_wordpress_files() {
    echo "WordPress-Dateien werden wiederhergestellt..."
    sudo tar -xzf "$BACKUP_DIR/wordpress-files.tar.gz" -C /
    echo "WordPress-Dateien Restore abgeschlossen."
}

restore_wordpress_db() {
    echo "WordPress-Datenbank wird wiederhergestellt..."
    sudo mariadb wordpress < "$BACKUP_DIR/wordpress.sql"
    echo "WordPress-Datenbank Restore abgeschlossen."
}

case "$CHOICE" in

    1)
        restore_apache
        ;;

    2)
        restore_tinyproxy
        ;;

    3)
        restore_app
        ;;

    4)
        restore_wordpress_files
        ;;

    5)
        restore_wordpress_db
        ;;

    6)
        restore_apache
        restore_tinyproxy
        restore_app
        restore_wordpress_files
        restore_wordpress_db
        ;;

    *)
        echo "Ungültige Auswahl."
        exit 1
        ;;

esac

echo
echo "Restore abgeschlossen."
