#!/bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}Fehler!${NC}"
    echo "Verwendung: ./deploy.sh <version> <name>"
    echo ""
    echo "Beispiele:"
    echo "  ./deploy.sh 1.2 blue    -> Erstellt v1.2 und deployt als Blue"
    echo "  ./deploy.sh 1.3 green   -> Erstellt v1.3 und deployt als Green"
    echo "  ./deploy.sh 1.4 orange  -> Erstellt v1.4 und deployt als Orange"
    exit 1
fi

VERSION=$1
TARGET=$2
APP_DIR="$HOME/app"
TOMCAT_DIR="/var/lib/tomcat/webapps"
CONF="/etc/httpd/conf.d/app-proxy.conf"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Deploy - Version $VERSION als $TARGET${NC}"
echo -e "${BLUE}========================================${NC}"

# Schritt 1: Code bearbeiten
echo ""
echo -e "${GREEN}[1/5] Code bearbeiten${NC}"
echo "      Oeffne jetzt die index.jsp und fuege deinen Code ein."
echo "      Speichern mit Strg+O, Enter, Strg+X"
echo ""
read -p "      Enter druecken um den Editor zu oeffnen..."
echo "" > $APP_DIR/src/main/webapp/index.jsp
nano $APP_DIR/src/main/webapp/index.jsp

# Schritt 2: Version in pom.xml setzen
echo -e "${GREEN}[2/5] Version $VERSION in pom.xml setzen...${NC}"
sed -i "0,/<version>.*<\/version>/s|<version>.*</version>|<version>$VERSION</version>|" $APP_DIR/pom.xml
echo "      Fertig."

# Schritt 3: Bauen
echo -e "${GREEN}[3/5] Maven Build...${NC}"
cd $APP_DIR
mvn clean package -q
if [ $? -ne 0 ]; then
    echo -e "${RED}      BUILD FAILED!${NC}"
    exit 1
fi
cp $APP_DIR/target/app.war $APP_DIR/app-$VERSION.war
echo "      BUILD SUCCESS - app-$VERSION.war gesichert"

# Schritt 4: Deployen
echo -e "${GREEN}[4/5] Deployen als app-$TARGET...${NC}"
sudo cp $APP_DIR/target/app.war $TOMCAT_DIR/app-$TARGET.war
echo "$VERSION" | sudo tee $TOMCAT_DIR/app-$TARGET.version > /dev/null
echo "      In Tomcat deployt."

# Schritt 5: Proxy-Route pruefen und anlegen
echo -e "${GREEN}[5/5] Proxy-Route pruefen...${NC}"
if grep -q "ProxyPass /app-$TARGET " $CONF; then
    echo "      Route /app-$TARGET existiert bereits."
else
    echo "" | sudo tee -a $CONF > /dev/null
    echo "# $TARGET immer erreichbar" | sudo tee -a $CONF > /dev/null
    echo "ProxyPass /app-$TARGET http://127.0.0.1:8080/app-$TARGET/" | sudo tee -a $CONF > /dev/null
    echo "ProxyPassReverse /app-$TARGET http://127.0.0.1:8080/app-$TARGET/" | sudo tee -a $CONF > /dev/null
    echo "      Neue Route /app-$TARGET angelegt."
fi

sudo systemctl restart httpd

# Landingpage aktualisieren
sudo python3 /usr/local/bin/cert-info.py
echo "      Landingpage aktualisiert."

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}  Version $VERSION als $TARGET deployt!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "      Hinweis: Die Live-Version wurde NICHT geaendert."
echo "      Zum Live schalten: ./switch.sh $TARGET"
echo ""
echo "  /app-$TARGET -> Version $VERSION"
echo ""
echo "  Alle Apps:"
ls /var/lib/tomcat/webapps/app-*.war 2>/dev/null | sed 's|.*/app-||;s|\.war||' | while read name; do
    echo "  /app-$name"
done
