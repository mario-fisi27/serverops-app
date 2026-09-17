Download des ISO-Images von RockyLinux
Offizielle Website von RockyLinux
https://rockylinux.org/de/download

- Download des DVD ISO Images für RockyLinux v9.4 (vielleicht neuere Version von RockyLinux)

Ich habe mich für das DVD ISO Image entschieden, da es das umfänglichste Softwarepaket enthält, was hoffentlich dazu führt, dass im Laufe der folgenden Installationen möglichst wenig Grundlagen nachinstalliert werden müssen. 

 

Falls die VM Probleme macht aufgrund des Rocky Linux dvd iso, das kommt wenn die Datei nicht vollständig runtergeladen wurde. Dies kann man testen wenn man die iso Datei öffnen will dann sollte kein Fehler kommen. Unten kommt dann der folgende Fehler wenn die Datei nicht vollständig ist. Durch Download im Browser problem. 





Das Problem kann man beheben in dem man Rocky Linux in Powershell runterlädt.

Code in Powershell einfügen:

Start-BitsTransfer -Source "https://dl.rockylinux.org/vault/rocky/9.4/isos/x86_64/Rocky-9.4-x86_64-dvd.iso" -Destination "$HOME\Desktop\Rocky-9.4-dvd.iso"

 

Der Download sollte so aussehen.
Virtuelle Maschine erstellen und hochfahren
- VirtualBox starten und eine neue VM erstellen

- Experten-Modus aktivieren

- im Folgenden werden die Spezifikationen der virtuellen Maschine festgelegt


Name und Betriebssystem
 

















Hardware
 


Festplatte
 - die virtuelle Maschine ist nun fertiggestellt und kannmit einem Klick auf    erstmals hochgefahren werden

- im erscheinenden Menü des Bootloaders „GRUB“, wird nun
„test this media & install Rocky Linux 9.4” gewählt.
 
Es kann nun eine Weile dauern, bis die im Folgenden ablaufenden Prüfungen des Installationsmediums (der ISO-Datei) abgeschlossen sind.
Die jetzt ablaufenden Prüfungen umfassen:

Integritätsprüfung: Die Prüfsummen (Checksums) der Dateien auf dem Medium werden mit den erwarteten Prüfsummen verglichen, um Beschädigungen oder Veränderungen der Datei ausschließen zu können.

Lesbarkeitstest: Die Lesbarkeit aller Inhalte des Installationsmedium bzw. der ISO-Datei wird geprüft, um Probleme ggf. noch vor der eigentlichen Installation erkennen zu können.


Im Anschluss wird man von der grafischen Oberfläche des Installers begrüßt:
 


Im folgenden Fenster müssen noch ein Paar Konfigurationen vorgenommen werden:
 


Software-Auswahl
Als Basisumgebung wählt man „Server“ und als zusätzliche Software für die ausgewählte Umgebung werden bei folgenden Punkten Haken gesetzt:



Debugging-Tools: Hilfreich, um Probleme in der Umgebung zu identifizieren und zu beheben.

DNS-Nameserver: Könnte evtl. im Zusammenhang mit Apache oder Webhosting hilfreich sein.

Hardware Überwachungs-Dienstprogramme: Eine Reihe von Tools zur Überwachung von Server-Hardware
Network File System Client: Ermöglicht dem System die Anbindung an Netzwerkstorage.

Netzwerk-Server: Diese Pakete enthalten netzwerkbasierte Server wie DHCP, Kerberos und NIS.

Remote-Verwaltung für Linux: Fernverwaltungsschnittstelle für Rocky Linux.

Windows-Dateiserver: Mit dieser Paketgruppe können Dateien in Linux und MS Windows gemeinsam genutzt werden.

Internet-Tools für die Konsole: Da das Ziel ist, alles über die Kommandozeile zu machen, sind diese Tools ggf. hilfreich für Netzwerkdiagnosen und andere internetbezogene Aufgaben.

Containerverwaltung: Falls in Zukunft mit Containern gearbeitet wird, sind diese Tools nützlich, um Anwendungen in isolierten Umgebungen zu betreiben.

Entwicklungswerkzeuge: Eine grundlegende Entwicklungsumgebung.

Kopfloses Management: Tools zur Verwaltung des Systems ohne GUI.

RPM Entwicklungswerkzeuge: Tools, die eventuell für die Paketverwaltung von RPM-Paketen sinnvoll sein könnte.

Sicherheitstools: Verschiedene Tools zur Überprüfung der Integrität und Vertrauenswürdigkeit von Inhalten. Da mit Webanwendungen gearbeitet wird ist die Sicherheit von erhöhter Bedeutung.

Smart-Card-Unterstützung: Unterstützung für die Verwendung von Smart Card Authentifikation.

Systemwerkzeuge: Grundlegende Verwaltungs- und Wartungstools.

 sind alle Haken gesetzt kommt man mit einem Klick auf „Fertig“ oben links zurück zur Zusammenfassung der Installation



System
Dass die automatische Partitionierung ausgewählt ist, ist für dieses Experiment nicht relevant und kann daher so belassen werden


Benutzereinstellungen
Root-Passwort
- gewünschtes root-Passwort eingeben | zum Beispiel: ServerOps#123
- Haken bei „Root-Konto sperren“ nicht setzen
- „Root-SSH-Anmeldung mit Passwort zulassen“ anhaken!

 mit sudo ausgeführte Aktionen sind tendenziell besser nachvollziehbar und auch die Anzahl versehentlicher Falscheingaben wird reduziert, da nach jeder Eingabe i.d.R. mit dem Passwort bestätigt werden muss.


Benutzer anlegen
- Benutzername und Passwort für den eigenen Nutzer definieren
 zum Beispiel:   user: matt  pw: password#123
- Haken setzen bei „diesen Anwender als Administrator festlegen“ sowie bei „Passworteingabe erforderlich für dieses Konto“


Installation starten
Nachdem alle Konfigurationen erledigt sind, sollte der Button „Installation starten“ in blau geworden sein  Installation kann gestartet werden.

- abwarten bis es fertig ist, und System neustarten, um die Installation abzuschließen
 

