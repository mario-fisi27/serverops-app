#!/bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

TOMCAT_DIR="/var/lib/tomcat/webapps"
CONF="/etc/httpd/conf.d/app-proxy.conf"

if [ -z "$1" ]; then
    echo -e "${RED}Fehler!${NC}"
    echo "Verwendung: ./delete.sh <name>"
    echo ""
    echo "Deployete Apps:"
    ls $TOMCAT_DIR/app-*.war 2>/dev/null | sed 's|.*/app-||;s|\.war||' | while read name; do
        echo "  - $name"
    done
    exit 1
fi

TARGET=$1

if [ ! -f "$TOMCAT_DIR/app-$TARGET.war" ]; then
    echo -e "${RED}Fehler: app-$TARGET existiert nicht!${NC}"
    exit 1
fi

echo -e "${RED}App '$TARGET' wird geloescht...${NC}"

# WAR, Ordner und Version loeschen
sudo rm -f $TOMCAT_DIR/app-$TARGET.war
sudo rm -f $TOMCAT_DIR/app-$TARGET.version
sudo rm -rf $TOMCAT_DIR/app-$TARGET

# Proxy-Route entfernen
sudo sed -i "/# $TARGET immer erreichbar/d" $CONF
sudo sed -i "/ProxyPass \/app-$TARGET /d" $CONF
sudo sed -i "/ProxyPassReverse \/app-$TARGET /d" $CONF

# Leere Zeilen aufraumen
sudo sed -i '/^$/N;/^\n$/d' $CONF

sudo systemctl restart httpd
sudo python3 /usr/local/bin/cert-info.py 2>/dev/null

echo -e "${GREEN}App '$TARGET' geloescht!${NC}"
echo ""
echo "Verbleibende Apps:"
ls $TOMCAT_DIR/app-*.war 2>/dev/null | sed 's|.*/app-||;s|\.war||' | while read name; do
    echo "  - $name"
done
