# ServerOps App

Dieses Repository dokumentiert meine ServerOps-Testumgebung auf Basis von Rocky Linux.

Das Projekt ist im Rahmen meiner Ausbildung zum Fachinformatiker für Systemintegration entstanden und dient dazu, verschiedene typische Aufgaben aus der Linux-Serveradministration praktisch umzusetzen und zu dokumentieren.

Im Fokus stehen unter anderem:

- Linux-Serveradministration
- Apache Webserver
- HTTPS und eigene Zertifizierungsstelle
- MariaDB
- PHP
- WordPress
- phpMyAdmin
- Tomcat
- Java
- Maven
- Blue/Green Deployment
- Reverse Proxy
- Tinyproxy
- Git und GitHub
- Netzwerk- und Firewall-Konfiguration
- Automatisierung mit Bash-Skripten

---

# Projektziel

Ziel des Projekts ist es, eine vollständige Linux-Testumgebung aufzubauen und verschiedene Serverdienste miteinander zu kombinieren.

Die Umgebung soll nicht nur funktionieren, sondern auch nachvollziehbar und reproduzierbar sein.

Dazu werden:

- Konfigurationen dokumentiert
- Skripte versioniert
- Quellcode gespeichert
- wichtige Serverkonfigurationen gesichert
- Installationsschritte dokumentiert
- Screenshots zur Veranschaulichung verwendet

GitHub dient dabei als zentrale Versionsverwaltung für den Quellcode, die Skripte und die Projektdokumentation.

---

# Systemumgebung

Aktuell wird folgende Umgebung verwendet:

- Rocky Linux 10.2
- VirtualBox
- Apache HTTP Server
- MariaDB
- PHP
- WordPress
- phpMyAdmin
- Tomcat 10
- Java 21
- Maven
- Tinyproxy
- Git
- GitHub

Die Rocky-Linux-VM besitzt zusätzlich einen Host-Only-Netzwerkadapter für die Kommunikation zwischen Hostsystem und virtueller Maschine.

Beispiel:

```text
192.168.56.101
```

---

# Netzwerkaufbau

Die Umgebung besteht vereinfacht aus folgendem Aufbau:

```text
Windows Client
      |
      |
      v
Host-Only Netzwerk
      |
      v
Rocky Linux VM
      |
      +----------------------+
      |                      |
      v                      v
Apache :80 / :443       Tinyproxy :8888
      |
      v
Reverse Proxy
      |
      v
Tomcat :8080
      |
      v
Blue / Green Deployment
```

Apache übernimmt dabei den externen Zugriff auf die Anwendungen.

Tomcat läuft intern auf Port `8080`.

Tinyproxy wird verwendet, damit lokale Testdomains über eine PAC-Datei im Browser erreichbar sind.

---

# Verwendete Domains

Für die Testumgebung werden unter anderem folgende lokalen Domains verwendet:

```text
azubi-vm-serverops.de
azubi-vm-wordpress.de
azubi-vm-phpmyadmin.de
```

Diese Domains werden innerhalb der Testumgebung verwendet und sind nicht als öffentliche Internetdomains gedacht.

---

# HTTPS

Für die Testumgebung wurde eine eigene Zertifizierungsstelle verwendet.

Damit können die lokalen Domains über HTTPS aufgerufen werden.

Die eigene CA muss auf dem jeweiligen Client als vertrauenswürdige Stammzertifizierungsstelle importiert werden.

Beispiel:

```text
https://azubi-vm-serverops.de
https://azubi-vm-wordpress.de
https://azubi-vm-phpmyadmin.de
```

Private Schlüssel werden aus Sicherheitsgründen nicht im GitHub-Repository gespeichert.

---

# Java-Webanwendung

Die eigene Java-Webanwendung befindet sich im Repository unter:

```text
src/main/webapp/
```

Wichtige Dateien sind beispielsweise:

```text
src/main/webapp/index.jsp
src/main/webapp/WEB-INF/web.xml
```

Das Maven-Projekt wird über die Datei

```text
pom.xml
```

konfiguriert.

---

# Anwendung bauen

Die Anwendung kann mit Maven gebaut werden.

```bash
mvn package
```

Dabei wird unter anderem das Verzeichnis

```text
target/
```

erstellt.

Darin befindet sich anschließend die erzeugte WAR-Datei.

Build-Artefakte werden bewusst nicht über Git versioniert, da sie jederzeit erneut aus dem Quellcode erzeugt werden können.

---

# Blue/Green Deployment

Für die Java-Anwendung wurde ein Blue/Green-Deployment aufgebaut.

Dabei existieren zwei getrennte Deployments:

```text
app-blue
app-green
```

Dadurch kann eine neue Version zunächst unabhängig von der produktiven Version bereitgestellt und getestet werden.

Beispiel:

```text
Apache
  |
  v
/app
  |
  +------> app-blue
  |
  +------> app-green
```

Eine Version ist dabei aktiv, während die andere vorbereitet oder getestet werden kann.

---

# Deployment-Skripte

Im Repository befinden sich mehrere Bash-Skripte zur Automatisierung.

## deploy.sh

```text
deploy.sh
```

Dieses Skript wird für das Deployment der Java-Anwendung verwendet.

Es unterstützt den Deployment-Prozess und reduziert manuelle Arbeitsschritte.

Ausführen:

```bash
./deploy.sh
```

---

## switch.sh

```text
switch.sh
```

Mit diesem Skript kann zwischen Blue und Green umgeschaltet werden.

Ausführen:

```bash
./switch.sh
```

Dadurch lässt sich eine neue Version aktivieren, ohne die gesamte Umgebung neu aufzubauen.

---

## delete.sh

```text
delete.sh
```

Dieses Skript wird verwendet, um nicht mehr benötigte Deployments oder Dateien kontrolliert zu entfernen.

Ausführen:

```bash
./delete.sh
```

---

# Apache

Apache dient in der Umgebung als zentraler Webserver.

Er übernimmt unter anderem:

- HTTP
- HTTPS
- Virtual Hosts
- Reverse Proxy
- Weiterleitung zu Tomcat

Die relevanten Apache-Konfigurationen befinden sich im Repository unter:

```text
apache/
```

---

# Reverse Proxy

Apache leitet Anfragen an Tomcat weiter.

Tomcat selbst ist intern über:

```text
127.0.0.1:8080
```

erreichbar.

Beispielsweise können folgende Pfade verwendet werden:

```text
/app
/app-blue
/app-green
```

Dabei bleibt Blue und Green jeweils separat erreichbar.

Der Pfad `/app` zeigt auf die aktuell aktive Version.

---

# Tinyproxy und PAC

Für den Zugriff auf die lokalen Domains wird Tinyproxy verwendet.

Die Tinyproxy-Konfiguration befindet sich unter:

```text
tinyproxy/
```

Der Proxy läuft in der Testumgebung auf:

```text
192.168.56.101:8888
```

Eine PAC-Datei entscheidet, welche Domains über diesen Proxy geleitet werden.

Beispiel:

```javascript
function FindProxyForURL(url, host) {

    if (dnsDomainIs(host, "azubi-vm-serverops.de") ||
        dnsDomainIs(host, "azubi-vm-wordpress.de") ||
        dnsDomainIs(host, "azubi-vm-phpmyadmin.de")) {

        return "PROXY 192.168.56.101:8888";
    }

    return "DIRECT";
}
```

---

# Paketübersicht

Eine Übersicht der installierten Rocky-Linux-Pakete befindet sich unter:

```text
packages/
```

Dadurch kann später nachvollzogen werden, welche Software auf der VM installiert war.

Eine Paketliste kann beispielsweise mit folgendem Befehl erstellt werden:

```bash
rpm -qa | sort > packages/installed-packages.txt
```

---

# Projektdokumentation

Die ausführliche Projektdokumentation befindet sich unter:

```text
docs/
```

Die Markdown-Versionen der einzelnen Kapitel befinden sich unter:

```text
docs/md_files/
```

Die Dokumentation besteht aktuell aus 14 Kapiteln.

Unter anderem werden folgende Themen behandelt:

1. Remoteverbindung und VirtualBox
2. Erstellen der virtuellen Maschine
3. Rocky-Linux-Einrichtung und SSH
4. Installation des LAMP-Stacks
5. WordPress
6. Apache und Virtual Hosts
7. lokale Namensauflösung
8. Testseite und Browserzugriff
9. Landingpage
10. Zertifikate und HTTPS
11. Python-Skript für Zertifikatsinformationen
12. Tomcat und Maven
13. Deployment-Automatisierung
14. DNS beziehungsweise Browser-/Proxy-Konfiguration

---

# Screenshots

Zusätzlich befinden sich Screenshots unter:

```text
docs/images/
```

Diese Bilder ergänzen die Dokumentation und zeigen beispielsweise:

- Konfigurationen
- Installationsschritte
- Terminalausgaben
- Webseiten
- Testergebnisse

Markdown-Dateien können die Bilder direkt einbinden.

Beispiel:

```markdown
![SSH Verbindung](../images/ssh-verbindung.png)
```

---

# Repository-Struktur

Der Aufbau des Repositories sieht ungefähr folgendermaßen aus:

```text
serverops-app/
│
├── apache/
│
├── docs/
│   ├── images/
│   └── md_files/
│
├── packages/
│
├── src/
│   └── main/
│       └── webapp/
│           ├── index.jsp
│           └── WEB-INF/
│               └── web.xml
│
├── tinyproxy/
│
├── .gitignore
├── delete.sh
├── deploy.sh
├── index-green-backup.jsp
├── pom.xml
├── README.md
└── switch.sh
```

---

# Git und GitHub

Das Projekt wird mit Git versioniert.

Typischer Ablauf bei Änderungen:

```bash
git status
```

Änderungen hinzufügen:

```bash
git add .
```

Commit erstellen:

```bash
git commit -m "Beschreibung der Änderung"
```

Änderungen nach GitHub übertragen:

```bash
git push
```

Aktuelle Änderungen von GitHub holen:

```bash
git pull
```

---

# Was wird nicht versioniert?

Nicht alle Dateien einer Serverumgebung gehören in Git.

Folgende Dateien werden bewusst nicht gespeichert:

```text
target/
*.war
*.log
*.tmp
```

Zusätzlich gehören sensible Informationen grundsätzlich nicht in das Repository.

Dazu gehören beispielsweise:

- private SSH-Schlüssel
- SSL-Private-Keys
- CA-Private-Keys
- Passwörter
- API-Tokens
- GitHub-Tokens
- Datenbankpasswörter
- Zugangsdaten
- produktive Datenbank-Dumps

---

# Gitignore

Über die Datei

```text
.gitignore
```

werden unnötige oder automatisch erzeugte Dateien vom Repository ausgeschlossen.

Beispiel:

```gitignore
target/
*.war
*.log
*.tmp
*~
*.swp
```

---

# Ziel der Versionsverwaltung

Das Ziel besteht nicht darin, die komplette virtuelle Maschine auf GitHub zu speichern.

Stattdessen sollen alle wichtigen Bestandteile gespeichert werden, die benötigt werden, um die Umgebung nachvollziehen oder teilweise wiederherstellen zu können.

Dazu gehören insbesondere:

```text
Quellcode
Konfigurationen
Bash-Skripte
Dokumentation
Paketlisten
Anleitungen
Screenshots
```

Die eigentliche virtuelle Maschine kann separat beispielsweise als OVA-Datei gesichert werden.

---

# Aktueller Stand

Der aktuelle Projektstand umfasst unter anderem:

- Rocky Linux 10.2
- Apache
- HTTPS
- eigene CA
- MariaDB
- PHP
- WordPress
- phpMyAdmin
- Tomcat
- Java
- Maven
- Blue/Green Deployment
- Reverse Proxy
- Tinyproxy
- PAC-Konfiguration
- SSH
- Git
- GitHub
- Bash-Automatisierung
- Projektdokumentation

Die Umgebung wird weiterhin erweitert und dient als praktische Test- und Lernplattform für Linux-Serveradministration und Systemintegration.~
