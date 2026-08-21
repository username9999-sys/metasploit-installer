#!/usr/bin/env bash
# ==============================================================================
# WEB GATHER — Web application reconnaissance
# Usage: bash web_gather.sh <TARGET_URL>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
TARGET="${1:-}"
[[ -z "$TARGET" ]] && { echo "Usage: bash web_gather.sh <TARGET_URL>"; exit 1; }
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }
echo ""; echo "=== WEB GATHER — Target: $TARGET ==="; echo ""
echo -e "--- ${BLUE}HTTP Enumeration${NC} ---"
for mod in http_version options dir_scanner apache_userdir_enum ssl_cert apache_optionsbleed; do
    $IN_MSF && run_msf "auxiliary/scanner/http/$mod" "RHOSTS $TARGET"
done
echo ""
echo -e "--- ${BLUE}Web App Fingerprinting${NC} ---"
$IN_MSF && run_msf "auxiliary/scanner/http/http_fingerprint" "RHOSTS $TARGET"
echo "# External: whatweb $TARGET"
echo "nikto -h $TARGET"
echo ""
echo -e "--- ${BLUE}Vulnerability Scan${NC} ---"
for vuln in shellshock http_vuln http_vuln_cve2017_5638 http_vuln_cve2017_9805 http_vuln_cve2018_7600 http_vuln_cve2019_19781; do
    $IN_MSF && run_msf "auxiliary/scanner/http/$vuln" "RHOSTS $TARGET"
done
echo ""
echo -e "--- ${BLUE}CMS Scanners${NC} ---"
for cms in http_wordpress_scanner http_joomla_scanner http_drupal_scanner; do
    $IN_MSF && run_msf "auxiliary/scanner/http/$cms" "RHOSTS $TARGET"
done
