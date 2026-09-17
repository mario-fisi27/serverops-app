Kapitel 12.1 – Tomcat & Java-App-Deployment(Erweiterung)

sudo dnf -y install java-17-openjdk tomcat maven

•	java-17-openjdk = Java 17 Laufzeitumgebung
•	tomcat = Application Server für Java-Web-Apps
•	maven = Build-Tool, erzeugt aus Quellcode ein .war-Artefakt

Tomcat starten und dauerhaft aktivieren:
sudo systemctl enable --now tomcat
sudo systemctl status tomcat --no-pager

Sollte active (running) zeigen. 
 
Kapitel 12.2 – Projektstruktur und Dateien anlegen

Ordnerstruktur erstellen:
mkdir -p ~/app/src/main/webapp/WEB-INF

Maven-Konfiguration (pom.xml):
nano ~/app/pom.xml

Inhalt:
<project>
  <modelVersion>4.0.0</modelVersion>
  <groupId>de.vwgs</groupId>
  <artifactId>azubi-app</artifactId>
  <version>1.0</version>
  <packaging>war</packaging>
  <build>
    <finalName>app</finalName>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>3.4.0</version>
      </plugin>
    </plugins>
  </build>
</project>


Wichtig: Die maven-war-plugin Version 3.4.0 muss explizit angegeben werden, sonst kommt ein Kompatibilitätsfehler.

web.xml:
nano ~/app/src/main/webapp/WEB-INF/web.xml



Inhalt:
<web-app>
  <display-name>Azubi App</display-name>
</web-app>

Kapitel 12.3 – Version 1.0 (Blue) erstellen – Infrastruktur-Übersicht

nano ~/app/src/main/webapp/index.jsp

Inhalt:

<html>
<head>
    <title>ServerOps App v1.0</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Arial, sans-serif; background: #0f172a; color: #cbd5e1; line-height: 1.6; }
        .hero { background: linear-gradient(135deg, #1e3a5f 0%, #0f172a 100%); padding: 60px 20px; text-align: center; border-bottom: 3px solid #1a73e8; }
        .badge { display: inline-block; background: #1a73e8; color: white; padding: 6px 20px; border-radius: 20px; font-size: 12px; font-weight: 700; letter-spacing: 2px; margin-bottom: 20px; text-transform: uppercase; }
        h1 { font-size: 36px; color: #ffffff; margin-bottom: 10px; }
        .hero p { color: #94a3b8; font-size: 18px; max-width: 600px; margin: 0 auto; }
        .content { max-width: 800px; margin: 0 auto; padding: 40px 20px; }
        h2 { color: #1a73e8; font-size: 22px; margin: 40px 0 20px 0; padding-bottom: 10px; border-bottom: 2px solid #1e293b; }
        p { margin-bottom: 14px; font-size: 15px; }
        .card { background: #1e293b; border-radius: 12px; padding: 24px; margin-bottom: 20px; border: 1px solid #334155; }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .card-title { color: #1a73e8; font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; }
        .status-badge { background: #065f46; color: #6ee7b7; padding: 4px 12px; border-radius: 12px; font-size: 11px; font-weight: 600; }
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .info-item { background: #0f172a; border-radius: 8px; padding: 16px; }
        .info-label { color: #64748b; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 4px; }
        .info-value { color: #e2e8f0; font-size: 16px; font-weight: 600; }
        .progress-bar { background: #0f172a; border-radius: 8px; height: 8px; margin-top: 8px; overflow: hidden; }
        .progress-fill { height: 100%; border-radius: 8px; }
        .resource-item { display: flex; justify-content: space-between; align-items: center; padding: 14px 0; border-bottom: 1px solid #334155; }
        .resource-item:last-child { border-bottom: none; }
        .resource-name { color: #94a3b8; font-size: 14px; }
        .resource-value { color: #e2e8f0; font-size: 14px; font-weight: 500; }
        .arch-container { display: flex; flex-direction: column; gap: 12px; margin-top: 16px; }
        .arch-layer { background: #0f172a; border-radius: 8px; padding: 16px; display: flex; align-items: center; gap: 16px; border-left: 3px solid #1a73e8; }
        .arch-icon { font-size: 28px; min-width: 40px; text-align: center; }
        .arch-info { flex: 1; }
        .arch-name { color: #e2e8f0; font-weight: 600; font-size: 15px; }
        .arch-desc { color: #64748b; font-size: 13px; margin-top: 2px; }
        .network-table { width: 100%; border-collapse: collapse; margin-top: 16px; }
        .network-table th { background: #1a73e8; color: white; padding: 10px 14px; text-align: left; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
        .network-table td { padding: 10px 14px; border-bottom: 1px solid #334155; font-size: 14px; }
        .network-table tr:nth-child(even) { background: #0f172a; }
        .footer { text-align: center; padding: 40px 20px; color: #475569; font-size: 12px; border-top: 1px solid #1e293b; margin-top: 40px; }
    </style>
</head>
<body>
    <div class="hero">
        <div class="badge">Version 1.0 - Blue - Stable</div>
        <h1>ServerOps Infrastruktur</h1>
        <p>Komplette Uebersicht der virtualisierten Server-Umgebung fuer das Azubi-Webhosting-Projekt</p>
    </div>
    <div class="content">
        <h2>Was ist Virtualisierung?</h2>
        <p>Virtualisierung ermoeglicht es, auf einem physischen Computer mehrere virtuelle Maschinen (VMs) gleichzeitig zu betreiben. Jede VM verhaelt sich wie ein eigenstaendiger Server mit eigenem Betriebssystem, eigenen Netzwerkeinstellungen und eigenen Anwendungen. Der Hypervisor (in unserem Fall VirtualBox) verwaltet die Hardware-Ressourcen und teilt sie zwischen den VMs auf.</p>
        <p>Der grosse Vorteil: Statt fuer jeden Dienst einen eigenen physischen Server zu kaufen, laufen alle Dienste isoliert auf einer Maschine. Das spart Kosten, Platz und Energie - und ist heute der Standard in jedem Rechenzentrum.</p>
        <h2>VM-Konfiguration</h2>
        <div class="card">
            <div class="card-header"><span class="card-title">Virtuelle Maschine</span><span class="status-badge">Active</span></div>
            <div class="info-grid">
                <div class="info-item"><div class="info-label">Hostname</div><div class="info-value">Projekt-ServerOps</div></div>
                <div class="info-item"><div class="info-label">Betriebssystem</div><div class="info-value">Rocky Linux 9.8</div></div>
                <div class="info-item"><div class="info-label">Hypervisor</div><div class="info-value">Oracle VirtualBox</div></div>
                <div class="info-item"><div class="info-label">Installationsmedium</div><div class="info-value">Rocky 9.4 DVD-ISO</div></div>
            </div>
        </div>
        <h2>Zugewiesene Ressourcen</h2>
        <div class="card">
            <div class="resource-item"><span class="resource-name">Arbeitsspeicher (RAM)</span><span class="resource-value">4.096 MB</span></div>
            <div class="progress-bar"><div class="progress-fill" style="width:50%;background:#1a73e8;"></div></div>
            <div class="resource-item"><span class="resource-name">Prozessorkerne (CPU)</span><span class="resource-value">2 vCPUs</span></div>
            <div class="progress-bar"><div class="progress-fill" style="width:25%;background:#8b5cf6;"></div></div>
            <div class="resource-item"><span class="resource-name">Festplatte</span><span class="resource-value">50 GB (dynamisch)</span></div>
            <div class="progress-bar"><div class="progress-fill" style="width:35%;background:#10b981;"></div></div>
            <div class="resource-item"><span class="resource-name">Netzwerkadapter</span><span class="resource-value">2 (NAT + Host-Only)</span></div>
        </div>
        <h2>Architektur-Stack</h2>
        <p>Die Umgebung besteht aus mehreren Schichten, die aufeinander aufbauen:</p>
        <div class="card">
            <div class="arch-container">
                <div class="arch-layer"><div class="arch-icon">🖥️</div><div class="arch-info"><div class="arch-name">Hardware / Host-System (Windows)</div><div class="arch-desc">Der physische Rechner. Stellt CPU, RAM und Festplatte bereit.</div></div></div>
                <div class="arch-layer"><div class="arch-icon">📦</div><div class="arch-info"><div class="arch-name">Hypervisor (VirtualBox)</div><div class="arch-desc">Erstellt und verwaltet virtuelle Maschinen. Teilt die Hardware-Ressourcen auf.</div></div></div>
                <div class="arch-layer"><div class="arch-icon">🐧</div><div class="arch-info"><div class="arch-name">Betriebssystem (Rocky Linux 9)</div><div class="arch-desc">RHEL-kompatibler Server, headless. Verwaltet Dienste, Benutzer und Netzwerk.</div></div></div>
                <div class="arch-layer"><div class="arch-icon">🌐</div><div class="arch-info"><div class="arch-name">Webserver (Apache HTTPD)</div><div class="arch-desc">Nimmt HTTP/HTTPS-Anfragen entgegen und liefert Webseiten aus.</div></div></div>
                <div class="arch-layer"><div class="arch-icon">🗄️</div><div class="arch-info"><div class="arch-name">Datenbank (MariaDB)</div><div class="arch-desc">Speichert alle Daten fuer WordPress und andere Anwendungen.</div></div></div>
                <div class="arch-layer"><div class="arch-icon">☕</div><div class="arch-info"><div class="arch-name">App-Server (Apache Tomcat)</div><div class="arch-desc">Fuehrt Java-Web-Anwendungen aus. Empfaengt Anfragen ueber den Reverse Proxy.</div></div></div>
            </div>
        </div>
        <h2>Netzwerk-Konfiguration</h2>
        <p>Die VM hat zwei Netzwerkadapter mit unterschiedlichen Aufgaben:</p>
        <div class="card">
            <table class="network-table">
                <tr><th>Adapter</th><th>Typ</th><th>IP-Adresse</th><th>Zweck</th></tr>
                <tr><td>enp0s3</td><td>NAT</td><td>10.0.2.15</td><td>Internetzugang</td></tr>
                <tr><td>enp0s8</td><td>Host-Only</td><td>192.168.56.101</td><td>Zugriff vom Host</td></tr>
            </table>
        </div>
        <h2>Installierte Dienste</h2>
        <div class="card">
            <table class="network-table">
                <tr><th>Dienst</th><th>Port</th><th>Status</th><th>Aufgabe</th></tr>
                <tr><td>Apache (httpd)</td><td>80 / 443</td><td>Active</td><td>Webseiten, HTTPS, Reverse Proxy</td></tr>
                <tr><td>MariaDB</td><td>3306</td><td>Active</td><td>Datenbank fuer WordPress</td></tr>
                <tr><td>Tomcat</td><td>8080</td><td>Active</td><td>Java-Web-Apps</td></tr>
                <tr><td>SSH (sshd)</td><td>22</td><td>Active</td><td>Fernzugriff</td></tr>
            </table>
        </div>
        <h2>Sicherheit</h2>
        <div class="card">
            <div class="card-header"><span class="card-title">Sicherheitskonfiguration</span><span class="status-badge">Enforcing</span></div>
            <div class="resource-item"><span class="resource-name">SELinux</span><span class="resource-value">Enforcing (strengster Modus)</span></div>
            <div class="resource-item"><span class="resource-name">Firewall</span><span class="resource-value">Aktiv - nur HTTP, HTTPS, SSH, 8080 offen</span></div>
            <div class="resource-item"><span class="resource-name">SSL/TLS</span><span class="resource-value">Eigene CA mit SHA-256 Zertifikaten</span></div>
            <div class="resource-item"><span class="resource-name">MariaDB</span><span class="resource-value">Root abgesichert, kein Remote-Zugang</span></div>
        </div>
        <p>Im Gegensatz zum Original-Projekt werden Firewall und SELinux nicht deaktiviert, sondern aktiv konfiguriert.</p>
        <div class="footer"><p>ServerOps Infrastruktur v1.0 (Blue) | Mario | FiSi Azubi | VW Group Services 2026</p></div>
    </div>
</body>
</html>




Speichern. Bauen und Version 1.0 sichern:

cd ~/app
mvn clean package
cp ~/app/target/app.war ~/app/app-1.0.war

Ergebnis sollte sein: BUILD SUCCESS!

 
Kapitel 12.4 – Version 1.1 (Green) erstellen – Deployment & DevOps

Datei leeren und neu beschreiben:

echo "" > ~/app/src/main/webapp/index.jsp
nano ~/app/src/main/webapp/index.jsp

Inhalt:
<html>
<head>
    <title>ServerOps App v1.1</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Arial, sans-serif; background: #0f172a; color: #cbd5e1; line-height: 1.6; }
        .hero { background: linear-gradient(135deg, #064e3b 0%, #0f172a 100%); padding: 60px 20px; text-align: center; border-bottom: 3px solid #10b981; }
        .badge { display: inline-block; background: #10b981; color: white; padding: 6px 20px; border-radius: 20px; font-size: 12px; font-weight: 700; letter-spacing: 2px; margin-bottom: 20px; text-transform: uppercase; }
        .new-flag { display: inline-block; background: #f59e0b; color: #0f172a; padding: 4px 10px; border-radius: 4px; font-size: 11px; font-weight: 700; margin-left: 8px; }
        h1 { font-size: 36px; color: #ffffff; margin-bottom: 10px; }
        .hero p { color: #94a3b8; font-size: 18px; max-width: 600px; margin: 0 auto; }
        .content { max-width: 800px; margin: 0 auto; padding: 40px 20px; }
        h2 { color: #10b981; font-size: 22px; margin: 40px 0 20px 0; padding-bottom: 10px; border-bottom: 2px solid #1e293b; }
        p { margin-bottom: 14px; font-size: 15px; }
        .card { background: #1e293b; border-radius: 12px; padding: 24px; margin-bottom: 20px; border: 1px solid #334155; }
        .card-title { color: #10b981; font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 16px; }
        .flow { display: flex; flex-direction: column; gap: 0; margin-top: 16px; }
        .flow-step { display: flex; align-items: stretch; gap: 16px; }
        .flow-line { display: flex; flex-direction: column; align-items: center; min-width: 40px; }
        .flow-dot { width: 16px; height: 16px; background: #10b981; border-radius: 50%; border: 3px solid #1e293b; z-index: 1; flex-shrink: 0; }
        .flow-connector { width: 2px; background: #334155; flex: 1; min-height: 20px; }
        .flow-content { background: #0f172a; border-radius: 8px; padding: 16px; flex: 1; margin-bottom: 12px; border-left: 3px solid #10b981; }
        .flow-title { color: #e2e8f0; font-weight: 600; font-size: 15px; }
        .flow-desc { color: #64748b; font-size: 13px; margin-top: 4px; }
        .comparison { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 16px; }
        .comp-card { background: #0f172a; border-radius: 8px; padding: 20px; text-align: center; }
        .comp-card.old { border: 2px solid #dc2626; }
        .comp-card.new { border: 2px solid #10b981; }
        .comp-label { font-size: 12px; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 8px; font-weight: 700; }
        .comp-card.old .comp-label { color: #dc2626; }
        .comp-card.new .comp-label { color: #10b981; }
        .comp-value { color: #e2e8f0; font-size: 24px; font-weight: 700; }
        .comp-desc { color: #64748b; font-size: 12px; margin-top: 4px; }
        .strategy-grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; margin-top: 16px; }
        .strategy-item { background: #0f172a; border-radius: 8px; padding: 20px; text-align: center; border: 1px solid #334155; }
        .strategy-icon { font-size: 32px; margin-bottom: 8px; }
        .strategy-name { color: #e2e8f0; font-weight: 600; font-size: 14px; margin-bottom: 4px; }
        .strategy-desc { color: #64748b; font-size: 12px; }
        .changelog { margin-top: 16px; }
        .change-item { display: flex; gap: 12px; padding: 12px 0; border-bottom: 1px solid #334155; }
        .change-item:last-child { border-bottom: none; }
        .change-type { padding: 2px 10px; border-radius: 4px; font-size: 11px; font-weight: 700; height: fit-content; margin-top: 2px; }
        .change-type.feature { background: #10b981; color: white; }
        .change-type.security { background: #f59e0b; color: #0f172a; }
        .change-type.fix { background: #3b82f6; color: white; }
        .change-text { flex: 1; }
        .change-title { color: #e2e8f0; font-size: 14px; font-weight: 500; }
        .change-desc { color: #64748b; font-size: 12px; margin-top: 2px; }
        .network-table { width: 100%; border-collapse: collapse; margin-top: 16px; }
        .network-table th { background: #10b981; color: white; padding: 10px 14px; text-align: left; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
        .network-table td { padding: 10px 14px; border-bottom: 1px solid #334155; font-size: 14px; }
        .network-table tr:nth-child(even) { background: #0f172a; }
        .footer { text-align: center; padding: 40px 20px; color: #475569; font-size: 12px; border-top: 1px solid #1e293b; margin-top: 40px; }
    </style>
</head>
<body>
    <div class="hero">
        <div class="badge">Version 1.1 - Green - Latest</div>
        <h1>ServerOps Deployment<span class="new-flag">UPDATED</span></h1>
        <p>Deployment-Pipeline, Versionierung und Release-Strategien fuer das Azubi-Webhosting-Projekt</p>
    </div>
    <div class="content">
        <h2>Was ist Deployment?</h2>
        <p>Deployment ist der Prozess, eine fertig entwickelte Anwendung auf einen Server zu bringen, damit sie fuer Benutzer erreichbar ist. In der modernen Softwareentwicklung ist das kein einmaliger Vorgang, sondern ein wiederholbarer, automatisierbarer Prozess.</p>
        <p>Ein gutes Deployment-Verfahren stellt sicher, dass neue Versionen schnell, zuverlaessig und ohne Ausfallzeit bereitgestellt werden koennen - und dass man bei Problemen sofort auf die vorherige Version zurueckkehren kann (Rollback).</p>
        <h2>Die Deployment-Pipeline</h2>
        <p>Vom Quellcode bis zur laufenden Anwendung durchlaeuft die Software mehrere Stationen:</p>
        <div class="card">
            <div class="flow">
                <div class="flow-step"><div class="flow-line"><div class="flow-dot"></div><div class="flow-connector"></div></div><div class="flow-content"><div class="flow-title">1. Quellcode schreiben</div><div class="flow-desc">Der Entwickler schreibt oder aendert den Code (index.jsp). Der Code wird versioniert gespeichert.</div></div></div>
                <div class="flow-step"><div class="flow-line"><div class="flow-dot"></div><div class="flow-connector"></div></div><div class="flow-content"><div class="flow-title">2. Build (Bauen)</div><div class="flow-desc">Apache Maven uebersetzt den Quellcode und verpackt alles in ein .war-Artefakt.</div></div></div>
                <div class="flow-step"><div class="flow-line"><div class="flow-dot"></div><div class="flow-connector"></div></div><div class="flow-content"><div class="flow-title">3. Artefakt sichern</div><div class="flow-desc">Das .war-Artefakt wird versioniert gespeichert (app-1.0.war, app-1.1.war).</div></div></div>
                <div class="flow-step"><div class="flow-line"><div class="flow-dot"></div><div class="flow-connector"></div></div><div class="flow-content"><div class="flow-title">4. Deployment</div><div class="flow-desc">Das Artefakt wird in Tomcats webapps-Ordner kopiert. Tomcat deployt automatisch.</div></div></div>
                <div class="flow-step"><div class="flow-line"><div class="flow-dot"></div></div><div class="flow-content"><div class="flow-title">5. Verifizierung</div><div class="flow-desc">Im Browser pruefen ob die neue Version korrekt laeuft. Bei Problemen sofort Rollback.</div></div></div>
            </div>
        </div>
        <h2>Modernisierung: Original vs. Neu</h2>
        <div class="comparison">
            <div class="comp-card old"><div class="comp-label">Original</div><div class="comp-value">Stunden</div><div class="comp-desc">Pakete manuell als RPM kopieren und installieren</div></div>
            <div class="comp-card new"><div class="comp-label">Modernisiert</div><div class="comp-value">Minuten</div><div class="comp-desc">Ein dnf-Befehl installiert alles automatisch</div></div>
        </div>
        <div class="comparison">
            <div class="comp-card old"><div class="comp-label">Original</div><div class="comp-value">Aus</div><div class="comp-desc">Firewall und SELinux komplett deaktiviert</div></div>
            <div class="comp-card new"><div class="comp-label">Modernisiert</div><div class="comp-value">Aktiv</div><div class="comp-desc">Firewall mit Regeln, SELinux auf Enforcing</div></div>
        </div>
        <h2>Deployment-Strategien</h2>
        <div class="strategy-grid">
            <div class="strategy-item"><div class="strategy-icon">🔄</div><div class="strategy-name">Rolling Update</div><div class="strategy-desc">Alte Version wird direkt ersetzt. Einfach, aber kurze Downtime moeglich.</div></div>
            <div class="strategy-item" style="border-color:#10b981;"><div class="strategy-icon">🔵🟢</div><div class="strategy-name">Blue/Green</div><div class="strategy-desc">Zwei Versionen parallel. Umschalten ohne Downtime.</div></div>
            <div class="strategy-item"><div class="strategy-icon">🐤</div><div class="strategy-name">Canary</div><div class="strategy-desc">Neue Version bekommt erst wenig Traffic. Bei Erfolg hochfahren.</div></div>
        </div>
        <h2>Blue/Green in der Praxis</h2>
        <div class="card">
            <table class="network-table">
                <tr><th>Umgebung</th><th>Version</th><th>Pfad</th><th>Status</th></tr>
                <tr><td style="color:#3b82f6;font-weight:600;">Blue</td><td>1.0 (Stable)</td><td>/app-blue</td><td>Standby</td></tr>
                <tr><td style="color:#10b981;font-weight:600;">Green</td><td>1.1 (Latest)</td><td>/app-green</td><td>Live</td></tr>
            </table>
        </div>
        <h2>Changelog: v1.0 zu v1.1</h2>
        <div class="card">
            <div class="changelog">
                <div class="change-item"><span class="change-type feature">Feature</span><div class="change-text"><div class="change-title">Deployment-Dashboard hinzugefuegt</div><div class="change-desc">Neue Seite mit Pipeline, Strategien und Versionierung</div></div></div>
                <div class="change-item"><span class="change-type feature">Feature</span><div class="change-text"><div class="change-title">Blue/Green Deployment implementiert</div><div class="change-desc">Zwei Versionen parallel, Umschaltung ueber Reverse Proxy</div></div></div>
                <div class="change-item"><span class="change-type security">Security</span><div class="change-text"><div class="change-title">SELinux auf Enforcing</div><div class="change-desc">Strengster Sicherheitsmodus aktiv</div></div></div>
                <div class="change-item"><span class="change-type security">Security</span><div class="change-text"><div class="change-title">HTTPS mit eigener CA</div><div class="change-desc">Alle Seiten ueber SSL/TLS verschluesselt</div></div></div>
                <div class="change-item"><span class="change-type fix">Improve</span><div class="change-text"><div class="change-title">Paketmanagement modernisiert</div><div class="change-desc">RPM-Installation durch dnf ersetzt</div></div></div>
            </div>
        </div>
        <h2>Technologie-Stack</h2>
        <div class="card">
            <table class="network-table">
                <tr><th>Komponente</th><th>Technologie</th><th>Aufgabe</th></tr>
                <tr><td>Betriebssystem</td><td>Rocky Linux 9</td><td>RHEL-kompatibler Server</td></tr>
                <tr><td>Webserver</td><td>Apache HTTPD</td><td>HTTP/HTTPS, Reverse Proxy</td></tr>
                <tr><td>App-Server</td><td>Apache Tomcat</td><td>Java-Web-Apps ausfuehren</td></tr>
                <tr><td>Build-Tool</td><td>Apache Maven</td><td>Quellcode zu .war bauen</td></tr>
                <tr><td>Datenbank</td><td>MariaDB</td><td>Datenhaltung</td></tr>
                <tr><td>Sicherheit</td><td>SELinux + firewalld</td><td>Zugriffskontrolle</td></tr>
            </table>
        </div>
        <div class="footer"><p>ServerOps Deployment v1.1 (Green) | Mario | FiSi Azubi | VW Group Services 2026</p></div>
    </div>
</body>
</html>

Speichern. pom.xml Version ändern:

nano ~/app/pom.xml

<version>1.0</version> ändern zu <version>1.1</version>. Speichern.

Bauen und sichern:

cd ~/app
mvn clean package
cp ~/app/target/app.war ~/app/app-1.1.war

Ergebnis sollte sein: BUILD SUCCESS!
 

Kapitel 12.5 – Beide Versionen deployen

sudo cp ~/app/app-1.0.war /var/lib/tomcat/webapps/app-blue.war
sudo cp ~/app/app-1.1.war /var/lib/tomcat/webapps/app-green.war
sudo cp ~/app/app-1.1.war /var/lib/tomcat/webapps/app.war

Im Browser:
•	http://192.168.56.101:8080/app-blue/ → Version 1.0
•	http://192.168.56.101:8080/app-green/ → Version 1.1

Kapitel 12.6 – Reverse Proxy einrichten

sudo nano /etc/httpd/conf.d/app-proxy.conf

Inhalt:
# Live - hier wird umgeschaltet
ProxyPass /app http://127.0.0.1:8080/app-green/
ProxyPassReverse /app http://127.0.0.1:8080/app-green/

# Blue immer erreichbar
ProxyPass /app-blue http://127.0.0.1:8080/app-blue/
ProxyPassReverse /app-blue http://127.0.0.1:8080/app-blue/

# Green immer erreichbar
ProxyPass /app-green http://127.0.0.1:8080/app-green/
ProxyPassReverse /app-green http://127.0.0.1:8080/app-green/


sudo systemctl restart httpd

Jetzt über HTTPS:
•	https://192.168.56.101/app → App (Live)
•	https://192.168.56.101/app-blue → Version 1.0
•	https://192.168.56.101/app-green → Version 1.1

Kapitel 12.7 – Rollback demonstrieren

Umschalten auf Blue (Rollback auf v1.0):

sudo sed -i '2s/app-green/app-blue/; 3s/app-green/app-blue/' /etc/httpd/conf.d/app-proxy.conf && sudo systemctl restart httpd

Browser F5 auf https://192.168.56.101/app → Version 1.0 ist zurück. 

Zurück auf Green:
sudo sed -i '2s/app-blue/app-green/; 3s/app-blue/app-green/' /etc/httpd/conf.d/app-proxy.conf && sudo systemctl restart httpd
Kapitel 12.8 – Landingpage Links aktualisieren

sudo nano /usr/local/bin/cert-info.py

Den <div class="links"> Block ersetzen durch:

    <div class="links">
        <a href="/wordpress">WordPress</a>
        <a href="/phpmyadmin">phpMyAdmin</a>
        <a href="/testseite.html">Testseite</a>
        <a href="/app">App (Live)</a>
        <a href="/app-blue">App Blue (v1.0)</a>
        <a href="/app-green">App Green (v1.1)</a>
    </div>

Skript ausführen:

sudo python3 /usr/local/bin/cert-info.py


