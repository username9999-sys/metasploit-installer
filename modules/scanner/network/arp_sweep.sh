#!/usr/bin/env bash
# ==============================================================================
# ARP SWEEP MODULE — Local network host discovery
# Usage: bash arp_sweep.sh <TARGET_CIDR>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
TARGET="${1:-}"
[[ -z "$TARGET" ]] && { echo "Usage: bash arp_sweep.sh <CIDR>"; exit 1; }
IN_MSF=false
[[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf_module() { local module="$1"; shift; local cmd="use $module"; for arg in "$@"; do cmd="$cmd; set $arg"; done; cmd="$cmd; run"; echo "$cmd"; }
echo ""; echo "=== ARP SWEEP — Target: $TARGET ==="; echo ""
echo -e "--- ${BLUE}ARP Sweep${NC} ---"
$IN_MSF && run_msf_module "auxiliary/scanner/discovery/arp_sweep" "RHOSTS $TARGET" "THREADS 50" || echo "msfconsole -x 'use auxiliary/scanner/discovery/arp_sweep; set RHOSTS $TARGET; set THREADS 50; run'"
echo ""
echo -e "--- ${BLUE}UDP Service Discovery${NC} ---"
$IN_MSF && run_msf_module "auxiliary/scanner/discovery/udp_sweep" "RHOSTS $TARGET" "THREADS 50" || echo "msfconsole -x 'use auxiliary/scanner/discovery/udp_sweep; set RHOSTS $TARGET; set THREADS 50; run'"
echo ""
echo -e "--- ${GREEN}Alternative: Nmap${NC} ---"
echo "nmap -sn $TARGET"
