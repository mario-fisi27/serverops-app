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

