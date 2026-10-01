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
echo "Gewähltes Backup:"
echo "$BACKUP_DIR"

echo
echo "Was möchtest du wiederherstellen?"
echo "1 = Apache"
echo "2 = Tinyproxy"
echo "3 = App"
echo "4 = WordPress-Dateien"
echo "5 = WordPress-Datenbank"
echo "6 = Alles"

echo
read -p "Auswahl: " CHOICE

confirm_restore() {

    COMPONENT="$1"

    echo
    echo "ACHTUNG!"
    echo "Folgender Bereich wird überschrieben:"
    echo "$COMPONENT"
    echo
    echo "Backup:"
    echo "$BACKUP_DIR"
    echo

    read -p "Zum Fortfahren JA eingeben: " CONFIRM

    if [ "$CONFIRM" != "JA" ]; then
        echo
        echo "Restore abgebrochen."
        exit 0
    fi
}

restore_apache() {

    if [ ! -f "$BACKUP_DIR/apache-config.tar.gz" ]; then
        echo "Fehler: apache-config.tar.gz fehlt."
        exit 1
    fi

    echo "Apache wird wiederhergestellt..."

    sudo tar -xzf "$BACKUP_DIR/apache-config.tar.gz" -C /

    sudo apachectl configtest

    sudo systemctl reload httpd

    echo "Apache Restore abgeschlossen."
}

restore_tinyproxy() {

    if [ ! -f "$BACKUP_DIR/tinyproxy-config.tar.gz" ]; then
        echo "Fehler: tinyproxy-config.tar.gz fehlt."
        exit 1
    fi

    echo "Tinyproxy wird wiederhergestellt..."

    sudo tar -xzf "$BACKUP_DIR/tinyproxy-config.tar.gz" -C /

    sudo systemctl restart tinyproxy

    echo "Tinyproxy Restore abgeschlossen."
}

restore_app() {

    if [ ! -f "$BACKUP_DIR/app.tar.gz" ]; then
        echo "Fehler: app.tar.gz fehlt."
        exit 1
    fi

    echo "App wird wiederhergestellt..."

    tar -xzf "$BACKUP_DIR/app.tar.gz" -C /

    echo "App Restore abgeschlossen."
}

restore_wordpress_files() {

    if [ ! -f "$BACKUP_DIR/wordpress-files.tar.gz" ]; then
        echo "Fehler: wordpress-files.tar.gz fehlt."
        exit 1
    fi

    echo "WordPress-Dateien werden wiederhergestellt..."

    sudo tar -xzf "$BACKUP_DIR/wordpress-files.tar.gz" -C /

    echo "WordPress-Dateien Restore abgeschlossen."
}

restore_wordpress_db() {

    if [ ! -f "$BACKUP_DIR/wordpress.sql" ]; then
        echo "Fehler: wordpress.sql fehlt."
        exit 1
    fi

    echo "WordPress-Datenbank wird wiederhergestellt..."

    sudo mariadb wordpress < "$BACKUP_DIR/wordpress.sql"

    echo "WordPress-Datenbank Restore abgeschlossen."
}

case "$CHOICE" in

    1)
        confirm_restore "Apache-Konfiguration"
        restore_apache
        ;;

    2)
        confirm_restore "Tinyproxy-Konfiguration"
        restore_tinyproxy
        ;;

    3)
        confirm_restore "ServerOps App"
        restore_app
        ;;

    4)
        confirm_restore "WordPress-Dateien"
        restore_wordpress_files
        ;;

    5)
        confirm_restore "WordPress-Datenbank"
        restore_wordpress_db
        ;;

    6)
        confirm_restore "KOMPLETTES SYSTEM-BACKUP: Apache, Tinyproxy, App, WordPress-Dateien und Datenbank"

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
echo "======================================"
echo "Restore erfolgreich abgeschlossen."
echo "======================================"
