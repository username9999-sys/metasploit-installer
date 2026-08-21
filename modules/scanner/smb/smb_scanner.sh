#!/usr/bin/env bash
# ==============================================================================
# SMB SCANNER MODULE — SMB enumeration, version detection, vulnerability scan
# Usage: bash smb_scanner.sh <TARGET> [quick|full|vuln]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true

TARGET="${1:-}"
MODE="${2:-quick}"

[[ -z "$TARGET" ]] && { echo "Usage: bash smb_scanner.sh <TARGET> [quick|full|vuln]"; exit 1; }

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
echo "=== SMB SCANNER — Target: $TARGET ==="
echo ""

# SMB Version Detection
echo -e "--- ${BLUE}SMB Version Detection${NC} ---"
if $IN_MSF; then
    run_msf_module "auxiliary/scanner/smb/smb_version" "RHOSTS $TARGET" "THREADS 10"
else
    echo "msfconsole -x 'use auxiliary/scanner/smb/smb_version; set RHOSTS $TARGET; set THREADS 10; run'"
fi
echo ""

# SMB Share Enumeration
echo -e "--- ${BLUE}SMB Share Enumeration${NC} ---"
if $IN_MSF; then
    run_msf_module "auxiliary/scanner/smb/smb_enumshares" "RHOSTS $TARGET" "ShowFiles true"
else
    echo "msfconsole -x 'use auxiliary/scanner/smb/smb_enumshares; set RHOSTS $TARGET; set ShowFiles true; run'"
fi
echo ""

# SMB User Enumeration
if [[ "$MODE" != "quick" ]]; then
    echo -e "--- ${BLUE}SMB User Enumeration${NC} ---"
    if $IN_MSF; then
        run_msf_module "auxiliary/scanner/smb/smb_enumusers" "RHOSTS $TARGET"
    else
        echo "msfconsole -x 'use auxiliary/scanner/smb/smb_enumusers; set RHOSTS $TARGET; run'"
    fi
    echo ""
fi

# EternalBlue (MS17-010) Check
echo -e "--- ${RED}EternalBlue (MS17-010) Check${NC} ---"
if $IN_MSF; then
    run_msf_module "auxiliary/scanner/smb/smb_ms17_010" "RHOSTS $TARGET"
else
    echo "msfconsole -x 'use auxiliary/scanner/smb/smb_ms17_010; set RHOSTS $TARGET; run'"
fi
echo ""

# SMB2 Protocol Check
if [[ "$MODE" != "quick" ]]; then
    echo -e "--- ${BLUE}SMB2 Protocol Check${NC} ---"
    if $IN_MSF; then
        run_msf_module "auxiliary/scanner/smb/smb2" "RHOSTS $TARGET"
    else
        echo "msfconsole -x 'use auxiliary/scanner/smb/smb2; set RHOSTS $TARGET; run'"
    fi
    echo ""
fi

# SMB Vulnerability Checks
if [[ "$MODE" == "vuln" || "$MODE" == "full" ]]; then
    echo -e "--- ${RED}Additional Vulnerability Checks${NC} ---"
    for module in \
        "auxiliary/scanner/smb/pipe_auditor" \
        "auxiliary/scanner/smb/smb_psexec" \
        "auxiliary/scanner/smb/pipe_dcerpc_auditor"; do
        if $IN_MSF; then
            run_msf_module "$module" "RHOSTS $TARGET"
        else
            echo "msfconsole -x 'use $module; set RHOSTS $TARGET; run'"
        fi
    done
    echo ""
fi

# SMB Login Brute (optional - requires credentials)
if [[ "$MODE" == "full" ]]; then
    echo -e "--- ${YELLOW}SMB Login Brute (optional)${NC} ---"
    echo "# Requires user list and pass list:"
    echo "msfconsole -x 'use auxiliary/scanner/smb/smb_login; set RHOSTS $TARGET; set SMBUser administrator; set PASS_FILE /usr/share/wordlists/rockyou.txt; set THREADS 5; run'"
    echo ""
fi

echo -e "--- ${GREEN}Recommendations${NC} ---"
echo "1. If MS17-010 vulnerable: exploit/windows/smb/ms17_010_eternalblue"
echo "2. If shares accessible: Check for sensitive files"
echo "3. If users enumerated: Try password spray or ASREPRoast"
echo "4. Use PsExec with valid creds: exploit/windows/smb/psexec"
echo ""

if ! $IN_MSF; then
    info "Run inside msfconsole: bash msf-run.sh module scanner/smb/smb_scanner $TARGET $MODE"
    info "Or copy-paste the commands above into msfconsole"
fi
