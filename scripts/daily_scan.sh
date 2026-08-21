#!/usr/bin/env bash
# ==============================================================================
# DAILY SCAN — Automated scheduled scanning with Metasploit
# Usage: bash daily_scan.sh [--rate-limit N] [--output-dir DIR] [targets...]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/env.sh" 2>/dev/null || true
detect_all 2>/dev/null || true

# ── Defaults ──────────────────────────────────────────────────────────────────
RATE_LIMIT="50"
OUTPUT_DIR="$HOME/msf_scans/$(date +%F)"
TARGETS=()
SCAN_TYPES=("quick" "service" "vuln")
MSFCONSOLE_BIN="${HOME}/bin/msfconsole"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$OUTPUT_DIR/scan_${TIMESTAMP}.log"

# ── Helpers ───────────────────────────────────────────────────────────────────
log()   { echo -e "  [✓] $*" | tee -a "$LOG_FILE"; }
info()  { echo -e "  [*] $*" | tee -a "$LOG_FILE"; }
warn()  { echo -e "  [!] $*" | tee -a "$LOG_FILE"; }
err()   { echo -e "  [✗] $*" | tee -a "$LOG_FILE"; }

usage() {
    cat << USAGE
Daily Scan - Automated Metasploit Scanning

Usage: bash daily_scan.sh [OPTIONS] [TARGETS...]

Options:
  --rate-limit N      Max packets/sec for nmap (default: 50)
  --output-dir DIR    Output directory (default: ~/msf_scans/YYYY-MM-DD)
  --scan-types LIST   Comma-separated: quick,service,vuln,full (default: quick,service,vuln)
  --msfconsole PATH   Path to msfconsole (default: ~/bin/msfconsole)
  -h, --help          Show this help

Targets:
  CIDR notation (192.168.1.0/24), IP ranges (192.168.1.1-50), 
  comma-separated (192.168.1.10,192.168.1.20), or hostnames

Examples:
  bash daily_scan.sh 192.168.1.0/24
  bash daily_scan.sh --rate-limit 100 --scan-types full 10.0.0.0/16
  bash daily_scan.sh --output-dir /data/scans 192.168.1.100
USAGE
    exit 0
}

# ── Parse Args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --rate-limit) RATE_LIMIT="$2"; shift 2 ;;
        --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
        --scan-types) IFS=',' read -ra SCAN_TYPES <<< "$2"; shift 2 ;;
        --msfconsole) MSFCONSOLE_BIN="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) TARGETS+=("$1"); shift ;;
    esac
done

[[ ${#TARGETS[@]} -eq 0 ]] && { err "No targets specified"; usage; }

# ── Setup ──────────────────────────────────────────────────────────────────────
mkdir -p "$OUTPUT_DIR"
log "Daily Scan started at $(date)"
log "Targets: ${TARGETS[*]}"
log "Output: $OUTPUT_DIR"
log "Rate limit: $RATE_LIMIT pps"

# Build target string for msf
MSF_TARGETS=$(IFS=,; echo "${TARGETS[*]}")

# ── Generate Resource Scripts ─────────────────────────────────────────────────
generate_rc() {
    local scan_type="$1"
    local rc_file="$OUTPUT_DIR/scan_${scan_type}_${TIMESTAMP}.rc"
    
    cat > "$rc_file" << RC_EOF
# Daily Scan - $scan_type - $(date)
spool $OUTPUT_DIR/scan_${scan_type}_${TIMESTAMP}.txt

# Database
db_connect \$HOME/.msf4/database.yml

RC_EOF

    case "$scan_type" in
        quick)
            cat >> "$rc_file" << RC_EOF
use auxiliary/scanner/portscan/tcp
set RHOSTS $MSF_TARGETS
set PORTS 21,22,23,25,53,80,110,139,443,445,993,995,1433,1521,3306,3389,5432,5900,8080,8443
set THREADS 50
run

use auxiliary/scanner/smb/smb_version
set RHOSTS $MSF_TARGETS
run

use auxiliary/scanner/ssh/ssh_version
set RHOSTS $MSF_TARGETS
run
RC_EOF
            ;;
        service)
            cat >> "$rc_file" << RC_EOF
use auxiliary/scanner/portscan/tcp
set RHOSTS $MSF_TARGETS
set PORTS 1-65535
set THREADS 30
run

# Service enumeration
use auxiliary/scanner/http/http_version
set RHOSTS $MSF_TARGETS
set RPORT 80,443,8080,8443
run

use auxiliary/scanner/smb/smb2
set RHOSTS $MSF_TARGETS
run
RC_EOF
            ;;
        vuln)
            cat >> "$rc_file" << RC_EOF
# Vulnerability scanning - requires nmap integration
# Import nmap XML first
# db_import /path/to/nmap_output.xml

# MSF built-in vuln checks
use auxiliary/scanner/smb/smb_ms17_010
set RHOSTS $MSF_TARGETS
run

use auxiliary/scanner/rdp/cve_2019_0708_bluekeep
set RHOSTS $MSF_TARGETS
run

use auxiliary/scanner/http/shellshock
set RHOSTS $MSF_TARGETS
run
RC_EOF
            ;;
        full)
            cat >> "$rc_file" << RC_EOF
use auxiliary/scanner/portscan/tcp
set RHOSTS $MSF_TARGETS
set PORTS 1-65535
set THREADS 20
run

# All enumeration
use auxiliary/scanner/smb/smb_version; set RHOSTS $MSF_TARGETS; run
use auxiliary/scanner/ssh/ssh_version; set RHOSTS $MSF_TARGETS; run
use auxiliary/scanner/http/http_version; set RHOSTS $MSF_TARGETS; run
use auxiliary/scanner/mssql/mssql_ping; set RHOSTS $MSF_TARGETS; run
use auxiliary/scanner/mysql/mysql_version; set RHOSTS $MSF_TARGETS; run
use auxiliary/scanner/postgres/postgres_version; set RHOSTS $MSF_TARGETS; run
RC_EOF
            ;;
    esac
    
    echo "spool off" >> "$rc_file"
    echo "$rc_file"
}

# ── Run Scans ─────────────────────────────────────────────────────────────────
run_scan() {
    local scan_type="$1"
    local rc_file
    rc_file=$(generate_rc "$scan_type")
    
    info "Running $scan_type scan..."
    
    if [[ ! -x "$MSFCONSOLE_BIN" ]]; then
        warn "msfconsole not found at $MSFCONSOLE_BIN"
        warn "Trying system msfconsole..."
        MSFCONSOLE_BIN="$(command -v msfconsole)"
    fi
    
    if [[ -z "$MSFCONSOLE_BIN" ]] || [[ ! -x "$MSFCONSOLE_BIN" ]]; then
        err "msfconsole not available — cannot run scan"
        return 1
    fi
    
    # Run with timeout
    timeout 3600 "$MSFCONSOLE_BIN" -q -r "$rc_file" 2>&1 | tee -a "$LOG_FILE"
    local exit_code=${PIPESTATUS[0]}
    
    if [[ $exit_code -eq 0 ]] || [[ $exit_code -eq 124 ]]; then
        log "$scan_type scan completed"
    else
        warn "$scan_type scan exited with code $exit_code"
    fi
    
    # Generate summary
    local txt_file="${rc_file%.rc}.txt"
    if [[ -f "$txt_file" ]]; then
        local host_count
        host_count=$(grep -c "Host:" "$txt_file" 2>/dev/null || echo 0)
        log "$scan_type: $host_count hosts found"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    for scan_type in "${SCAN_TYPES[@]}"; do
        run_scan "$scan_type"
        sleep 5
    done
    
    # Generate HTML report
    info "Generating summary report..."
    cat > "$OUTPUT_DIR/report_${TIMESTAMP}.html" << HTML_EOF
<!DOCTYPE html>
<html>
<head>
    <title>Daily Scan Report - $(date)</title>
    <style>
        body { font-family: monospace; background: #1a1a1a; color: #0f0; padding: 20px; }
        h1 { color: #f00; }
        .section { margin: 20px 0; padding: 10px; border: 1px solid #333; }
        pre { background: #000; padding: 10px; overflow-x: auto; }
    </style>
</head>
<body>
    <h1>🔴 Daily Scan Report</h1>
    <p><strong>Date:</strong> $(date)</p>
    <p><strong>Targets:</strong> ${TARGETS[*]}</p>
    <p><strong>Rate Limit:</strong> ${RATE_LIMIT}pps</p>
    <div class="section">
        <h2>Scan Types: ${SCAN_TYPES[*]}</h2>
    </div>
    <div class="section">
        <h2>Output Files</h2>
        <ul>
HTML_EOF

    for f in "$OUTPUT_DIR"/*"${TIMESTAMP}"*; do
        [[ -f "$f" ]] && echo "            <li>$(basename "$f")</li>" >> "$OUTPUT_DIR/report_${TIMESTAMP}.html"
    done

    cat >> "$OUTPUT_DIR/report_${TIMESTAMP}.html" << HTML_EOF
        </ul>
    </div>
</body>
</html>
HTML_EOF
    
    log "Report: $OUTPUT_DIR/report_${TIMESTAMP}.html"
    log "All scans complete!"
}

main "$@"
