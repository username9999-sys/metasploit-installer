#!/usr/bin/env bash
# ==============================================================================
# HTTP SCANNER MODULE — Web server version detection, dir scanning, vuln checks
# Usage: bash http_scanner.sh <TARGET> [options]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true

TARGET="${1:-}"
MODE="${2:-quick}"

[[ -z "$TARGET" ]] && { echo "Usage: bash http_scanner.sh <TARGET> [quick|full|vuln]"; exit 1; }

# Determine if we're in msfconsole or standalone
IN_MSF=false
if [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]]; then
    IN_MSF=true
fi

run_msf_module() {
    local module="$1"
    shift
    local cmd="use $module"
    for arg in "$@"; do
        cmd="$cmd; set $arg"
    done
    cmd="$cmd; run"
    echo "$cmd"
}

echo ""
echo "=== HTTP SCANNER — Target: $TARGET ==="
echo ""

# HTTP Version Detection
echo -e "--- ${BLUE}HTTP Version Detection${NC} ---"
if $IN_MSF; then
    run_msf_module "auxiliary/scanner/http/http_version" "RHOSTS $TARGET" "RPORT 80,443,8080,8443,9090"
else
    echo "msfconsole -x 'use auxiliary/scanner/http/http_version; set RHOSTS $TARGET; set RPORT 80,443,8080,8443,9090; run'"
fi
echo ""

# HTTP Options
echo -e "--- ${BLUE}HTTP Options Method Check${NC} ---"
if $IN_MSF; then
    run_msf_module "auxiliary/scanner/http/options" "RHOSTS $TARGET"
else
    echo "msfconsole -x 'use auxiliary/scanner/http/options; set RHOSTS $TARGET; run'"
fi
echo ""

# Directory Scanner
if [[ "$MODE" != "quick" ]]; then
    echo -e "--- ${BLUE}Directory Scanner${NC} ---"
    if $IN_MSF; then
        run_msf_module "auxiliary/scanner/http/dir_scanner" "RHOSTS $TARGET" "DICTIONARY /usr/share/seclists/Discovery/Web-Content/common.txt"
    else
        echo "msfconsole -x 'use auxiliary/scanner/http/dir_scanner; set RHOSTS $TARGET; set DICTIONARY /usr/share/seclists/Discovery/Web-Content/common.txt; run'"
    fi
    echo ""
fi

# SSL Certificate
echo -e "--- ${BLUE}SSL Certificate Inspection${NC} ---"
if $IN_MSF; then
    run_msf_module "auxiliary/gather/ssl_cert" "RHOSTS $TARGET"
else
    echo "msfconsole -x 'use auxiliary/gather/ssl_cert; set RHOSTS $TARGET; run'"
fi
echo ""

# Vulnerability checks
if [[ "$MODE" == "vuln" || "$MODE" == "full" ]]; then
    echo -e "--- ${RED}Vulnerability Checks${NC} ---"
    for module in \
        "auxiliary/scanner/http/apache_optionsbleed" \
        "auxiliary/scanner/http/shellshock" \
        "auxiliary/scanner/http/http_trace" \
        "auxiliary/scanner/http/robots_txt"; do
        if $IN_MSF; then
            run_msf_module "$module" "RHOSTS $TARGET"
        else
            echo "msfconsole -x 'use $module; set RHOSTS $TARGET; run'"
        fi
    done
    echo ""
fi

# Recommendations
echo -e "--- ${GREEN}Recommendations${NC} ---"
echo "1. Review open ports and services"
echo "2. Check directory listings for sensitive files"
echo "3. Test SSL/TLS configuration"
echo "4. Run web app scanner (nikto, nuclei) for deeper analysis"
echo ""

if ! $IN_MSF; then
    info "Run inside msfconsole: bash msf-run.sh module scanner/http/http_scanner $TARGET $MODE"
    info "Or copy-paste the commands above into msfconsole"
fi
