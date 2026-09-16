#!/bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

CONF="/etc/httpd/conf.d/app-proxy.conf"

if [ -z "$1" ]; then
    echo -e "${RED}Fehler!${NC}"
    echo "Verwendung: ./switch.sh <name>"
    echo ""
    echo "Beispiele:"
    echo "  ./switch.sh blue"
    echo "  ./switch.sh green"
    echo "  ./switch.sh orange"
    echo ""
    echo "Verfuegbare Apps:"
    ls /var/lib/tomcat/webapps/app-*.war 2>/dev/null | sed 's|.*/app-||;s|\.war||' | while read name; do
        echo "  - $name"
    done
    exit 1
fi

TARGET=$1

# Pruefen ob die App existiert
if [ ! -f "/var/lib/tomcat/webapps/app-$TARGET.war" ]; then
    echo -e "${RED}Fehler: app-$TARGET existiert nicht!${NC}"
    echo ""
    echo "Verfuegbare Apps:"
    ls /var/lib/tomcat/webapps/app-*.war 2>/dev/null | sed 's|.*/app-||;s|\.war||' | while read name; do
        echo "  - $name"
    done
    exit 1
fi

# Live-Route aendern
sudo sed -i "0,/ProxyPass \/app /s|ProxyPass /app http://127.0.0.1:8080/app-[a-zA-Z]*/|ProxyPass /app http://127.0.0.1:8080/app-$TARGET/|" $CONF
sudo sed -i "0,/ProxyPassReverse \/app /s|ProxyPassReverse /app http://127.0.0.1:8080/app-[a-zA-Z]*/|ProxyPassReverse /app http://127.0.0.1:8080/app-$TARGET/|" $CONF

sudo systemctl restart httpd

echo -e "${BLUE}========================================${NC}"
echo -e "  ${GREEN}Live ist jetzt: $TARGET${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "  /app -> $TARGET (Live)"
echo ""
echo "  Alle Apps:"
ls /var/lib/tomcat/webapps/app-*.war 2>/dev/null | sed 's|.*/app-||;s|\.war||' | while read name; do
    echo "  /app-$name"
done
