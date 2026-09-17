Kapitel 13.1 – Deploy-Skript erstellen
Das Deploy-Skript automatisiert den kompletten Deployment-Prozess: Code bearbeiten, Version setzen, bauen, deployen, Proxy-Route anlegen und Landingpage aktualisieren — alles mit einem einzigen Befehl. Die Live-Version wird dabei bewusst NICHT umgeschaltet, damit man die neue Version erst testen kann bevor sie live geht.
nano ~/app/deploy.sh
Inhalt:
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
Ausführbar machen:
chmod +x ~/app/deploy.sh
Was das Skript automatisch macht:
1.	Leert die index.jsp und öffnet nano zum Code einfügen
2.	Setzt die Versionsnummer in pom.xml
3.	Baut das Projekt mit Maven
4.	Deployt das .war-Artefakt in Tomcat
5.	Legt eine neue Proxy-Route an falls nötig
6.	Aktualisiert die Landingpage mit dem neuen Button
Was das Skript bewusst NICHT macht: Die Live-Version (/app) umschalten. So kann die neue Version erst unter /app-name getestet werden bevor sie live geht.
Verwendung:
cd ~/app
./deploy.sh 1.2 orange

 
Kapitel 13.2 – Switch-Skript erstellen
Das Switch-Skript wechselt die Live-Version (/app) auf eine beliebige deployte App. Alle anderen App-Versionen bleiben unter ihrem eigenen Pfad erreichbar.
nano ~/app/switch.sh
Inhalt:
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
Ausführbar machen:
chmod +x ~/app/switch.sh
Verwendung:
•	./switch.sh blue → Live zeigt auf Blue
•	./switch.sh green → Live zeigt auf Green
•	./switch.sh orange → Live zeigt auf Orange
•	./switch.sh → Zeigt alle verfügbaren Apps
 
Kapitel 13.3 – Automatische Landingpage
Das Python-Skript für die Landingpage wurde erweitert: Es erkennt automatisch alle deployte Apps aus dem Tomcat webapps-Ordner und erstellt für jede einen Button mit der richtigen Farbe und Versionsnummer. Die Buttons werden nach Versionsnummer sortiert angezeigt.
Funktionen:
•	Erkennt automatisch alle .war-Dateien in /var/lib/tomcat/webapps/
•	Liest die Versionsnummer aus .version-Dateien
•	Sortiert Buttons nach Versionsnummer (1.0, 1.1, 1.2, ...)
•	Farbcodierung: Blue (blau), Green (grün), Orange (orange), Red (rot), Purple (lila)
•	Wird bei jedem Deploy automatisch aufgerufen
•	Zusätzlich alle 6 Stunden über den Cronjob

echo "1.0" | sudo tee /var/lib/tomcat/webapps/app-blue.version
echo "1.1" | sudo tee /var/lib/tomcat/webapps/app-green.version
Dann die Webseite neu laden damit des auf der Landingpage richtig angezeigt wird.
sudo python3 /usr/local/bin/cert-info.py
Das noch ausführen damit auf der Landingpage die Versionen 1.0 und 1.1 auch richtig erkannt werden.
 
Kapitel 13.4 – Typischer Workflow
Neue Version erstellen und deployen:
cd ~/app
./deploy.sh 1.2 purple
Das Skript öffnet nano mit leerer Datei, Code einfügen, speichern. Die App wird gebaut, deployt und erscheint als Button auf der Landingpage. Die Live-Version bleibt unverändert.
Neue Version im Browser testen:
https://192.168.56.101/app-purple
Wenn alles passt, live schalten:
./switch.sh purple
Jetzt zeigt /app auf Purple. Falls Probleme auftreten, sofort zurück:
./switch.sh green
Das ist Blue/Green-Deployment in der Praxis: Deployen → Testen → Live schalten → bei Problemen sofort zurückrollen.
Kapitel 13.5 – Löschungs Skript

nano ~/app/delete.sh

Inhalt:
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


Ausführbar machen:
chmod +x ~/app/delete.sh

./delete.sh orange → löscht App Orange komplett
./delete.sh → zeigt alle Apps

 


