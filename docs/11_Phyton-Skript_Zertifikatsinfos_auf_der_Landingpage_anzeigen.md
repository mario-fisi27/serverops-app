Im Original: Ein Python-Skript liest die Zertifikatsinformationen aus und schreibt sie automatisch auf die Landingpage. Das bleibt gleich.
Was wir machen: Ein Skript das die Ablaufdaten und Infos der SSL-Zertifikate ausliest und automatisch in die Landingpage einbaut. Per Cronjob wird das regelmäßig aktualisiert.
Kapitel 11.1 – Python-Skript erstellen
sudo nano /usr/local/bin/cert-info.py

Und darin möglichen Inhalt einfügen:
#!/usr/bin/env python3
import subprocess
import datetime
import os
import glob
import hashlib

cert_path = "/etc/httpd/ssl/server.crt"
ca_path = "/etc/httpd/ssl/ca.crt"
html_path = "/var/www/html/index.html"
webapps_dir = "/var/lib/tomcat/webapps"

def get_cert_info(path, name):
    result = subprocess.run(
        ["openssl", "x509", "-in", path, "-noout", "-subject", "-issuer", "-dates"],
        capture_output=True, text=True
    )
    lines = result.stdout.strip().split("\n")
    info = {"name": name}
    for line in lines:
        if line.startswith("subject="):
            info["subject"] = line.split("=", 1)[1].strip()
        elif line.startswith("issuer="):
            info["issuer"] = line.split("=", 1)[1].strip()
        elif line.startswith("notBefore="):
            info["von"] = line.split("=", 1)[1].strip()
        elif line.startswith("notAfter="):
            info["bis"] = line.split("=", 1)[1].strip()
    return info

def get_deployed_apps():
    apps = []
    for war in glob.glob(os.path.join(webapps_dir, "app-*.war")):
        name = os.path.basename(war).replace(".war", "").replace("app-", "")
        version_file = os.path.join(webapps_dir, f"app-{name}.version")
        if os.path.exists(version_file):
            with open(version_file) as f:
                version = f.read().strip()
        else:
            version = "?"
        apps.append({"name": name, "version": version})
    apps.sort(key=lambda x: [int(n) for n in x["version"].split(".") if n.isdigit()])
    return apps

# Bekannte Farben
known_colors = {
    "blue": "#1a73e8",
    "green": "#10b981",
    "orange": "#f97316",
    "red": "#dc2626",
    "purple": "#a855f7",
    "lila": "#a855f7",
    "yellow": "#eab308",
    "pink": "#ec4899",
    "cyan": "#06b6d4",
    "white": "#94a3b8",
    "black": "#1e293b",
    "gold": "#d97706",
}

# Zufällige aber einzigartige Farben für unbekannte Namen
random_colors = [
    "#ef4444", "#f97316", "#f59e0b", "#84cc16",
    "#22c55e", "#14b8a6", "#06b6d4", "#0ea5e9",
    "#3b82f6", "#6366f1", "#8b5cf6", "#a855f7",
    "#d946ef", "#ec4899", "#f43f5e", "#fb923c",
]

used_colors = []

def get_color(name):
    if name.lower() in known_colors:
        return known_colors[name.lower()]
    
    # Einzigartige Farbe basierend auf dem Namen generieren
    available = [c for c in random_colors if c not in used_colors]
    if not available:
        available = random_colors
    
    # Hash des Namens für konsistente Farbzuweisung
    index = int(hashlib.md5(name.encode()).hexdigest(), 16) % len(available)
    color = available[index]
    used_colors.append(color)
    return color

server = get_cert_info(cert_path, "Server-Zertifikat")
ca = get_cert_info(ca_path, "CA-Zertifikat")
timestamp = datetime.datetime.now().strftime("%d.%m.%Y %H:%M:%S")
apps = get_deployed_apps()

app_buttons = ""
for app in apps:
    color = get_color(app["name"])
    app_buttons += f'        <a href="/app-{app["name"]}" style="background:{color}">App {app["name"].capitalize()} (v{app["version"]})</a>\n'

html = f"""<!DOCTYPE html>
<html>
<head>
    <title>ServerOps - Azubi Webprojekt</title>
    <style>
        body {{ font-family: Arial, sans-serif; background: #1a1a2e; color: #eee; text-align: center; padding: 50px; }}
        h1 {{ color: #e94560; }}
        .links {{ margin-top: 30px; }}
        a {{ color: white; background: #e94560; padding: 12px 24px; text-decoration: none; border-radius: 5px; margin: 10px; display: inline-block; }}
        a:hover {{ opacity: 0.8; }}
        .info {{ margin-top: 40px; color: #aaa; font-size: 14px; }}
        table {{ margin: 20px auto; border-collapse: collapse; text-align: left; }}
        th {{ background: #e94560; color: white; padding: 10px 16px; }}
        td {{ padding: 8px 16px; border-bottom: 1px solid #333; }}
        h2 {{ color: #e94560; margin-top: 40px; }}
    </style>
</head>
<body>
    <h1>Azubi Webprojekt - ServerOps</h1>
    <p>Rocky Linux 9.4 | Apache | MariaDB | PHP</p>

    <h2>Webseiten</h2>
    <div class="links">
        <a href="/wordpress">WordPress</a>
        <a href="/phpmyadmin">phpMyAdmin</a>
        <a href="/testseite.html">Testseite</a>
    </div>

    <h2>App-Versionen ({len(apps)} deployt)</h2>
    <div class="links">
        <a href="/app" style="background:#e94560">App (Live)</a>
{app_buttons}    </div>

    <h2>Zertifikatsinfos</h2>
    <table>
        <tr><th>Zertifikat</th><th>Subject</th><th>Aussteller</th><th>Gueltig ab</th><th>Gueltig bis</th></tr>
        <tr><td>{server['name']}</td><td>{server.get('subject','')}</td><td>{server.get('issuer','')}</td><td>{server.get('von','')}</td><td>{server.get('bis','')}</td></tr>
        <tr><td>{ca['name']}</td><td>{ca.get('subject','')}</td><td>{ca.get('issuer','')}</td><td>{ca.get('von','')}</td><td>{ca.get('bis','')}</td></tr>
    </table>

    <div class="info">
        <p>Zuletzt aktualisiert: {timestamp}</p>
        <p>Erstellt von Mario - Fachinformatiker Systemintegration</p>
        <p>VW Group Services - Azubi Projekt 2026</p>
    </div>
</body>
</html>"""

with open(html_path, "w") as f:
    f.write(html)

print(f"Landingpage aktualisiert: {timestamp} - {len(apps)} Apps gefunden")

Speichern mit Strg + O -> Enter -> Strg + X


Ausführbar machen und testen:

sudo chmod +x /usr/local/bin/cert-info.py
sudo python3 /usr/local/bin/cert-info.py


Dann im Browser:

http://192.168.56.101

Da sollte die Landingpage jetzt mit einer Zertifikats-Tabelle erscheinen!
Kapitel 11.2 – Cronjob einrichten (automatische Aktualisierung)

sudo crontab -e

crontab = die Tabelle für geplante Aufgaben (wie Windows Aufgabenplanung)
-e = bearbeiten

Dann i drücken. Dadurch kann man dann folgende Zeile einfügen:

0 */6 * * * /usr/bin/python3 /usr/local/bin/cert-info.py

Sobald diese drinnen steht. ESC drücken und dann :wq rein schreiben und auf Enter drücken. Somit wird die Datei gespeichert und geschlossen.

Sieht dann wie folgt aus (im Code wurde noch einegfügt das man sehen kann Welche Webseiten bisher deployt wurden und diese kann man auch ansehen):
 
