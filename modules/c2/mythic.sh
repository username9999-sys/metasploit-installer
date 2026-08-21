#!/usr/bin/env bash
# ==============================================================================
# MYTHIC C2 — Modular, plugin-based C2 framework
# Usage: bash mythic.sh [install|start|menu]
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
MYTHIC_DIR="${MYTHIC_DIR:-$HOME/mythic}"
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }
install_mythic() { step "Installing Mythic C2"; [[ -d "$MYTHIC_DIR" ]] && { log "Mythic exists"; return 0; }; cmd_exists docker && docker info &>/dev/null || { warn "Docker required"; return 1; }; git clone https://github.com/its-a-feature/Mythic.git "$MYTHIC_DIR" 2>/dev/null || true; log "Cloned to $MYTHIC_DIR"; info "Install: cd $MYTHIC_DIR && sudo ./mythic-cli install"; info "Start: cd $MYTHIC_DIR && sudo ./mythic-cli start"; }
start_mythic() { [[ -d "$MYTHIC_DIR" ]] || { err "Run install first"; return 1; }; cmd_exists docker || { err "Docker not available"; return 1; }; cd "$MYTHIC_DIR"; sudo ./mythic-cli start; log "Mythic started on http://localhost:7443"; }
case "${1:-menu}" in install) install_mythic ;; start) start_mythic ;; menu) echo ""; echo -e "${BOLD}Mythic C2:${NC}"; echo -e " 1) Install  2) Start  0) Back"; read -r -p "Choice: " c; case "$c" in 1) install_mythic ;; 2) start_mythic ;; esac ;; *) err "Usage: bash mythic.sh [install|start|menu]"; exit 1 ;; esac
