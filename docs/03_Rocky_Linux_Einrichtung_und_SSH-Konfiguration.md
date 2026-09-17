Login
Mit dem Benutzer den man Konfiguriert hat davor mit user und Passwort müssen zum Login eingegeben werden.

Kapitel 3.1 – Netzwerk prüfen
Befehl 1:
ip a

Zeigt alle Netzwerk Schnittstellen und ihr IP-Adressen.











Befehl 2:

sudo dnf repolist 

damit kann man überprüfen ob die VM ein Internet zugang hat. Mit Ping funktioniert des nicht da der Ping durch des Firmennetz blokiert wird.  


Kapitel 3.2 – Host-Only-Adapter einrichten für SSH-Zugriff
Einen zweiten Netzwerkadapter hinzufügen, damit du von deinem Windows direkt per SSH auf die VM kommst – ohne Tunnel, ohne Proxy.
Netzwerkadapter 1 (NAT) gibt der VM Internet, aber du kannst von außen nicht darauf zugreifen. Adapter 2 (Host-Only) gibt der VM eine IP die dein Windows direkt erreichen kann.

Fahre die VM kurz runter mit: sudo shutdown now 
Oder Links oben über Maschine und dann Ausschalten.








Um den zweiten Netzwerkadapter zu aktivieren auf ändern drücken und dann auf Netzwerk und dann den Adapter 2 auswählen. Diesen Aktivieren und Host-Only Adapter auswählen bei Angeschlossen an und fertig.














Jetzt solltest du mit ip a einen weitere dritte Schnittstelle sehen enp0s8, aber noch ohne IP-Adresse.

Nun wird die Verbindung für den Host-Only-Adapter angelegt.

Mit dem Befehl: 
sudo nmcli con add type ethernet ifname enp0s8 con-name hostonly ipv4.method auto

Mit nmcli con add wird einen neue Netzwerkverbindung angelegt. Type ethernet ist eine Kabel gebundene Verbindung. Ifname enp0s8 bedeutet für die Schnittstelle und keine andere. Con-name hostonly damit nennen wir die Verbindung „hostonly“. Und mit ipv4.method auto wird die IP-Adresse automatisch per DHCP geholt.

Mit dem Befehl: sudo nmcli con up hostonly         wird die Verbindung aktiviert

Mit ip a show enp0s8 überprüfen ob alle funktioniert hat. Das sollte dann wie folgt anschauen, die ip sollte 192.168.56.xxx sein.  


