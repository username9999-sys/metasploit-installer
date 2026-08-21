#!/usr/bin/env bash
# ==============================================================================
# DNS GATHER — DNS reconnaissance
# Usage: bash dns_gather.sh <DOMAIN>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
DOMAIN="${1:-}"
[[ -z "$DOMAIN" ]] && { echo "Usage: bash dns_gather.sh <DOMAIN>"; exit 1; }
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }
echo ""; echo "=== DNS GATHER — Domain: $DOMAIN ==="; echo ""
echo -e "--- ${BLUE}Zone Transfer${NC} ---"
$IN_MSF && run_msf "auxiliary/gather/dns_brute" "DOMAIN $DOMAIN" "WORDLIST /usr/share/wordlists/dnsmap.txt" || echo "msfconsole -x 'use auxiliary/gather/dns_brute; set DOMAIN $DOMAIN; run'"
echo ""
echo -e "--- ${BLUE}DNS Records${NC} ---"
echo "dig @8.8.8.8 $DOMAIN ANY"
echo "dig @8.8.8.8 $DOMAIN AXFR"
echo "nslookup -type=any $DOMAIN 8.8.8.8"
echo ""
echo -e "--- ${BLUE}Subdomain Enum${NC} ---"
$IN_MSF && run_msf "auxiliary/gather/dns_brute" "DOMAIN $DOMAIN" "WORDLIST /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt"
echo "# Also try: subfinder -d $DOMAIN"
echo "# amass enum -d $DOMAIN"
