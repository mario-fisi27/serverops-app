Kapitel 8.1 – Testseite erstellen
Folgenden Befehl eingeben um den HTML code für die Internetseite einzugeben:

sudo nano /var/www/html/testseite.html

Code: 
<!DOCTYPE html>
<html>
<head>
    <title>Testseite - Azubi Webprojekt</title>
</head>
<body>
    <h1>Testseite funktioniert!</h1>
    <p>Apache liefert diese Seite aus.</p>
    <p>Server: Rocky Linux 9.4</p>
    <p>Erstellt von: Mario - FiSi Azubi</p>
</body>
</html>

So könnte die für den ersten Test aussehen:
 


Speichern (Strg+O → Enter → Strg+X)

http://192.168.56.101/testseite.html damit dann die Testseite aufrufen

