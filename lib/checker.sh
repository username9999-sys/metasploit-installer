#!/usr/bin/env bash
# ==============================================================================
# PRE-FLIGHT CHECKER — Validate environment before install
# Usage: bash lib/checker.sh [--quiet]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/env.sh" 2>/dev/null || true

QUIET=false
[[ "${1:-}" == "--quiet" ]] && QUIET=true

log_q() { $QUIET || log "$@"; }
info_q() { $QUIET || info "$@"; }
warn_q() { $QUIET || warn "$@"; }
err_q() { $QUIET || err "$@"; }

# ── Check Functions ─────────────────────────────────────────────────────────
check_item() {
    local label="$1" cmd="$2"
    if eval "$cmd" &>/dev/null; then
        log_q "$label"
        return 0
    else
        err_q "$label — MISSING"
        return 1
    fi
}

# Main check
main() {
    local failed=0
    
    # OS Detection
    detect_all 2>/dev/null || true
    
    echo -e "${BOLD}── System Requirements ──${NC}"
    check_item "OS: Linux/Unix/macOS" '[[ "$(uname -s)" =~ ^(Linux|Darwin)$ ]]' || failed=1
    check_item "Architecture supported" '[[ "$(uname -m)" =~ ^(x86_64|aarch64|arm64|armv7l)$ ]]' || failed=1
    
    echo -e "${BOLD}── Core Tools ──${NC}"
    check_item "bash >= 4.0" 'bash -c "echo ${BASH_VERSION%%.*} >= 4" 2>/dev/null' || failed=1
    check_item "git" 'command -v git' || failed=1
    check_item "curl" 'command -v curl' || failed=1
    check_item "wget" 'command -v wget' || failed=1
    
    echo -e "${BOLD}── Package Manager ──${NC}"
    case "${OS_FAMILY:-}" in
        debian) check_item "apt" 'command -v apt-get' || failed=1 ;;
        redhat) check_item "dnf/yum" 'command -v dnf || command -v yum' || failed=1 ;;
        arch) check_item "pacman" 'command -v pacman' || failed=1 ;;
        termux) check_item "pkg" 'command -v pkg' || failed=1 ;;
        *) warn_q "Unknown OS family: ${OS_FAMILY:-unknown}" ;;
    esac
    
    echo -e "${BOLD}── Development Tools ──${NC}"
    check_item "gcc/clang" 'command -v gcc || command -v clang' || failed=1
    check_item "make" 'command -v make' || failed=1
    check_item "ruby >= 2.7" 'ruby -e "exit(RUBY_VERSION.to_f >= 2.7 ? 0 : 1)" 2>/dev/null' || failed=1
    check_item "bundler" 'command -v bundle || gem list bundler -i 2>/dev/null' || warn_q "bundler not installed (will install during setup)"
    
    echo -e "${BOLD}── Security Tools ──${NC}"
    check_item "nmap" 'command -v nmap' || warn_q "nmap not installed (will install)"
    check_item "msfconsole" 'command -v msfconsole' || warn_q "Metasploit not installed (will install)"
    check_item "msfvenom" 'command -v msfvenom' || warn_q "msfvenom not installed (will install)"
    
    echo -e "${BOLD}── Database ──${NC}"
    check_item "PostgreSQL client (psql)" 'command -v psql' || warn_q "PostgreSQL client not installed"
    check_item "pg_isready" 'command -v pg_isready' || warn_q "pg_isready not found"
    
    echo -e "${BOLD}── Go/Python ──${NC}"
    check_item "go" 'command -v go' || warn_q "Go not installed (needed for Sliver, etc.)"
    check_item "python3" 'command -v python3' || failed=1
    check_item "pip/pipx" 'command -v pip3 || command -v pipx' || warn_q "pip not found"
    
    # Disk space
    echo -e "${BOLD}── Resources ──${NC}"
    local avail_kb
    avail_kb=$(df -k "$HOME" 2>/dev/null | tail -1 | awk '{print $4}' || echo 0)
    local avail_gb=$((avail_kb / 1024 / 1024))
    if [[ $avail_gb -ge 5 ]]; then
        log_q "Disk space: ${avail_gb}GB available ✓"
    elif [[ $avail_gb -ge 2 ]]; then
        warn_q "Disk space: ${avail_gb}GB — tight but workable"
    else
        err_q "Disk space: ${avail_gb}GB — INSUFFICIENT (need 2GB+)"
        failed=1
    fi
    
    # Memory
    local mem_kb
    mem_kb=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}' || echo 0)
    local mem_gb=$((mem_kb / 1024 / 1024))
    if [[ $mem_gb -ge 2 ]]; then
        log_q "RAM: ${mem_gb}GB ✓"
    elif [[ $mem_gb -ge 1 ]]; then
        warn_q "RAM: ${mem_gb}GB — minimum met"
    else
        err_q "RAM: ${mem_gb}GB — INSUFFICIENT"
        failed=1
    fi
    
    # Network
    echo -e "${BOLD}── Network ──${NC}"
    if curl -sf --connect-timeout 5 https://github.com >/dev/null 2>&1; then
        log_q "Internet: GitHub reachable ✓"
    else
        warn_q "Internet: GitHub NOT reachable — may fail to download"
    fi
    
    echo ""
    if [[ $failed -eq 0 ]]; then
        log_q "All critical checks PASSED"
        return 0
    else
        err_q "$failed critical check(s) FAILED"
        return 1
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
