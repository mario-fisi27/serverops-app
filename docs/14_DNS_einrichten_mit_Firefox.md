Kapitel 14.1 – tinyproxy installieren

sudo dnf -y install epel-release

Aktiviert das EPEL-Repository, in dem tinyproxy als Paket bereitgestellt wird. Ohne dieses Repo würde dnf das Paket nicht finden.

sudo dnf -y install tinyproxy

Installiert tinyproxy selbst – ein sehr schlanker HTTP-Proxy, der Anfragen entgegennimmt und an das eigentliche Ziel weiterleitet.

Kapitel 14.2 – tinyproxy konfigurieren

sudo nano /etc/tinyproxy/tinyproxy.conf

Öffnet die Konfigurationsdatei von tinyproxy zum Bearbeiten.

Listen-Zeile auskommentiert lassen (Proxy soll auf allen Netzwerkschnittstellen lauschen, nicht nur auf localhost). Im Allow-Bereich das Host-Only-Netzwerk freigeben:

Allow 127.0.0.1
Erlaubt Anfragen von der VM selbst (für lokale Tests).

Allow 192.168.56.0/24
Erlaubt Anfragen aus dem gesamten Host-Only-Netzwerk, also auch vom Windows-Rechner aus. Ohne diese Zeile würde tinyproxy Anfragen von außerhalb der VM ablehnen.

Kapitel 14.3 – Dienst starten und Firewall freigeben

sudo systemctl enable --now tinyproxy
Startet tinyproxy sofort und sorgt gleichzeitig dafür, dass der Dienst bei jedem VM-Neustart automatisch mitstartet.

sudo systemctl status tinyproxy --no-pager
Zeigt den aktuellen Status des Dienstes an, um zu prüfen, ob er wirklich läuft (active/running).

sudo firewall-cmd --permanent --add-port=8888/tcp
Öffnet Port 8888 (den Proxy-Port) dauerhaft in der Firewall, da sonst Anfragen von außerhalb der VM blockiert würden.

sudo firewall-cmd --reload
Lädt die Firewall-Regeln neu, damit die neue Freigabe sofort aktiv wird.

Kapitel 14.4 – Funktionstest auf der VM

getent hosts azubi-vm-wordpress.de
Prüft, ob die VM den Domainnamen selbst auflösen kann (über die eigene /etc/hosts). Erwartete Ausgabe: 127.0.0.1.

curl -x 127.0.0.1:8888 http://azubi-vm-wordpress.de
Schickt eine Testanfrage über den lokalen Proxy. Eine gültige HTTP-Antwort von Apache bestätigt, dass tinyproxy die Anfrage korrekt entgegennimmt, den Namen auflöst und weiterleitet.

Kapitel 14.5 – Funktionstest vom Windows-Rechner

In der Eingabeaufforderung (CMD), mit der IP-Adresse der VM im Host-Only-Netzwerk:

curl -x 192.168.56.101:8888 http://azubi-vm-wordpress.de

Gleicher Test wie zuvor, diesmal aber vom Windows-Rechner aus über das Netzwerk. Bestätigt, dass der Proxy auch von außerhalb der VM erreichbar ist.

Kapitel 14.6 – PAC-Datei erstellen

Mit dem Editor erstellen und als azubi-vm.pac auf dem Desktop speichern (Dateityp: "Alle Dateien", damit keine .txt-Endung angehängt wird):

function FindProxyForURL(url, host) {
    if (dnsDomainIs(host, "azubi-vm-serverops.de") ||
        dnsDomainIs(host, "azubi-vm-wordpress.de") ||
        dnsDomainIs(host, "azubi-vm-phpmyadmin.de")) {
        return "PROXY 192.168.56.101:8888";
    }
    return "DIRECT";
}

Diese Funktion wird von Firefox für jede aufgerufene URL ausgeführt. dnsDomainIs prüft, ob die aufgerufene Domain zu einer der drei Lab-Domains gehört. Falls ja, wird die Anfrage über den Proxy (PROXY 192.168.56.111:8888) geleitet. Für alle anderen Domains gibt die Funktion DIRECT zurück, sodass diese ganz normal ohne Proxy aufgerufen werden.

Kapitel 14.7 – PAC-Datei in Firefox einbinden

Firefox Einstellungen öffnen und folgendes anpassen:

Datenschutz & Sicherheit > Verbindungs- und Softwaresicherheit > Erweiterte Einstellungen > Proxy konfigurieren

Punkt setzten bei „Automatische Proxy-Konfigurations-Adresse:“. 
file:///C:/Users/Dein_Benutzername/Desktop/azubi-vm.pac

file:///C:/Users/Dein Benutzername/OneDrive%20-%20Volkswagen%20AG/Desktop/azubi-vm.pac

Pfad zur eben erstellten PAC-Datei. Firefox liest diese Datei aus und wendet die darin definierte Regel auf jede Anfrage an. Der Pfad kann auch aus dem kopiert werden. Oder einfach auf der Datei einmal Rechtsklick und dann auf Pfad kopieren.

Auf "Neu laden" klicken, mit OK bestätigen, Firefox neustarten.

Kapitel 14.8 – Abschließender Test

Im Browser aufrufen:

http://azubi-vm-wordpress.de
http://azubi-vm-serverops.de
http://azubi-vm-phpmyadmin.de

Alle drei Seiten sollten jetzt über den Domainnamen erreichbar sein, da Firefox diese Anfragen laut PAC-Datei automatisch über den tinyproxy-Server auf der VM leitet. Normales Surfen (z. B. google.de) funktioniert weiterhin ganz normal, da diese Anfragen laut PAC-Datei direkt (ohne Proxy) laufen.
