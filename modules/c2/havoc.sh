#!/usr/bin/env bash
# ==============================================================================
# HAVOC C2 — Modern Docker-based C2 framework
# Usage: bash havoc.sh [install|start|menu]
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
HAVOC_DIR="${HAVOC_DIR:-$HOME/havoc}"
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }

install_havoc() {
    step "Installing Havoc C2"
    [[ -d "$HAVOC_DIR" ]] && { log "Havoc directory exists"; return 0; }
    if ! cmd_exists docker || ! docker info &>/dev/null; then
        warn "Docker required for Havoc. Install Docker first."
        return 1
    fi
    info "Cloning Havoc..."
    git clone https://github.com/HavocFramework/Havoc.git "$HAVOC_DIR" 2>/dev/null || true
    log "Havoc cloned to $HAVOC_DIR"
    info "Build: cd $HAVOC_DIR && docker compose build"
    info "Run: cd $HAVOC_DIR && docker compose up -d"
}

start_havoc() {
    [[ -d "$HAVOC_DIR" ]] || { err "Havoc not installed. Run: bash havoc.sh install"; return 1; }
    cmd_exists docker || { err "Docker not available"; return 1; }
    info "Starting Havoc via Docker Compose..."
    cd "$HAVOC_DIR"
    docker compose up -d
    log "Havoc started. Web UI: https://localhost:443 (default admin:password)"
    warn "CHANGE DEFAULT PASSWORD IMMEDIATELY!"
}

case "${1:-menu}" in
    install) install_havoc ;;
    start) start_havoc ;;
    menu)
        echo ""; echo -e "${BOLD}Havoc C2 Options:${NC}"
        echo -e "  ${GREEN}1)${NC} Install Havoc"
        echo -e "  ${GREEN}2)${NC} Start Havoc"
        echo -e "  ${GREEN}0)${NC} Back"
        read -r -p "  [?] Choice: " c
        case "$c" in 1) install_havoc ;; 2) start_havoc ;; esac
        ;;
    *) err "Usage: bash havoc.sh [install|start|menu]"; exit 1 ;;
esac
