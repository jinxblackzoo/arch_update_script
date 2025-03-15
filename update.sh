#!/usr/bin/env sh

# ======================================================
#          Arch Linux Update-Skript
# ======================================================
# Kompatibel mit bash, zsh und anderen POSIX-kompatiblen Shells

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
        "green") printf "\033[32m%s\033[0m" "$text" ;;
        "red") printf "\033[31m%s\033[0m" "$text" ;;
        "yellow") printf "\033[33m%s\033[0m" "$text" ;;
        "blue") printf "\033[34m%s\033[0m" "$text" ;;
        *) printf "%s" "$text" ;;
    esac
}

# Funktion für Statusmeldungen
print_status() {
    local operation=$1
    local result=$2
    
    printf "%-45s" "$operation"
    
    if [ "$result" = "success" ]; then
        print_colored "green" "[Erfolg]"
        printf "\n"
    elif [ "$result" = "warning" ]; then
        print_colored "yellow" "[Hinweis]"
        printf "\n"
    else
        print_colored "red" "[Fehler]"
        printf "\n"
    fi
}

# Funktion für formatierte Abschnitte
print_section() {
    local title=$1
    printf "\n"
    print_colored "blue" "=== $title ==="
    printf "\n\n"
}

# Funktion zur Fehlerprotokollierung
log_error() {
    local message=$1
    printf "%s - %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$message" >> ~/update_error_log.txt
    ERROR_LOG="${ERROR_LOG}${message}\n"
}

# Funktion für Update-Logs
log_update() {
    printf "%s - %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> ~/update_log.txt
}

# Funktion zum Ausführen von Befehlen mit Fehlerbehandlung
run_command() {
    local command=$1
    local operation=$2
    local log_message=$3
    
    if eval "$command" > /dev/null 2>&1; then
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
    printf "\n1) Schnellupdate (nur Paketaktualisierungen, schneller)\n"
    printf "2) Vollständiges Update (inkl. Mirrors, Schlüssel und Systembereinigung, gründlicher)\n"
    print_colored "yellow" "Bitte wählen Sie [1/2] (Standard: 2):"
    printf "\n"
    read -r mode_choice
    
    case "$mode_choice" in
        1)
            UPDATE_MODE="quick"
            print_colored "blue" "Schnellupdate wurde ausgewählt."
            printf "\n"
            log_update "Schnellupdate-Modus ausgewählt"
            ;;
        2|"")
            UPDATE_MODE="full"
            print_colored "blue" "Vollständiges Update wurde ausgewählt."
            printf "\n"
            log_update "Vollständiges Update-Modus ausgewählt"
            ;;
        *)
            print_colored "yellow" "Ungültige Eingabe, verwende Standardeinstellung (Vollständiges Update)."
            printf "\n"
            UPDATE_MODE="full"
            log_update "Vollständiges Update-Modus ausgewählt (Standard)"
            ;;
    esac
}

# Funktion zur GitHub-Abfrage und Repository-Konfiguration
ask_for_github_repo() {
    print_section "GitHub-Integration"
    
    print_colored "yellow" "Möchten Sie ein GitHub-Repository hinzufügen? (j/n)"
    printf "\n"
    read -r github_choice
    
    if [ "$github_choice" = "j" ] || [ "$github_choice" = "J" ]; then
        # Standard GitHub-Account
        DEFAULT_GITHUB_USER="jinxblackzoo"
        
        # Konfigurationsverzeichnis erstellen, falls es nicht existiert
        mkdir -p "$(dirname "$CONFIG_FILE")"
        
        # Abfrage der Repository-Informationen
        print_colored "yellow" "Bitte geben Sie die GitHub-Repository-URL ein (Format: benutzername/repo):"
        printf "\nBeispiel: %s/repo\n" "$DEFAULT_GITHUB_USER"
        read -r repo_input
        
        # Standardwerte verwenden, wenn keine Eingabe erfolgt
        if [ -z "$repo_input" ]; then
            repo_input="$DEFAULT_GITHUB_USER/arch_update_script"
            print_colored "blue" "Keine Eingabe erkannt. Verwende Standardwert: $repo_input"
            printf "\n"
        fi
        
        # Prüfen, ob die Eingabe das richtige Format hat
        if printf "%s" "$repo_input" | grep -qE '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$'; then
            # Repository-Informationen extrahieren
            repo_parts=$(printf "%s" "$repo_input" | tr '/' ' ')
            repo_user=$(printf "%s" "$repo_parts" | awk '{print $1}')
            repo_name=$(printf "%s" "$repo_parts" | awk '{print $2}')
            
            # Repository-URL
            GITHUB_REPO_URL="https://github.com/$repo_user/$repo_name.git"
            
            # Branch abfragen (mit Standard "main")
            print_colored "yellow" "Bitte geben Sie den Branch ein (Standard: main):"
            printf "\n"
            read -r branch_input
            
            if [ -z "$branch_input" ]; then
                GITHUB_REPO_BRANCH="main"
                print_colored "blue" "Kein Branch angegeben. Verwende Standard: main"
                printf "\n"
            else
                GITHUB_REPO_BRANCH="$branch_input"
            fi
            
            # Skript-Name abfragen (mit Standard "update.sh")
            print_colored "yellow" "Bitte geben Sie den Namen des Update-Skripts im Repository an (Standard: update.sh):"
            printf "\n"
            read -r script_input
            
            if [ -z "$script_input" ]; then
                SCRIPT_NAME="update.sh"
                print_colored "blue" "Kein Skript-Name angegeben. Verwende Standard: update.sh"
                printf "\n"
            else
                SCRIPT_NAME="$script_input"
            fi
            
            # Lokalen Pfad für das Repository festlegen
            repo_dir="${repo_user}_${repo_name}"
            LOCAL_REPO_PATH="$HOME/.local/share/update_script/$repo_dir"
            
            # Konfiguration in JSON-Datei speichern
            if command -v jq > /dev/null 2>&1; then
                # Verwende jq, falls verfügbar
                printf '{"github_repo_url": "%s", "github_repo_branch": "%s", "local_repo_path": "%s", "script_name": "%s"}' \
                       "$GITHUB_REPO_URL" "$GITHUB_REPO_BRANCH" "$LOCAL_REPO_PATH" "$SCRIPT_NAME" | \
                       jq '.' > "$CONFIG_FILE"
                print_status "GitHub-Repository-Konfiguration gespeichert" "success"
            else
                # Fallback ohne jq
                printf '{\n  "github_repo_url": "%s",\n  "github_repo_branch": "%s",\n  "local_repo_path": "%s",\n  "script_name": "%s"\n}' \
                       "$GITHUB_REPO_URL" "$GITHUB_REPO_BRANCH" "$LOCAL_REPO_PATH" "$SCRIPT_NAME" > "$CONFIG_FILE"
                print_status "GitHub-Repository-Konfiguration gespeichert (ohne jq)" "success"
            fi
            
            # Repository aktualisieren
            update_from_github
            
            # Aktualisiere das Skript, falls eine neue Version im Repository verfügbar ist
            if [ -f "$LOCAL_REPO_PATH/$SCRIPT_NAME" ]; then
                local_hash=$(md5sum "$0" | cut -d' ' -f1)
                repo_hash=$(md5sum "$LOCAL_REPO_PATH/$SCRIPT_NAME" | cut -d' ' -f1)
                
                if [ "$local_hash" != "$repo_hash" ]; then
                    print_colored "yellow" "Eine neue Version des Skripts wurde gefunden."
                    printf "\n"
                    print_colored "yellow" "Möchten Sie das Skript aktualisieren? (j/n)"
                    printf "\n"
                    read -r update_script
                    
                    if [ "$update_script" = "j" ] || [ "$update_script" = "J" ]; then
                        update_script_from_repo
                        # Das Skript wird neu gestartet, wenn es aktualisiert wurde
                    fi
                fi
            fi
        else
            print_colored "red" "Ungültiges Repository-Format. Verwende Format: benutzername/repo"
            printf "\n"
        fi
    else
        print_colored "blue" "GitHub-Integration übersprungen."
        printf "\n"
    fi
}

# Funktion für GitHub-Repository-Updates
update_from_github() {
    # Prüfe, ob Git installiert ist
    if ! command -v git > /dev/null 2>&1; then
        print_status "Git ist nicht installiert. Installiere Git..." "warning"
        
        if ! command -v git &> /dev/null; then
            run_command "sudo pacman -S --noconfirm git" "Git wird installiert..." "Git-Installation"
        fi
        
        echo "Installiere Git..."
        
        if ! run_command "sudo pacman -S --noconfirm git" "Git wird installiert..." "Git-Installation"; then
            return 1
        fi
    fi
    
    # Prüfe, ob jq installiert ist (für JSON-Parsing)
    if ! command -v jq > /dev/null 2>&1; then
        print_status "jq ist nicht installiert. Installiere jq..." "warning"
        
        if ! run_command "sudo pacman -S --noconfirm jq" "jq wird installiert..." "jq-Installation"; then
            # Fehlschlag von jq ist nicht kritisch
            print_colored "yellow" "jq konnte nicht installiert werden. Die Skriptfunktionalität ist eingeschränkt."
            printf "\n"
        fi
    fi
    
    # Prüfe, ob die GitHub-Konfiguration existiert
    if [ -z "$GITHUB_REPO_URL" ] || [ -z "$GITHUB_REPO_BRANCH" ] || [ -z "$LOCAL_REPO_PATH" ]; then
        print_status "GitHub-Konfiguration fehlt oder ist unvollständig." "error"
        ask_for_github_repo
    fi
    
    print_section "GitHub-Repository Update"
    
    # Prüfe, ob das Repository bereits geklont wurde
    if [ -d "$LOCAL_REPO_PATH/.git" ]; then
        print_status "Repository wird aktualisiert..." "warning"
        
        if cd "$LOCAL_REPO_PATH" > /dev/null 2>&1; then
            if git pull origin "$GITHUB_REPO_BRANCH" > /dev/null 2>&1; then
                print_status "Repository wurde aktualisiert." "success"
                log_update "GitHub-Repository wurde aktualisiert"
                return 0
            else
                print_status "Fehler beim Aktualisieren des Repositories." "error"
                log_error "Fehler beim Aktualisieren des GitHub-Repositories"
                return 1
            fi
        else
            print_status "Konnte nicht in das Repository-Verzeichnis wechseln." "error"
            log_error "Konnte nicht in das Repository-Verzeichnis wechseln"
            return 1
        fi
    else
        print_status "Repository wird geklont..." "warning"
        
        # Erstelle das Verzeichnis, falls es nicht existiert
        mkdir -p "$LOCAL_REPO_PATH" > /dev/null 2>&1
        
        if git clone -b "$GITHUB_REPO_BRANCH" "$GITHUB_REPO_URL" "$LOCAL_REPO_PATH" > /dev/null 2>&1; then
            print_status "Repository wurde geklont." "success"
            log_update "GitHub-Repository wurde geklont"
            return 0
        else
            print_status "Fehler beim Klonen des Repositories." "error"
            log_error "Fehler beim Klonen des GitHub-Repositories"
            return 1
        fi
    fi
}

# Funktion zum Aktualisieren des Skripts aus dem Repository
update_script_from_repo() {
    print_section "Skript-Update"
    
    # Prüfe, ob das Repository existiert
    if [ ! -d "$LOCAL_REPO_PATH" ]; then
        print_status "Repository-Verzeichnis existiert nicht." "error"
        log_error "Repository-Verzeichnis existiert nicht"
        return 1
    fi
    
    # Prüfe, ob das Skript im Repository existiert
    if [ ! -f "$LOCAL_REPO_PATH/$SCRIPT_NAME" ]; then
        print_status "Skript '$SCRIPT_NAME' nicht im Repository gefunden." "error"
        log_error "Skript '$SCRIPT_NAME' nicht im Repository gefunden"
        return 1
    fi
    
    # Kopiere das Skript in das aktuelle Verzeichnis
    if cp "$LOCAL_REPO_PATH/$SCRIPT_NAME" "$0" > /dev/null 2>&1; then
        print_status "Skript wurde aktualisiert." "success"
        log_update "Skript wurde aus dem Repository aktualisiert"
        
        # Setze Ausführungsrechte
        chmod +x "$0" > /dev/null 2>&1
        
        print_colored "yellow" "Das Skript wurde aktualisiert und wird neu gestartet."
        printf "\n"
        
        # Starte das Skript neu
        exec "$0"
    else
        print_status "Fehler beim Aktualisieren des Skripts." "error"
        log_error "Fehler beim Aktualisieren des Skripts aus dem Repository"
        return 1
    fi
}

# Funktion für Paket-Updates
perform_package_updates() {
    print_section "Paket-Updates"
    
    # Systemaktualisierung
    print_colored "blue" "Führe Systemaktualisierung durch..."
    printf "\n"
    
    # Arch/Pacman-Updates
    run_command "sudo pacman -Syu --noconfirm" "Pacman-Updates werden installiert..." "Pacman-Updates"
    
    # Yay/AUR-Updates (falls vorhanden)
    if command -v yay > /dev/null 2>&1; then
        run_command "yay -Syu --noconfirm" "AUR-Updates werden installiert..." "AUR-Updates"
    fi
    
    # Flatpak-Updates (falls vorhanden)
    if command -v flatpak > /dev/null 2>&1; then
        run_command "flatpak update -y" "Flatpak-Updates werden installiert..." "Flatpak-Updates"
    fi
    
    # Snap-Updates (falls vorhanden)
    if command -v snap > /dev/null 2>&1; then
        run_command "sudo snap refresh" "Snap-Updates werden installiert..." "Snap-Updates"
    fi
}

# Funktion für System-Vorbereitung (nur bei vollständigem Update)
perform_system_preparation() {
    print_section "System-Vorbereitung"
    
    run_command "sudo pacman-mirrors -f 5" "Pacman-Mirrors werden aktualisiert..." "Pacman-Mirrors-Aktualisierung"
    run_command "sudo pacman -Syy" "Paketdatenbank wird aktualisiert..." "Paketdatenbank-Aktualisierung"
    run_command "sudo pacman-key --populate archlinux" "Schlüssel werden aktualisiert..." "Pacman-Schlüssel-Aktualisierung"
}

# Funktion für Systembereinigung (nur bei vollständigem Update)
perform_system_cleanup() {
    print_section "Systembereinigung"
    
    # Pacman-Cache bereinigen
    run_command "sudo pacman -Sc --noconfirm" "Pacman-Cache wird bereinigt..." "Pacman-Cache-Bereinigung"
    
    # Verwaiste Pakete entfernen
    print_status "Verwaiste Pakete werden gesucht..." "warning"
    
    orphans=$(pacman -Qtdq)
    if [ -n "$orphans" ]; then
        if printf "%s" "$orphans" | sudo pacman -Rns - > /dev/null 2>&1; then
            print_status "Verwaiste Pakete wurden entfernt." "success"
            log_update "Verwaiste Pakete wurden entfernt"
        else
            print_status "Fehler beim Entfernen verwaister Pakete." "error"
            log_error "Fehler beim Entfernen verwaister Pakete"
        fi
    else
        print_status "Keine verwaisten Pakete gefunden." "success"
    fi
    
    # Temporäre Dateien bereinigen
    run_command "sudo rm -rf /tmp/*" "Temporäre Dateien werden bereinigt..." "Temporäre Dateien-Bereinigung"
    
    # Journal bereinigen (behalte nur die letzten 7 Tage)
    run_command "sudo journalctl --vacuum-time=7d" "Journal wird bereinigt..." "Journal-Bereinigung"
}

# Funktion zum Überprüfen von Root-Rechten
check_sudo() {
    print_section "Root-Rechte Überprüfung"
    
    print_colored "yellow" "Dieses Skript benötigt Root-Rechte für verschiedene Operationen."
    printf "\nBitte geben Sie Ihr Passwort ein, wenn Sie dazu aufgefordert werden.\n"
    
    # Sudo-Befehl testen, um die Rechte zu aktivieren
    if sudo -v; then
        print_status "Root-Rechte erhalten" "success"
        log_update "Root-Rechte wurden erfolgreich aktiviert"
        return 0
    else
        print_status "Root-Rechte konnten nicht erhalten werden" "error"
        log_error "Fehler beim Erhalten von Root-Rechten"
        printf "\n"
        print_colored "red" "Ohne Root-Rechte können wichtige Update-Funktionen nicht ausgeführt werden."
        printf "\nDas Skript wird beendet.\n"
        exit 1
    fi
}

# Hauptprogramm
main() {
    # Begrüßungsnachricht
    printf "\n"
    print_colored "blue" "========================================================"
    printf "\n"
    print_colored "blue" "              Arch Linux Update-Skript"
    printf "\n"
    print_colored "blue" "========================================================"
    printf "\n\n"
    
    # Initialisieren der Fehlerprotokolle
    ERROR_LOG=""
    
    # Prüfe Internetverbindung
    if ! ping -c 1 archlinux.org > /dev/null 2>&1; then
        print_colored "red" "Keine Internetverbindung. Das Update wird abgebrochen."
        printf "\n"
        exit 1
    fi
    
    # Prüfe und fordere Root-Rechte an
    check_sudo
    
    # Prüfe, ob notwendige Pakete installiert sind
    check_and_install_packages
    
    # Frage den Benutzer nach GitHub-Repository-Informationen
    ask_for_github_repo
    
    # Frage den Benutzer nach dem Update-Modus
    ask_for_update_mode
    
    # Führe System-Vorbereitung durch (nur bei vollständigem Update)
    if [ "$UPDATE_MODE" = "full" ]; then
        perform_system_preparation
    fi
    
    # Führe Paket-Updates durch
    perform_package_updates
    
    # Führe Systembereinigung durch (nur bei vollständigem Update)
    if [ "$UPDATE_MODE" = "full" ]; then
        perform_system_cleanup
    fi
    
    # Ausgabe einer Erfolgsmeldung
    printf "\n"
    print_colored "green" "========================================================"
    printf "\n"
    print_colored "green" "              Update wurde abgeschlossen"
    printf "\n"
    print_colored "green" "========================================================"
    printf "\n\n"
    
    # Ausgabe von Fehlermeldungen, falls vorhanden
    if [ -n "$ERROR_LOG" ]; then
        print_colored "red" "Es sind Fehler aufgetreten:"
        printf "\n"
        printf "%s" "$ERROR_LOG"
        printf "\nSiehe ~/update_error_log.txt für Details.\n"
    fi
    
    # Frage, ob ein Neustart erwünscht ist
    print_colored "yellow" "Möchten Sie das System neu starten? (j/n)"
    printf "\n"
    read -r reboot_choice
    
    if [ "$reboot_choice" = "j" ] || [ "$reboot_choice" = "J" ]; then
        print_colored "blue" "System wird neu gestartet..."
        printf "\n"
        log_update "System wird neu gestartet"
        sudo reboot
    else
        print_colored "blue" "Neustart abgebrochen."
        printf "\n"
    fi
    
    exit 0
}

# Skript ausführen
main
