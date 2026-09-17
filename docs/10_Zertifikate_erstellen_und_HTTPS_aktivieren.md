Was passiert hier?

Bisher läuft alles über HTTP (unverschlüsselt). Jetzt erstellen wir eine eigene Certificate Authority (CA) — quasi unsere eigene kleine Zertifizierungsstelle — und damit Zertifikate für unsere Domains. Danach läuft alles über HTTPS (verschlüsselt).

Kapitel 10.1 – Ordnerstruktur anlegen
sudo mkdir -p /etc/httpd/ssl

cd /etc/httpd/ssl

mkdir -p = Ordner erstellen (-p = auch übergeordnete Ordner falls nötig)
Hier speichern wir alle Zertifikate und Schlüssel

Kapitel 10.2 – CA erstellen (unsere eigene Zertifiezierungsstelle)

sudo openssl genrsa -out ca.key 4096

•	openssl = das Tool für Kryptografie und Zertifikate
•	genrsa = einen RSA-Schlüssel generieren
•	-out ca.key = Schlüssel in diese Datei speichern
•	4096 = Schlüssellänge in Bit (sehr sicher)
---------------------------------------------------------------------------------------------------------------------------
sudo openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=Azubi CA/O=VW Group Services/C=DE"

•	req -x509 = ein selbst-signiertes Zertifikat erstellen
•	-new -nodes = neues Zertifikat, Schlüssel nicht extra verschlüsseln
•	-key ca.key = den eben erstellten Schlüssel verwenden
•	-sha256 = SHA-256 als Hash-Algorithmus
•	-days 3650 = gültig für 10 Jahre
•	-out ca.crt = Zertifikat in diese Datei speichern
•	-subj "..." = Informationen über die CA (Name, Organisation, Land)

Kapitel 10.3 – Server-Zertifikat für die Domains erstellen

Jetzt erstellen wir ein Zertifikat das für alle drei Domains gilt.

Schritt 1 — Privaten Schlüssel für den Server generieren:

sudo openssl genrsa -out server.key 4096

•	Gleich wie beim CA-Schlüssel, aber diesmal für den Webserver



Schritt 2 — Certificate Signing Request (CSR) erstellen:

sudo openssl req -new -key server.key -out server.csr -subj "/CN=azubi-vm-serverops.de/O=VW Group Services/C=DE" -addext "subjectAltName=DNS:azubi-vm-serverops.de,DNS:azubi-vm-wordpress.de,DNS:azubi-vm-phpmyadmin.de,IP:192.168.56.101"

•	req -new = eine Zertifikats-Anfrage erstellen
•	CSR = „Bitte liebe CA, unterschreib mir dieses Zertifikat"
•	-subj = für welche Domain das Zertifikat gilt

Schritt 3 — CSR mit unserer CA signieren (Zertifikat ausstellen):

sudo openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256 -copy_extensions copyall

•	x509 -req = eine CSR-Anfrage bearbeiten und ein Zertifikat ausstellen
•	-in server.csr = die Anfrage die wir gerade erstellt haben
•	-CA ca.crt -CAkey ca.key = mit unserer CA unterschreiben
•	-CAcreateserial = Seriennummer automatisch erzeugen
•	-out server.crt = fertiges Zertifikat speichern
•	-days 365 = gültig für 1 Jahr

Schritt 4 — Prüfen ob alles da ist:

ls -la /etc/httpd/ssl/
Da sollten diese Dateien stehen: ca.key, ca.crt, server.key, server.csr, server.crt


 
Kapitel 10.4 – Apache für HTTPS konfigurieren

SSL-Modul installieren:

sudo dnf -y install mod_ssl

Default-SSL-Config umbenennen (verhindert Konflikt):
sudo mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak

Damit alle HTTP-Aufrufe automatisch auf HTTPS umgeleitet werden, wird die vhosts.conf angepasst.

Die komplette vhosts.conf sieht dann so aus:

sudo nano /etc/httpd/conf.d/vhosts.conf

Inhalt:
Listen 443 https

<VirtualHost *:80>
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
</VirtualHost>

<VirtualHost *:443>
    ServerName 192.168.56.101
    DocumentRoot /var/www/html
    SSLEngine on
    SSLCertificateFile /etc/httpd/ssl/server.crt
    SSLCertificateKeyFile /etc/httpd/ssl/server.key
    SSLCACertificateFile /etc/httpd/ssl/ca.crt
</VirtualHost>

<VirtualHost *:443>
    ServerName azubi-vm-serverops.de
    DocumentRoot /var/www/html
    SSLEngine on
    SSLCertificateFile /etc/httpd/ssl/server.crt
    SSLCertificateKeyFile /etc/httpd/ssl/server.key
    SSLCACertificateFile /etc/httpd/ssl/ca.crt
</VirtualHost>

<VirtualHost *:443>
    ServerName azubi-vm-wordpress.de
    DocumentRoot /var/www/html/wordpress
    SSLEngine on
    SSLCertificateFile /etc/httpd/ssl/server.crt
    SSLCertificateKeyFile /etc/httpd/ssl/server.key
    SSLCACertificateFile /etc/httpd/ssl/ca.crt
</VirtualHost>

<VirtualHost *:443>
    ServerName azubi-vm-phpmyadmin.de
    DocumentRoot /usr/share/phpMyAdmin
    SSLEngine on
    SSLCertificateFile /etc/httpd/ssl/server.crt
    SSLCertificateKeyFile /etc/httpd/ssl/server.key
    SSLCACertificateFile /etc/httpd/ssl/ca.crt
</VirtualHost>

Der eine <VirtualHost *:80> Block leitet alle HTTP-Anfragen auf HTTPS um, egal ob über IP oder Domainname
%{HTTP_HOST} behält den originalen Hostnamen/IP bei
RewriteRule ^(.*)$ https://azubi-vm-serverops.de$1 fängt jede Anfrage an die IP ab und leitet sie auf die Domain um, inklusive dem ursprünglich aufgerufenen Pfad ($1). [R=301,L] sorgt für eine dauerhafte Weiterleitung (301) und beendet danach die weitere Regelprüfung (L = last).
Config prüfen und neustarten:

sudo apachectl configtest
sudo systemctl restart httpd

Testen: http://192.168.56.101 leitet automatisch auf https://192.168.56.101 um.

 
Dort sollte noch folgender Fehler kommen welcher gleich noch behoben wird.

Kapitel 10.5 – CA-Zertifikat im Browser importieren
CA-Zertifikat von der VM auf Windows kopieren (Wichtig neue Powershell öffnen mit der man nicht mit der VM verbunden ist sonst geht’s nicht! Kann danach wieder geschlossen werden!):

scp mario@192.168.56.101:/etc/httpd/ssl/ca.crt $HOME\Desktop\ca.crt
 
Das sollte dann auf dem Desktop erscheinen.

Dann in Windows:
1.	Doppelklick auf ca.crt
2.	Zertifikat installieren → Aktueller Benutzer
3.	Alle Zertifikate in folgendem Speicher speichern → Durchsuchen → Vertrauenswürdige Stammzertifizierungsstellen
4.	Fertigstellen
5.	Sicherheitswarnung: Möchten Sie dieses Zertifikat installieren? Ja
6.	Fertig
Danach Browser neu starten — HTTPS funktioniert ohne Warnung.

Kapitel 10.6 – HTTPS testen und verifizieren
Im Browser:
•	https://192.168.56.101 → Landingpage über HTTPS
•	https://192.168.56.101/wordpress → WordPress über HTTPS
•	https://192.168.56.101/phpmyadmin → phpMyAdmin über HTTPS

Sollte alle Seiten mit HTTPS laden.

Per Kommandozeile:
curl -k https://localhost | head -5
echo | openssl s_client -connect localhost:443 2>/dev/null | openssl x509 -noout -subject -dates 

Die Daten können natürlich etwas varieren.






























Falls der Fehler immer noch da ist dann könnte es daran liegen das die IP in den Commands davor falsch eingegeben wurden.

Dann mit folgendem Befehl die ip noch mal überprüfen:
ip a show enp0s8

Dann IP merken. Danach Windows Taste drücken und certmgr.msc eingeben. Vertrauenswürdige Stammzertifizierungsstellen → Zertifikate. Dann rechts suchen nach Azubi CA und dann mit Rechtsklick drauf drücken und löschen.

Folgende Befehle nochmal eingeben:

cd /etc/httpd/ssl
sudo openssl genrsa -out server.key 4096 2>/dev/null
sudo openssl req -new -key server.key -out server.csr -subj "/CN=azubi-vm-serverops.de/O=VW Group Services/C=DE" -addext "subjectAltName=DNS:azubi-vm-serverops.de,DNS:azubi-vm-wordpress.de,DNS:azubi-vm-phpmyadmin.de,IP:192.168.56.101"
sudo openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256 -copy_extensions copyall 2>/dev/null
sudo systemctl restart httpd

Diesmal wichtig mit der Richtigen IP! Und danach nochmal neue Powershell auf machen und ca.crt neu installieren. Und dann sollte es ohne Probleme funktionieren.

