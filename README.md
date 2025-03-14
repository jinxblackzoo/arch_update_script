# Arch Linux Update-Skript

## Übersicht

Dieses Skript automatisiert die Aktualisierung aller Paketmanager unter Arch Linux/Manjaro und bietet zusätzliche Funktionen zur GitHub-Integration und flexiblen Update-Steuerung. Es ist darauf ausgelegt, mit nur einer Passwort-Eingabe den gesamten Aktualisierungsprozess zu vereinfachen.

## Ablaufdiagramm

```
                             +------------------------+
                             |  Start Update-Skript   |
                             +------------------------+
                                        |
                                        v
                            +-------------------------+
                            | GitHub Repository       |
                            | konfigurieren?          |
                            +-------------------------+
                                 /             \
                                /               \
                               v                 v
            +------------------+                 +------------------+
            | Neues Repository |                 | Vorhandene       |
            | konfigurieren    |                 | Konfiguration    |
            +------------------+                 +------------------+
                      |                                   |
                      v                                   v
                      +----------------------------------+
                      |      Repository aktualisieren    |
                      +----------------------------------+
                                     |
                                     v
                            +-------------------------+
                            | Update-Modus auswählen? |
                            +-------------------------+
                                 /             \
                                /               \
                               v                 v
            +------------------+                 +------------------+
            | Schnellupdate    |                 | Vollständiges    |
            | ausgewählt       |                 | Update ausgewählt|
            +------------------+                 +------------------+
                      |                                   |
                      v                                   v
            +-------------------+            +------------------------+
            | Paketaktualisierung|           | 1. Systemvorbereitung  |
            | - pacman           |           |    - Schlüssel         |
            | - yay              |           |    - Mirrors           |
            | - flatpak          |           | 2. Paketaktualisierung |
            | - snap             |           | 3. Systembereinigung   |
            +-------------------+            +------------------------+
                      |                                   |
                      v                                   v
                      +----------------------------------+
                      |    Zusammenfassung und           |
                      |    Fehlerprotokollierung         |
                      +----------------------------------+
                                     |
                                     v
                            +------------------+
                            |       Ende       |
                            +------------------+
```

## Funktionen

- **Automatische Updates** für alle gängigen Paketmanager:
  - pacman (System-Pakete)
  - yay (AUR-Pakete)
  - flatpak (Container-Apps)
  - snap (Snap-Pakete, falls installiert)

- **Zwei Update-Modi**:
  - **Schnellupdate**: Nur Paketaktualisierungen (schneller, weniger gründlich)
  - **Vollständiges Update**: Inklusive Schlüssel, Mirrors und Systembereinigung

- **GitHub-Integration**:
  - Automatisches Update des Skripts aus einem konfigurierbaren GitHub-Repository
  - Interaktive Konfiguration neuer GitHub-Repositories
  - Speicherung der Repository-Konfiguration

- **Intelligente Paketprüfung**:
  - Automatische Installation fehlender Paketmanager (yay, flatpak, snap)
  - Fehlerbehandlung bei Installationsfehlern

- **Komfortfunktionen**:
  - Klare, farbige Statusmeldungen für bessere Übersichtlichkeit
  - Umfangreiche Protokollierung mit Zeitstempeln
  - Automatisches Entfernen überflüssiger Abhängigkeiten
  - Optimierung der Paket-Mirrors

- **Robuste Fehlerbehandlung**:
  - Ausführliche Fehlerprotokolle
  - Zusammenfassung aller aufgetretenen Fehler am Ende

## Installation

Das Skript kann auf verschiedene Weisen installiert werden:

### Methode 1: Ein-Klick Installation (empfohlen)

```bash
# Installation als Root (systemweit)
sudo mkdir -p /usr/local/bin && sudo cp /home/jinx/Dokumente/GitHub/arch_update_script/update.sh /usr/local/bin/update && sudo chmod +x /usr/local/bin/update && echo "Das Skript wurde als /usr/local/bin/update installiert und ist nun ausführbar!"
```

### Methode 2: Direkte Installation aus dem Internet (empfohlen)

```bash
# Systemweite Installation (erfordert Root-Rechte)
curl -sSL https://raw.githubusercontent.com/jinxblackzoo/arch_update_script/main/update.sh | sudo tee /usr/local/bin/update > /dev/null && sudo chmod +x /usr/local/bin/update && echo "Das Update-Skript wurde installiert und ist bereit zur Verwendung!"

# ODER: Installation im Home-Verzeichnis (ohne Root-Rechte)
mkdir -p ~/.local/bin && curl -sSL https://raw.githubusercontent.com/jinxblackzoo/arch_update_script/main/update.sh | tee ~/.local/bin/update > /dev/null && chmod +x ~/.local/bin/update && echo "Das Update-Skript wurde in ~/.local/bin/update installiert!"
```

### Methode 3: Manuelle Installation

```bash
# Verzeichnis erstellen
mkdir -p ~/.local/bin

# Skript in die Datei ~/.local/bin/update kopieren
# Dann ausführbar machen:
chmod +x ~/.local/bin/update

# Zur PATH-Variable hinzufügen (je nach Shell)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc  # oder ~/.bashrc
source ~/.zshrc  # oder ~/.bashrc
```

## Verwendung

Nach der Installation kannst du das Update-Skript einfach durch Eingabe des folgenden Befehls starten:

```bash
update
```

### Update-Modi

Das Skript bietet zwei verschiedene Update-Modi:

| Funktion                              | Schnellupdate | Vollständiges Update |
|---------------------------------------|:-------------:|:--------------------:|
| Paket-Updates (pacman, yay)           |       ✓       |          ✓           |
| Flatpak-Updates                       |       ✓       |          ✓           |
| Snap-Updates                          |       ✓       |          ✓           |
| Schlüssel-Aktualisierung              |       ✗       |          ✓           |
| Mirror-Aktualisierung                 |       ✗       |          ✓           |
| Paket-Cache-Bereinigung               |       ✗       |          ✓           |
| Entfernung ungenutzter Abhängigkeiten |       ✗       |          ✓           |

### GitHub-Repository-Konfiguration

Das Skript kann aus einem GitHub-Repository aktualisiert werden:

1. Bei der ersten Ausführung oder auf Wunsch kannst du ein neues Repository hinzufügen
2. Gib den Repository-Namen im Format `Benutzername/Repository` ein
3. Wähle den gewünschten Branch (Standard: main)
4. Gib den Namen des Update-Skripts im Repository an (Standard: update.sh)

Alle Einstellungen werden in `~/.local/share/update_script/config.json` gespeichert.

## Konfigurationsdatei

Die Konfigurationsdatei wird automatisch an folgendem Ort erstellt:
```
~/.local/share/update_script/config.json
```

Beispiel-Inhalt:
```json
{
  "github_repo_url": "https://github.com/benutzername/repository.git",
  "github_repo_branch": "main",
  "local_repo_path": "/home/benutzer/.local/share/update_script/benutzername_repository",
  "script_name": "update.sh"
}
```

## Logdateien und Fehlerprotokolle

Das Skript erstellt zwei Logdateien, die für Debugging und Nachverfolgung verwendet werden können:

### Update-Log
- **Pfad:** `~/update_log.txt`
- **Inhalt:** Protokolliert alle erfolgreichen Update-Vorgänge mit Zeitstempeln
- **Format:** `YYYY-MM-DD HH:MM:SS - Aktion - Erfolgreich`

### Fehlerprotokoll
- **Pfad:** `~/update_error_log.txt`
- **Inhalt:** Erfasst aufgetretene Fehler mit detaillierten Zeitstempeln
- **Format:** `YYYY-MM-DD HH:MM:SS - Aktion - Fehler`

Bei jedem Lauf des Skripts wird eine Zusammenfassung aller aufgetretenen Fehler am Ende angezeigt. Detailliertere Informationen findest du in den oben genannten Logdateien.

## Anforderungen

- Arch Linux oder Arch-basierte Distribution (z.B. Manjaro)
- Bash-Shell
- Optional: `git` für GitHub-Integration (wird automatisch installiert, falls nicht vorhanden)
- Optional: `jq` für bessere JSON-Verarbeitung (Fallback-Mechanismus vorhanden)

## Deinstallation

Wenn du das Skript entfernen möchtest, führe die folgenden Befehle aus:

```bash
# Skript entfernen
rm ~/.local/bin/update

# Konfigurationsdateien und heruntergeladene Repositories entfernen
rm -rf ~/.local/share/update_script

# Optional: Logdateien entfernen
rm ~/update_log.txt
rm ~/update_error_log.txt
```

Entferne außerdem die entsprechende `export PATH`-Zeile aus deiner `.zshrc` oder `.bashrc` Datei, wenn du diese nur für dieses Skript hinzugefügt hast.

## Fehlerbehebung

Sollten Probleme auftreten, prüfe folgende häufige Ursachen:

1. **Skript ist nicht ausführbar**: 
   ```bash
   chmod +x ~/.local/bin/update
   ```

2. **Skript ist nicht im PATH**:
   Stelle sicher, dass `~/.local/bin` in deiner PATH-Variable enthalten ist:
   ```bash
   echo $PATH
   ```
   Falls nicht, füge die entsprechende Zeile zu deiner Shell-Konfigurationsdatei hinzu.

3. **Fehler beim GitHub-Update**:
   Prüfe, ob git installiert ist:
   ```bash
   pacman -Q git
   ```
   Falls nicht, installiere es:
   ```bash
   sudo pacman -S git
   ```

4. **Fehler in den Logdateien überprüfen**:
   ```bash
   cat ~/update_error_log.txt
   ```

## Mitwirken

Verbesserungsvorschläge und Erweiterungen sind willkommen! Reiche einfach einen Pull Request ein oder eröffne ein Issue im GitHub-Repository.

## Lizenz

MIT Lizenz

Copyright (c) 2025 jinxblackzoo

Hiermit wird unentgeltlich jeder Person, die eine Kopie dieser Software und der zugehörigen Dokumentationen (die "Software") erhält, die Erlaubnis erteilt, sie uneingeschränkt zu nutzen, inklusive und ohne Ausnahme mit dem Recht, sie zu verwenden, zu kopieren, zu verändern, zusammenzuführen, zu veröffentlichen, zu verbreiten, unterzulizenzieren und/oder zu verkaufen, und Personen, denen diese Software überlassen wird, diese Rechte zu verschaffen, unter den folgenden Bedingungen:

Der obige Urheberrechtsvermerk und dieser Erlaubnisvermerk sind in allen Kopien oder Teilkopien der Software beizulegen.

DIE SOFTWARE WIRD OHNE JEDE AUSDRÜCKLICHE ODER IMPLIZIERTE GARANTIE BEREITGESTELLT, EINSCHLIESSLICH DER GARANTIE ZUR BENUTZUNG FÜR DEN VORGESEHENEN ODER EINEM BESTIMMTEN ZWECK SOWIE JEGLICHER RECHTSVERLETZUNG, JEDOCH NICHT DARAUF BESCHRÄNKT. IN KEINEM FALL SIND DIE AUTOREN ODER COPYRIGHTINHABER FÜR JEGLICHEN SCHADEN ODER SONSTIGE ANSPRÜCHE HAFTBAR ZU MACHEN, OB INFOLGE DER ERFÜLLUNG EINES VERTRAGES, EINES DELIKTES ODER ANDERS IM ZUSAMMENHANG MIT DER SOFTWARE ODER SONSTIGER VERWENDUNG DER SOFTWARE ENTSTANDEN.
