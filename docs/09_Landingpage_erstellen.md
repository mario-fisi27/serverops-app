Kapitel 9 – Landingpage erstellen
In Windows Powershell mit dem Benutzernamen und der IP-Adresse der VM also 192.168.56.101 verbinden um den Code leichter einzufügen mit Strg + v:
Befehel = ssh mario@192.168.56.101 in meinem Fall.

sudo nano /var/www/html/index.html   

mit dem Befehl die Landing page aufrufen und neuen Code einfügen.

Code: 
<!DOCTYPE html>
<html>
<head>
    <title>ServerOps - Azubi Webprojekt</title>
    <style>
        body { font-family: Arial, sans-serif; background: #1a1a2e; color: #eee; text-align: center; padding: 50px; }
        h1 { color: #e94560; }
        .links { margin-top: 30px; }
        a { color: #0f3460; background: #e94560; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin: 10px; display: inline-block; }
        a:hover { background: #c73650; }
        .info { margin-top: 40px; color: #aaa; font-size: 14px; }
    </style>
</head>
<body>
    <h1>Azubi Webprojekt - ServerOps</h1>
    <p>Rocky Linux 9.4 | Apache | MariaDB | PHP</p>
    <div class="links">
        <a href="/wordpress">WordPress</a>
        <a href="/phpmyadmin">phpMyAdmin</a>
        <a href="/testseite.html">Testseite</a>
    </div>
    <div class="info">
        <p>Erstellt von Mario - Fachinformatiker Systemintegration</p>
        <p>VW Group Services - Azubi Projekt 2026</p>
    </div>
</body>
</html>

Speichern (Strg+O → Enter → Strg+X)

Dann im Browser öffnen mit: http://192.168.56.101








Könnte wie folgt aussehen:
 
