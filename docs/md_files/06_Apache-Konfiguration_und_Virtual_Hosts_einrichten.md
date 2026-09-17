Was sind Virtual Hosts?

Stell dir vor du hast einen Server, aber drei verschiedene Webseiten. Ohne Virtual Hosts wüsste Apache nicht welche Seite er zeigen soll. Mit Virtual Hosts sagst du: „Wenn jemand azubi-vm-wordpress.de aufruft, zeig den WordPress-Ordner. Wenn jemand azubi-vm-phpmyadmin.de aufruft, zeig phpMyAdmin."
Kapitel 6.1 – Apache Virtual Hosts konfigurieren

sudo nano /etc/httpd/conf.d/vhosts.conf

Folgendes eintragen:

<VirtualHost *:80>
    ServerName azubi-vm-serverops.de
    DocumentRoot /var/www/html
</VirtualHost>

<VirtualHost *:80>
    ServerName azubi-vm-wordpress.de
    DocumentRoot /var/www/html/wordpress
</VirtualHost>

<VirtualHost *:80>
    ServerName azubi-vm-phpmyadmin.de
    DocumentRoot /usr/share/phpMyAdmin
</VirtualHost>


<VirtualHost *:80> = gilt für alle Anfragen auf Port 80 (HTTP)
ServerName = für welche Domain dieser Block gilt
DocumentRoot = welcher Ordner ausgeliefert wird

Speichern mit Strg+O → Enter → Strg+X.
Dann Apache neustarten:
sudo systemctl restart httpd

