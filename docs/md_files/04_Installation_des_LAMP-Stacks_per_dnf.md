Kapitel 4 – SSH Verbindung von Windows
Als erstes Powershell öffnen. Dort folgenden Befehl eingeben: 
ssh mario@192.168.56.101
bzw ssh benutzername@eigene IP(bei ip a zu sehen)

Warum? In Powershell kann man die Befehle einfach einfügen und dadurch ist man schneller als jeden Befehel einzeln abzutippen.
Es wird gefragt: Are you sure you want to continue connecting: mit “yes” antworten.
Danach muss noch das Passwort zur bestätigung eingegeben werden.

Kapitel 4.0 – System aktualisieren (nicht nötig kann aber gemacht werden aber hat keine Nachteile nur für die Sicherheit)
Wird nur auf Grund der SSL-Inspektion vom Zscaler gemacht sonst funktionieren die dnf -y install befehle nicht und kann nicht installiert werden.
Tastenkombination außerhalb der VM in Windows: Win + R
Dort dann: certmgr.msc    eingeben und enter

1.	Vertrauenswürdige Stammzertifizierungsstellen → Zertifikate
2.	Suche nach einem Eintrag mit „Zscaler" im Namen (z. B. "Zscaler Root CA")
3.	Rechtsklick → Alle Aufgaben → Exportieren
4.	Base-64-codiert X.509 (.CER) wählen
5.	Speichern als zscaler-root-ca.crt
6.	Solange man keinen anderen Ordner ausgewählt hat unter dem Benutzer gespeichert
 
Wichtig! Folgenden Befehl in einem neuen CMD Fenster eingeben nicht auf der VM:
scp zscaler-root-ca.crt.cer mario@IP DER VM:~/

Dadurch wird das Zscaler-Zertifikat von Windows auf die VM übertragen.
Dann in der VM eingeben:
sudo cp ~/zscaler-root-ca.crt.cer /etc/pki/ca-trust/source/anchors/zscaler-root-ca.crt 

sudo update-ca-trust extract

Bindet das Zertifikat in den systemweiten Vertrauensspeicher ein — dadurch vertrauen alle Programme (dnf, curl, Ansible) automatisch der SSL-Inspektion des Firmen-Proxys, ohne die Prüfung selbst abzuschalten.

Kapitel 4.1 – System aktualisieren (nicht nötig kann aber gemacht werden aber hat keine Nachteile nur für die Sicherheit)
sudo dnf -y upgrade

dnf ist der Packetmanager von Rocky Linux
-y bedeutet alle Rückfragen werden mit „Ja“ beantwortet, sont müsste man jedes Mal manuell j eintippen und Enter drücken. Was natürlich bei so vielen Pakten nervig wäre.
Upgrade bedeutet alle installierten Pakete auf den neuesten Stand bringen.

Einfachste Lösung: sudo nano /etc/dnf/dnf.conf

Dann strg + o -> enter -> strg + x

Dann nochmal sudo dnf -y upgrade und dann sollte es klappen.

 

Nach dem Update dann falls die Auswahl kommt des 9.4 nehmen. Also des 2 in der Reihe.

Kapitel 4.2 – LAMP-Stack installieren

sudo dnf -y install mariadb-server httpd php php-mysqlnd php-zip php-bcmath php-process

Damit installiert man den kompletten LAMP-Stack.

mariadb-server = Datenbank-Server (speichert die Daten für WordPress)
httpd = Apache Webserver (liefert Webseiten aus)
php = Programmiersprache (WordPress ist in PHP geschrieben)
php-mysqlnd = PHP-Modul damit PHP mit der Datenbank reden kann
php-zip = PHP-Modul für ZIP-Dateien (braucht WordPress für Plugins/Themes)
php-bcmath = PHP-Modul für Berechnungen
php-process = PHP-Modul für Prozesssteuerung

Kapitel 4.3 – LAMP-Stack erweitern
sudo dnf -y install epel-release

aktiviert das Extra Packages for Enterprise Linux Repository – eine riesige Paketsammlung die im Standard-Rocky nicht dabei ist (von Fedora). Damit phpmyadmin gleich ohne Probleme installiert werden kann.

Mit dem Befehl: sudo dnf -y install phpmyadmin       wird phpmyadmin installiert.
phpmyadmin = Web-Oberfläche für die MariaDB-Datenbank (statt SQL-Befehle tippen kannst du die DB im Browser verwalten)




sudo dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm

sudo dnf -y install php-tidy


remi-release-9.rpm = aktiviert das Remi-Repository (hat aktuelle PHP-Module die sonst fehlen)  Rocky Linux liefert PHP mit, aber nicht alle PHP-Module. Manche Module wie php-tidy sind weder im Standard-Repo noch in EPEL verfügbar. Remi ist das bekannteste und vertrauenswürdigste PHP-Repository für die RHEL/Rocky-Welt — es wird von einem einzelnen Fedora-Entwickler (Remi Collet) gepflegt und von der PHP-Community breit eingesetzt.

php-tidy = PHP-Modul zum Aufräumen/Validieren von HTML-Code
Es räumt HTML-Code auf — korrigiert fehlerhafte Tags, formatiert HTML sauber und kann HTML validieren. phpMyAdmin nutzt es um die Ausgabe sauber darzustellen.
Warum das relevant ist: Im Original-Projekt musste php-tidy aus dem kompletten PHP-Quellcode gebaut werden (rpmbuild, SPEC-Dateien, stundenlange Arbeit) — weil die VM kein Internet hatte und das Paket nicht als fertige RPM vorlag. Mit Remi-Repo ist es ein einziger Befehl. Das ist einer der größten Zeitgewinne der Modernisierung.


Kapitel 4.4 – Dienste starten und aktivieren
sudo systemctl enable --now mariadb httpd

systemctl = das Tool um Dienste (Services) zu verwalten
enable = Dienst soll bei jedem Systemstart automatisch mitlaufen
--now = und zusätzlich jetzt sofort starten (spart einen zweiten Befehl)
mariadb httpd = beide Dienste gleichzeitig

 

Nun wird geprüft ob sie laufen:
sudo systemctl status mariadb          sollte in grün active stehen.
 


sudo systemctl status httpd            sollte ebenfalls in grün active stehen.
 

Kapitel 4.5 – MariaDB absichern
sudo mysql_secure_installation

Dieses Skript härtet die Datenbank ab (Standard-Passwörter weg, Testdaten weg, Remote-Root-Zugang weg)

Bei den Fragen:
•	Enter current password for root: einfach Enter (ist noch leer)
•	Switch to unix_socket auth: n
•	Set root password: Y → dein DB-Passwort eingeben
•	Danach alles: Y, Y, Y, Y

Sollte dann wiefolgt aussehen:
 

Danach Login Testen: mysql -u root -p  

 

Mit exit einfach wieder schließen.
Kapitel 4.6 – Firewall richtig konfigurieren
Im Original: Firewall komplett ausgeschaltet. Bei uns: aktiv lassen und gezielt Ports öffnen.

Befehle:
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

firewall-cmd = Tool um die Firewall zu verwalten
--permanent = Regel bleibt auch nach Neustart bestehen
--add-service=http = Port 80 (Webseiten) freigeben
--add-service=https = Port 443 (verschlüsselte Webseiten) freigeben
Port 8080 machen wir diesmal gleich mit — den brauchen wir später für Tomcat.
--reload = neue Regeln aktivieren

Danach prüfen:
sudo firewall-cmd --list-all        so sollte es jetzt aussehen.

 


SELinux-Boolean setzen:
sudo setsebool -P httpd_can_network_connect 1

Wird später noch benötigt für den Reverse Proxy.
Das ist SELinux — es blockiert Apache daran, sich mit Tomcat zu verbinden.
httpd_can_network_connect 1 = Apache darf Netzwerkverbindungen nach außen aufbauen (z.B. zu Tomcat auf Port 8080)
-P steht für Permanent




Nun sollte man mit: http://192.168.56.101    bzw der eigenen IP-Adresse folgende Seite im Browser öffnen können.

 
