#!/usr/bin/env bash
# ==============================================================================
# SSH SCANNER MODULE — SSH version detection, auth enumeration
# Usage: bash ssh_scanner.sh <TARGET> [quick|full]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true

TARGET="${1:-}"
MODE="${2:-quick}"

[[ -z "$TARGET" ]] && { echo "Usage: bash ssh_scanner.sh <TARGET> [quick|full]"; exit 1; }

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
echo "=== SSH SCANNER — Target: $TARGET ==="
echo ""

# SSH Version Detection
echo -e "--- ${BLUE}SSH Version Detection${NC} ---"
if $IN_MSF; then
    run_msf_module "auxiliary/scanner/ssh/ssh_version" "RHOSTS $TARGET" "THREADS 10"
else
    echo "msfconsole -x 'use auxiliary/scanner/ssh/ssh_version; set RHOSTS $TARGET; set THREADS 10; run'"
fi
echo ""

# SSH User Enumeration
if [[ "$MODE" != "quick" ]]; then
    echo -e "--- ${BLUE}SSH User Enumeration${NC} ---"
    if $IN_MSF; then
        run_msf_module "auxiliary/scanner/ssh/ssh_enumusers" "RHOSTS $TARGET" "USER_FILE /usr/share/metasploit-framework/data/wordlists/common_users.txt"
    else
        echo "msfconsole -x 'use auxiliary/scanner/ssh/ssh_enumusers; set RHOSTS $TARGET; set USER_FILE /usr/share/metasploit-framework/data/wordlists/common_users.txt; run'"
    fi
    echo ""
fi

# SSH Login (Brute Force - optional)
if [[ "$MODE" == "full" ]]; then
    echo -e "--- ${YELLOW}SSH Login Brute Force (optional)${NC} ---"
    echo "# Requires user list and pass list:"
    echo "msfconsole -x 'use auxiliary/scanner/ssh/ssh_login; set RHOSTS $TARGET; set USER_FILE /usr/share/wordlists/common_users.txt; set PASS_FILE /usr/share/wordlists/rockyou.txt; set THREADS 5; run'"
    echo ""
fi

echo -e "--- ${GREEN}Recommendations${NC} ---"
echo "1. Check SSH version for known vulnerabilities"
echo "2. Test for weak credentials if authorized"
echo "3. Check for SSH key authentication"
echo "4. If access gained: post/linux/manage/sshkey_persistence"
