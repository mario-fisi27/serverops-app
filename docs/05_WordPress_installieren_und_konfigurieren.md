Kapitel 5.1 – Wordpress-Datenbank anlegen
mysql -u root -p

Passwort eingeben, dann im MariaDB-Prompt:

CREATE DATABASE wordpress;

•	Erstellt eine neue leere Datenbank namens wordpress

CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'DEIN PASSWORT';

•	Erstellt einen Datenbank-Benutzer wpuser der sich nur lokal verbinden darf
•	IDENTIFIED BY 'passwort' = setzt das Passwort (nimm dein eigenes Passwort)

GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';

•	Gibt dem User wpuser alle Rechte auf die Datenbank wordpress
•	wordpress.* = alle Tabellen in dieser Datenbank

FLUSH PRIVILEGES;

•	Macht die Rechtänderungen sofort wirksam

Exit um wieder aus dem SQL bereich zu kommen.

Kapitel 5.2 – Wordpress herunterladen und entpacken
cd /var/www/html

cd = change directory — wechselt in den Ordner wo Apache seine Webseiten sucht

sudo wget https://wordpress.org/latest.tar.gz

 

sudo tar -xzf latest.tar.gz

tar = Archiv-Tool (wie WinRAR/7-Zip für Linux)


-x = extract (entpacken)
-z = durch gzip-Filter (weil die Datei .gz komprimiert ist)
-f = file (danach kommt der Dateiname)

sudo chown -R apache:apache wordpress

chown = change owner — ändert den Besitzer der Dateien
-R = rekursiv (alle Dateien und Unterordner)
apache:apache = Benutzer und Gruppe apache — damit der Webserver die Dateien lesen/schreiben darf

Kapitel 5.3 – Wordpress konfigurieren
cd wordpress

sudo cp wp-config-sample.php wp-config.php

•	Kopiert die Beispiel-Konfiguration als echte Konfigurationsdatei
Dann die Datenbankdaten eintragen:

sudo sed -i "s/database_name_here/wordpress/" wp-config.php
sudo sed -i "s/username_here/wpuser/" wp-config.php
sudo sed -i "s/password_here/HIER DEIN PASSWORT/" wp-config.php

•	sed = stream editor — sucht und ersetzt Text in Dateien
•	-i = direkt in der Datei ändern (nicht nur anzeigen)
•	s/alt/neu/ = ersetze alt durch neu

Falls du ein anderes DB-Passwort gesetzt hast, pass den letzten Befehl an!
Prüfen ob alles stimmt:

grep -E "DB_NAME|DB_USER|DB_PASSWORD" wp-config.php

 




Jetzt im Browser der erste Test:
http://192.168.56.101/wordpress eingeben
 

Ausfüllen mit:
Site Title: z. B. Azubi Webprojekt
Username: admin
Password: was du willst (merken!)
Email: z. B. admin@test.de

Dann Install WordPress klicken.



