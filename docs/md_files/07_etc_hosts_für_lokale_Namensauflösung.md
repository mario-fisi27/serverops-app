Was ist die hosts-Datei?

Normalerweise fragt dein PC einen DNS-Server „Welche IP hat azubi-vm-wordpress.de?". Die hosts-Datei ist wie ein lokales Telefonbuch — dein PC schaut dort zuerst nach, bevor er einen DNS-Server fragt. So können wir erfundene Domainnamen auf unsere VM zeigen lassen.
Kapitel 7 – /etc/hosts für lokale Namensauflösung

sudo nano /etc/hosts   

darin noch folgende Zeile einfügen: 

127.0.0.1  azubi-vm-serverops.de azubi-vm-wordpress.de azubi-vm-phpmyadmin.de

Dann strg + o, dann enter und dann strg + x

127.0.0.1 ist der localhost also die VM selbst da die Domains auf der VM laufen.


curl -s http://azubi-vm-wordpress.de | head -5
curl -s http://azubi-vm-serverops.de | head -5

die beiden Befehle eingeben und dann sollte html code kommen.
 

Wenn du keinen zugriff auf die phpMyAdmin Seite hast dann einfach Befehel:

sudo nano /etc/httpd/conf.d/phpMyAdmin.conf

Dann dort mit strg + w nach Require local suchen und da wo des steht ersetzten durch Require all granted (gibt es 2 mal in der Datei)

Speichern (Strg+O → Enter → Strg+X)



Apache neustarten:

sudo apachectl configtest                      -> dabei sollte Syntax OK rauskommen
sudo systemctl restart httpd

Dann kann man die phpMyAdmin Seite aufrufen und mit root und dem passwort des festgelegt wurde bei mysql anmelden.	
