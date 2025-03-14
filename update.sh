#!/bin/bash

# ======================================================
#          Arch Linux Update-Skript
# ======================================================

# Konfigurationsbereich - Passe diese Werte an deine Bedürfnisse an
CONFIG_FILE="$HOME/.local/share/update_script/config.json"        # Konfigurationsdatei
UPDATE_MODE="full"                                                # Standard-Update-Modus (full/quick)

# Initialisiere die GitHub-Repository-Variablen als leer
# Diese werden später aus der Konfiguration geladen oder vom Benutzer abgefragt
GITHUB_REPO_URL=""
GITHUB_REPO_BRANCH=""
LOCAL_REPO_PATH=""
SCRIPT_NAME=""

# Funktion für farbige Ausgaben
print_colored() {
    local color=$1
    local text=$2
    
    case "$color" in
        "green") echo -e "\e[32m$text\e[0m" ;;
        "red") echo -e "\e[31m$text\e[0m" ;;
        "yellow") echo -e "\e[33m$text\e[0m" ;;
        "blue") echo -e "\e[34m$text\e[0m" ;;
        *) echo "$text" ;;
    esac
}

# Funktion für Statusmeldungen
print_status() {
    local operation=$1
    local result=$2
    
    printf "%-45s" "$operation"
    
    if [ "$result" = "success" ]; then
        print_colored "green" "[Erfolg]"
    elif [ "$result" = "warning" ]; then
        print_colored "yellow" "[Hinweis]"
    else
        print_colored "red" "[Fehler]"
    fi
}

# Funktion für formatierte Abschnitte
print_section() {
    local title=$1
    echo ""
    print_colored "blue" "=== $title ==="
    echo ""
}

# Funktion zur Fehlerprotokollierung
log_error() {
    local message=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> ~/update_error_log.txt
    ERROR_LOG+="$message\n"
}

# Funktion für Update-Logs
log_update() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> ~/update_log.txt
}

# Funktion zum Ausführen von Befehlen mit Fehlerbehandlung
run_command() {
    local command=$1
    local operation=$2
    local log_message=$3
    
    if eval "$command" &> /dev/null; then
        print_status "$operation" "success"
        log_update "$log_message - Erfolgreich"
        return 0
    else
        print_status "$operation" "error"
        log_error "$log_message - Fehler"
        return 1
    fi
}

# Funktion zur Überprüfung und Installation fehlender Pakete
check_and_install_packages() {
    print_section "Paketprüfung"
    
    # Prüfe und installiere yay
    if ! command -v yay &> /dev/null; then
        print_status "Prüfung auf yay-Installation..." "warning"
        echo " [Wird installiert]"
        
        if ! command -v git &> /dev/null; then
            run_command "sudo pacman -S --noconfirm git" "Git wird installiert..." "Git-Installation"
        fi
        
        echo "Installiere yay..."
        
        local temp_dir=$(mktemp -d)
        cd "$temp_dir" || return 1
        
        if git clone https://aur.archlinux.org/yay.git &> /dev/null && \
           cd yay && makepkg -si --noconfirm &> /dev/null; then
            print_status "yay wurde installiert..." "success"
            log_update "yay wurde erfolgreich installiert"
        else
            print_status "yay konnte nicht installiert werden..." "error"
            log_error "yay-Installation fehlgeschlagen"
        fi
        
        cd "$HOME" || return 1
        rm -rf "$temp_dir"
    else
        print_status "Prüfung auf yay-Installation..." "success"
    fi
    
    # Prüfe und installiere flatpak
    if ! command -v flatpak &> /dev/null; then
        print_status "Prüfung auf flatpak-Installation..." "warning"
        echo " [Wird installiert]"
        run_command "sudo pacman -S --noconfirm flatpak" "Flatpak wird installiert..." "Flatpak-Installation"
        
        # Flathub hinzufügen
        run_command "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo" "Flathub-Repository wird hinzugefügt..." "Flathub-Hinzufügung"
    else
        print_status "Prüfung auf flatpak-Installation..." "success"
    fi
    
    # Prüfe und installiere snap
    if ! command -v snap &> /dev/null; then
        print_status "Prüfung auf snap-Installation..." "warning"
        echo " [Wird installiert]"
        
        # snapd aus AUR installieren
        if command -v yay &> /dev/null; then
            run_command "yay -S --noconfirm snapd" "Snap wird installiert..." "Snap-Installation"
            run_command "sudo systemctl enable --now snapd.socket" "Snap-Dienst wird aktiviert..." "Snap-Dienst-Aktivierung"
            
            # Symbolischen Link für snap erstellen
            run_command "sudo ln -sf /var/lib/snapd/snap /snap" "Snap-Symlink wird erstellt..." "Snap-Symlink-Erstellung"
        else
            print_status "Snap kann nicht installiert werden..." "error"
            log_error "Snap-Installation fehlgeschlagen - yay ist erforderlich"
        fi
    else
        print_status "Prüfung auf snap-Installation..." "success"
    fi
}

# Funktion zum Abfragen des Update-Modus
ask_for_update_mode() {
    print_section "Update-Modus Auswahl"
    
    print_colored "yellow" "Welche Art von Update möchten Sie durchführen?"
    echo "1) Schnellupdate (nur Paketaktualisierungen, schneller)"
    echo "2) Vollständiges Update (inkl. Mirrors, Schlüssel und Systembereinigung, gründlicher)"
    print_colored "yellow" "Bitte wählen Sie [1/2] (Standard: 2):"
    read -r mode_choice
    
    case "$mode_choice" in
        1)
            UPDATE_MODE="quick"
            print_colored "blue" "Schnellupdate wurde ausgewählt."
            log_update "Schnellupdate-Modus ausgewählt"
            ;;
        2|"")
            UPDATE_MODE="full"
            print_colored "blue" "Vollständiges Update wurde ausgewählt."
            log_update "Vollständiges Update-Modus ausgewählt"
            ;;
        *)
            print_colored "yellow" "Ungültige Eingabe, verwende Standardeinstellung (Vollständiges Update)."
            UPDATE_MODE="full"
            log_update "Vollständiges Update-Modus ausgewählt (Standard)"
            ;;
    esac
}

# Funktion zum Abfragen von GitHub-Repository-Informationen
ask_for_github_repo() {
    print_section "GitHub-Repository Konfiguration"
    
    # Prüfe, ob bereits eine Konfiguration existiert
    if [ -f "$CONFIG_FILE" ]; then
        # Lade die Konfiguration
        if command -v jq &> /dev/null; then
            GITHUB_REPO_URL=$(jq -r '.github_repo_url' "$CONFIG_FILE")
            GITHUB_REPO_BRANCH=$(jq -r '.github_repo_branch' "$CONFIG_FILE")
            LOCAL_REPO_PATH=$(jq -r '.local_repo_path' "$CONFIG_FILE")
            SCRIPT_NAME=$(jq -r '.script_name' "$CONFIG_FILE")
        else
            # Primitive Parsing ohne jq
            GITHUB_REPO_URL=$(grep -o '"github_repo_url": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
            GITHUB_REPO_BRANCH=$(grep -o '"github_repo_branch": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
            LOCAL_REPO_PATH=$(grep -o '"local_repo_path": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
            SCRIPT_NAME=$(grep -o '"script_name": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
        fi
        
        # Prüfe, ob gültige Werte in der Konfiguration gefunden wurden
        if [ -n "$GITHUB_REPO_URL" ]; then
            print_colored "blue" "Vorhandene GitHub-Konfiguration gefunden:"
            print_colored "blue" "Repository: $GITHUB_REPO_URL"
            print_colored "blue" "Branch: $GITHUB_REPO_BRANCH"
            
            # Frage, ob der Benutzer ein neues Repository konfigurieren möchte
            print_colored "yellow" "Möchten Sie ein neues GitHub-Repository konfigurieren? (j/n)"
            read -r answer
            
            if [[ ! "$answer" =~ [jJ] ]]; then
                print_colored "blue" "Die bestehende Konfiguration wird verwendet."
                
                # Aktualisiere das Repository, falls es existiert
                if [ -n "$GITHUB_REPO_URL" ]; then
                    update_from_github
                fi
                return 0
            fi
        fi
    fi
    
    # Neues Repository konfigurieren
    # GitHub Repository-Name abfragen
    print_colored "yellow" "Bitte geben Sie den GitHub-Repository-Namen ein (Benutzername/Repository):"
    read -r github_repo_name
    
    if [ -z "$github_repo_name" ]; then
        print_colored "yellow" "Kein Repository-Name angegeben. Die GitHub-Integration wird übersprungen."
        GITHUB_REPO_URL=""
        GITHUB_REPO_BRANCH=""
        LOCAL_REPO_PATH=""
        SCRIPT_NAME=""
        return 0
    fi
    
    # Repository-URL erstellen
    GITHUB_REPO_URL="https://github.com/$github_repo_name.git"
    
    # Branch abfragen
    print_colored "yellow" "Bitte geben Sie den Branch-Namen ein (Standard: main):"
    read -r branch_name
    if [ -z "$branch_name" ]; then
        GITHUB_REPO_BRANCH="main"
    else
        GITHUB_REPO_BRANCH="$branch_name"
    fi
    
    # Skript-Name abfragen
    print_colored "yellow" "Bitte geben Sie den Namen des Update-Skripts im Repository ein (Standard: update.sh):"
    read -r script_name
    if [ -z "$script_name" ]; then
        SCRIPT_NAME="update.sh"
    else
        SCRIPT_NAME="$script_name"
    fi
    
    # Lokalen Pfad bestimmen
    repo_dir=$(echo "$github_repo_name" | sed 's/\//_/g')
    LOCAL_REPO_PATH="$HOME/.local/share/update_script/$repo_dir"
    
    # Konfiguration speichern
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo "{
  \"github_repo_url\": \"$GITHUB_REPO_URL\",
  \"github_repo_branch\": \"$GITHUB_REPO_BRANCH\",
  \"local_repo_path\": \"$LOCAL_REPO_PATH\",
  \"script_name\": \"$SCRIPT_NAME\"
}" > "$CONFIG_FILE"
    
    print_colored "green" "GitHub-Repository wurde konfiguriert: $GITHUB_REPO_URL"
    
    # Aktualisiere das GitHub Repository
    if [ -n "$GITHUB_REPO_URL" ]; then
        update_from_github
    fi
}

# Funktion für GitHub-Repository-Updates
update_from_github() {
    print_section "GitHub-Update"
    
    # Prüfe, ob git installiert ist
    if ! command -v git &> /dev/null; then
        print_status "Prüfung auf git-Installation..." "error"
        log_error "GitHub-Update fehlgeschlagen - git ist nicht installiert"
        print_colored "yellow" "Installiere git mit: sudo pacman -S git"
        return 1
    fi
    
    # Erstelle Verzeichnisstruktur, falls nicht vorhanden
    mkdir -p "$LOCAL_REPO_PATH"
    
    # Prüfe, ob das Repository bereits geklont wurde
    if [ -d "$LOCAL_REPO_PATH/.git" ]; then
        # Repository existiert bereits, führe pull durch
        cd "$LOCAL_REPO_PATH" || return 1
        print_status "GitHub-Repository wird aktualisiert..." ""
        
        # Speichere den aktuellen Commit-Hash
        local old_hash=$(git rev-parse HEAD 2>/dev/null)
        
        # Führe git pull aus
        if git pull origin "$GITHUB_REPO_BRANCH" &> /dev/null; then
            local new_hash=$(git rev-parse HEAD)
            
            if [ "$old_hash" = "$new_hash" ]; then
                print_status "GitHub-Repository wird aktualisiert..." "warning"
                echo " [Bereits aktuell]"
                log_update "GitHub-Repository ist bereits aktuell"
            else
                print_status "GitHub-Repository wird aktualisiert..." "success"
                log_update "GitHub-Repository aktualisiert von $old_hash auf $new_hash"
                
                # Update das Skript, wenn vorhanden
                update_script_from_repo
            fi
        else
            print_status "GitHub-Repository wird aktualisiert..." "error"
            log_error "GitHub-Repository Update fehlgeschlagen"
            return 1
        fi
    else
        # Repository muss geklont werden
        print_status "GitHub-Repository wird geklont..." ""
        
        if git clone --branch "$GITHUB_REPO_BRANCH" "$GITHUB_REPO_URL" "$LOCAL_REPO_PATH" &> /dev/null; then
            print_status "GitHub-Repository wird geklont..." "success"
            log_update "GitHub-Repository erfolgreich geklont"
            
            # Update das Skript nach dem Klonen
            cd "$LOCAL_REPO_PATH" || return 1
            update_script_from_repo
        else
            print_status "GitHub-Repository wird geklont..." "error"
            log_error "GitHub-Repository konnte nicht geklont werden"
            return 1
        fi
    fi
}

# Funktion zum Aktualisieren des Skripts aus dem Repository
update_script_from_repo() {
    if [ -f "$SCRIPT_NAME" ]; then
        # Kopiere das aktualisierte Skript
        if cp "$SCRIPT_NAME" "$HOME/.local/bin/update" && chmod +x "$HOME/.local/bin/update"; then
            print_status "Update-Skript wird aktualisiert..." "success"
            log_update "Update-Skript wurde aus GitHub-Repository aktualisiert"
            
            print_colored "yellow" "Das Skript wurde aktualisiert. Führe es erneut aus, um die neuen Funktionen zu nutzen."
            print_colored "yellow" "Befehl: update"
        else
            print_status "Update-Skript wird aktualisiert..." "error"
            log_error "Konnte Update-Skript nicht aktualisieren"
        fi
    else
        print_status "Update-Skript im Repository suchen..." "warning"
        echo " [Skript '$SCRIPT_NAME' nicht im Repository gefunden]"
        log_error "Update-Skript '$SCRIPT_NAME' nicht im Repository gefunden"
    fi
}

# Funktion für Paket-Updates
perform_package_updates() {
    print_section "Paket-Updates"
    
    # Pacman-Update
    run_command "sudo pacman -Syu --noconfirm" "Pacman wird aktualisiert..." "Pacman-Update"
    
    # Yay-Update (falls vorhanden)
    if command -v yay &> /dev/null; then
        run_command "yay -Syu --noconfirm" "Yay (AUR) wird aktualisiert..." "Yay-Update"
    fi
    
    # Snap-Update (falls vorhanden)
    if command -v snap &> /dev/null; then
        run_command "sudo snap refresh" "Snap wird aktualisiert..." "Snap-Update"
    fi
    
    # Flatpak-Update (falls vorhanden)
    if command -v flatpak &> /dev/null; then
        run_command "flatpak update -y" "Flatpak wird aktualisiert..." "Flatpak-Update"
    fi
}

# Funktion für System-Vorbereitung (nur bei vollständigem Update)
perform_system_preparation() {
    print_section "System-Vorbereitung"
    run_command "sudo pacman-key --refresh-keys" "Schlüssel werden aktualisiert..." "Schlüsselaktualisierung"
    run_command "sudo pacman-mirrors --fasttrack" "Mirrors werden aktualisiert..." "Mirror-Aktualisierung"
}

# Funktion für Systembereinigung (nur bei vollständigem Update)
perform_system_cleanup() {
    print_section "System-Bereinigung"
    
    # Cache-Bereinigung
    if command -v yay &> /dev/null; then
        run_command "yay -Sc --noconfirm" "Paket-Cache wird bereinigt..." "Cache-Bereinigung"
    else
        run_command "sudo pacman -Sc --noconfirm" "Paket-Cache wird bereinigt..." "Cache-Bereinigung"
    fi
    
    # Nicht mehr benötigte Abhängigkeiten entfernen
    orphans=$(pacman -Qtdq 2>/dev/null)
    if [ -n "$orphans" ]; then
        run_command "sudo pacman -Rns $(pacman -Qtdq) --noconfirm" "Nicht benötigte Abhängigkeiten werden entfernt..." "Abhängigkeiten-Bereinigung"
    else
        print_status "Nicht benötigte Abhängigkeiten werden gesucht..." "warning"
        echo " [Keine zu entfernenden Abhängigkeiten gefunden]"
    fi
}

# Hauptprogramm
main() {
    # Initialisierungen
    ERROR_LOG=""
    USER_NAME=$(whoami)
    CURRENT_SHELL=$(basename "$SHELL")
    LOG_DIR="$HOME/.local/share/update_script"
    mkdir -p "$LOG_DIR"
    
    # Begrüßung
    clear
    print_colored "blue" "======================================"
    print_colored "blue" "  Hallo $USER_NAME, dein Update beginnt jetzt..."
    print_colored "blue" "======================================"
    echo "Aktuelle Shell: $CURRENT_SHELL"
    echo ""
    print_colored "yellow" "Bitte habe etwas Geduld, während die Updates durchgeführt werden."
    print_colored "yellow" "Du wirst über Fortschritt und eventuelle Probleme informiert."
    
    # Sudo-Passwort abfragen
    sudo -v
    
    # Prüfe und installiere benötigte Pakete
    check_and_install_packages
    
    # GitHub-Repository konfigurieren oder aktualisieren
    ask_for_github_repo
    
    # Update-Modus abfragen
    ask_for_update_mode
    
    # Je nach Update-Modus verschiedene Schritte ausführen
    if [ "$UPDATE_MODE" = "full" ]; then
        # Vollständiges Update
        
        # Schlüssel und Mirrors aktualisieren
        perform_system_preparation
    
        # Pakete aktualisieren
        perform_package_updates
    
        # System aufräumen
        perform_system_cleanup
    else
        # Schnellupdate - nur Pakete aktualisieren
        print_colored "yellow" "Schnellupdate wird durchgeführt (ohne Mirror-Update, Schlüssel-Update und Systembereinigung)."
        perform_package_updates
    fi
    
    # Abschlussmeldung und Fehlerausgabe
    print_section "Zusammenfassung"
    
    # Gesamtlogbuch-Eintrag
    if [ "$UPDATE_MODE" = "full" ]; then
        log_update "Vollständiges System-Update abgeschlossen"
    else
        log_update "Schnellupdate abgeschlossen"
    fi
    
    # Fehler ausgeben, falls vorhanden
    if [ -n "$ERROR_LOG" ]; then
        print_colored "red" "Während des Updates sind Fehler aufgetreten:"
        echo -e "$ERROR_LOG"
        print_colored "yellow" "Detaillierte Fehlerprotokolle findest du in ~/update_error_log.txt"
    else
        print_colored "green" "Alle Schritte wurden erfolgreich abgeschlossen!"
    fi
    
    print_colored "blue" "======================================"
    print_colored "green" "  Update-Vorgang abgeschlossen!"
    if [ "$UPDATE_MODE" = "quick" ]; then
        print_colored "yellow" "  (Schnellupdate-Modus)"
    fi
    print_colored "blue" "  Logbucheintrag gespeichert in ~/update_log.txt"
    print_colored "blue" "======================================"
}

# Skript ausführen
main
