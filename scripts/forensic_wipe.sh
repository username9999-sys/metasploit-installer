#!/usr/bin/env bash
# ==============================================================================
# FORENSIC WIPE — Secure cleanup of Metasploit workspace (preserves DB by default)
# Usage: bash forensic_wipe.sh [--preserve-db] [--force]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh" 2>/dev/null || {
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
    log() { echo -e "${GREEN}[✓]${NC} $*"; }
    info() { echo -e "${BLUE}[*]${NC} $*"; }
    warn() { echo -e "${YELLOW}[!]${NC} $*"; }
    err() { echo -e "${RED}[✗]${NC} $*" >&2; }
    ask_yesno() {
        local p="${1:-Continue?}" d="${2:-n}" h
        [[ "$d" == "y" ]] && h="[Y/n]" || h="[y/N]"
        local a; read -r -p "  [?] $p $h: " a; a="${a:-$d}"
        [[ "${a,,}" == "y" || "${a,,}" == "yes" ]]
    }
}

# ── Config ────────────────────────────────────────────────────────────────────
PRESERVE_DB=true
FORCE_MODE=false
MSF_DIR="${MSF_DIR:-$HOME/.msf4}"
INSTALL_DIR="${MSF_INSTALL_DIR:-$HOME/metasploit-framework}"

# ── Targets to wipe ───────────────────────────────────────────────────────────
WIPE_TARGETS=(
    "$MSF_DIR/logs"
    "$MSF_DIR/loot"
    "$MSF_DIR/data"
    "$MSF_DIR/local"
    "$MSF_DIR/modules"
    "$MSF_DIR/plugins"
    "$MSF_DIR/config"
    "$HOME/bin/msfconsole"
    "$HOME/bin/msfvenom"
    "$HOME/bin/msfdb"
    "$HOME/bin/pg-start"
    "$HOME/bin/pg-stop"
    "$HOME/.msf-setup-state"
    "$HOME/.msf4/config.yml"
    "$HOME/.msf4/database.yml"
    "$HOME/.msf4/hosts"
    "$HOME/.msf4/creds"
    "$HOME/.msf4/services"
    "$HOME/.msf4/vulns"
    "$HOME/.msf4/notes"
    "$HOME/.msf4/web_sites"
    "$HOME/.msf4/web_vulns"
    "$HOME/.msf4/web_forms"
    "$HOME/.msf4/web_pages"
    "$HOME/.msf4/web_urls"
)

# DB files (only wiped if --no-preserve-db)
DB_TARGETS=(
    "$MSF_DIR/postgres"
    "$HOME/.msf4/postgres"
    "$HOME/db_data"
    "$HOME/pg_data"
)

# ── Secure Delete ─────────────────────────────────────────────────────────────
secure_delete() {
    local target="$1"
    local passes="${2:-3}"
    
    [[ ! -e "$target" ]] && return 0
    
    info "Wiping: $target"
    
    if command -v shred &>/dev/null; then
        if [[ -f "$target" ]]; then
            shred -n "$passes" -z -u "$target" 2>/dev/null || rm -f "$target"
        elif [[ -d "$target" ]]; then
            find "$target" -type f -exec shred -n "$passes" -z -u {} \; 2>/dev/null || true
            rm -rf "$target" 2>/dev/null || true
        fi
    else
        # Fallback: multiple overwrites with dd
        if [[ -f "$target" ]]; then
            local size
            size=$(stat -c%s "$target" 2>/dev/null || stat -f%z "$target" 2>/dev/null || echo 0)
            for i in $(seq 1 $passes); do
                dd if=/dev/urandom of="$target" bs=1M count=$((size/1024/1024 + 1)) 2>/dev/null || true
            done
            dd if=/dev/zero of="$target" bs=1M count=$((size/1024/1024 + 1)) 2>/dev/null || true
            rm -f "$target"
        elif [[ -d "$target" ]]; then
            find "$target" -type f -exec rm -f {} \; 2>/dev/null || true
            rm -rf "$target" 2>/dev/null || true
        fi
    fi
}

# ── Wipe Workspace ────────────────────────────────────────────────────────────
wipe_workspace() {
    step "Forensic Workspace Wipe"
    
    echo ""
    echo -e "  ${BOLD}Targets to be wiped:${NC}"
    for t in "${WIPE_TARGETS[@]}"; do
        [[ -e "$t" ]] && echo -e "  ${RED}✓${NC} $t" || echo -e "  ${DIM}○${NC} $t (not found)"
    done
    
    if [[ "$PRESERVE_DB" == "true" ]]; then
        echo ""
        echo -e "  ${GREEN}Database PRESERVED${NC} (use --no-preserve-db to wipe PostgreSQL data)"
    else
        echo ""
        echo -e "  ${RED}Database WILL BE WIPED${NC}:"
        for t in "${DB_TARGETS[@]}"; do
            [[ -e "$t" ]] && echo -e "  ${RED}✓${NC} $t" || echo -e "  ${DIM}○${NC} $t (not found)"
        done
    fi
    
    echo ""
    if [[ "$FORCE_MODE" != "true" ]]; then
        ask_yesno "CONFIRM: Proceed with secure wipe?" "n" || { info "Cancelled"; exit 0; }
        echo ""
        ask_yesno "This is IRREVERSIBLE. Are you absolutely sure?" "n" || { info "Cancelled"; exit 0; }
    fi
    
    # Stop PostgreSQL first (if home mode)
    if [[ -x "$HOME/bin/pg-stop" ]]; then
        info "Stopping PostgreSQL..."
        "$HOME/bin/pg-stop" 2>/dev/null || true
    fi
    
    # Wipe targets
    for t in "${WIPE_TARGETS[@]}"; do
        secure_delete "$t"
    done
    
    # Wipe DB if requested
    if [[ "$PRESERVE_DB" != "true" ]]; then
        for t in "${DB_TARGETS[@]}"; do
            secure_delete "$t" 7
        done
    fi
    
    # Clean shell history of sensitive commands
    if [[ -f "$HOME/.bash_history" ]]; then
        info "Sanitizing shell history..."
        grep -v -i -E '(msfpass|msfpassword|msfuser|msfdb|postgres|password|secret|token|api_key)' "$HOME/.bash_history" > "$HOME/.bash_history.tmp" 2>/dev/null || true
        mv "$HOME/.bash_history.tmp" "$HOME/.bash_history" 2>/dev/null || true
    fi
    
    log "Forensic wipe complete"
    info "Recommend: reboot system to clear RAM"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --preserve-db) PRESERVE_DB=true; shift ;;
            --no-preserve-db) PRESERVE_DB=false; shift ;;
            --force|-f) FORCE_MODE=true; shift ;;
            --help|-h)
                cat << USAGE
Usage: bash $(basename "$0") [OPTIONS]

Options:
  --preserve-db       Keep PostgreSQL data (default)
  --no-preserve-db    Also wipe PostgreSQL data directories
  --force, -f         Skip confirmations
  --help, -h          Show this help

By default, this preserves your database but wipes:
  - Logs, loot, session data
  - Config files (database.yml, config.yml)
  - Launchers (msfconsole, msfvenom, msfdb)
  - PostgreSQL helpers (pg-start, pg-stop)
  - Shell history sanitization

USAGE
                exit 0
                ;;
            *) err "Unknown option: $1"; exit 1 ;;
        esac
    done
    
    wipe_workspace
}

main "$@"
