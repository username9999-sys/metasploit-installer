#!/usr/bin/env bash
# ==============================================================================
# COMMON LIBRARY — Shared helpers, colors, and utilities (FULLY FIXED)
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# ==============================================================================

# ── Colors ────────────────────────────────────────────────────────────────────
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export BOLD='\033[1m'
export DIM='\033[2m'
export NC='\033[0m'

# ── Logging ───────────────────────────────────────────────────────────────────
log()   { echo -e "  ${GREEN}[✓]${NC} $*"; }
info()  { echo -e "  ${BLUE}[*]${NC} $*"; }
warn()  { echo -e "  ${YELLOW}[!]${NC} $*" >&2; }
err()   { echo -e "  ${RED}[✗]${NC} $*" >&2; }
step()  { echo -e "\n${CYAN}${BOLD}[≡] $*${NC}\n"; }
title() { echo -e "${MAGENTA}${BOLD}$*${NC}"; }

# ── User Interaction ──────────────────────────────────────────────────────────
ask_yesno() {
    local prompt="${1:-Continue?}" default="${2:-y}"
    local hint; [[ "$default" == "y" ]] && hint="[Y/n]" || hint="[y/N]"
    local answer
    read -r -p "  [?] $prompt $hint: " answer
    answer="${answer:-$default}"
    [[ "${answer,,}" == "y" || "${answer,,}" == "yes" ]]
}

# ── Command & Package Helpers ──────────────────────────────────────────────────
cmd_exists() { command -v "$1" &>/dev/null; }

ensure_cmd() {
    local tool="$1" install_hint="${2:-}"
    if cmd_exists "$tool"; then
        log "$tool found: $(command -v "$tool")"
        return 0
    else
        warn "$tool NOT found"
        [[ -n "$install_hint" ]] && info "Install: $install_hint"
        return 1
    fi
}

# ── Permission & Privilege Detection ──────────────────────────────────────────
is_root() { [[ "${EUID:-$(id -u)}" -eq 0 ]]; }
has_sudo() { cmd_exists sudo && sudo -n true 2>/dev/null; }

# Returns: "root" | "sudo" | "normal"
user_mode() {
    if is_root; then echo "root"
    elif has_sudo; then echo "sudo"
    else echo "normal"
    fi
}

# SAFE: Run a command with appropriate privileges - NO EVAL
# Usage: priv_run apt-get update
#        priv_run apt-get install -y package
#        priv_run systemctl start postgresql
priv_run() {
    local cmd=("$@")
    case "$(user_mode)" in
        root)   "${cmd[@]}" ;;
        sudo)   sudo "${cmd[@]}" ;;
        normal) "${cmd[@]}" 2>/dev/null || {
                    warn "Cannot run privileged command: ${cmd[*]}"
                    info "You may need to run as root/sudo manually"
                    return 1
                } ;;
    esac
}

# ── File & Path Utilities ─────────────────────────────────────────────────────
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$LIB_DIR")"

resolve_path() {
    local path="$1"
    [[ "$path" == /* ]] && echo "$path" || echo "$PROJECT_DIR/$path"
}

# Secure a file (chmod 600)
secure_file() {
    local file="$1"
    [[ -f "$file" ]] && chmod 600 "$file" 2>/dev/null
}

# ── Safe Config Loader (FIXES RCE) ────────────────────────────────────────────
# Only loads KEY=VALUE pairs, ignores comments and arbitrary code
# Usage: safe_load_config "/path/to/config.env"
safe_load_config() {
    local config_file="$1"
    [[ -f "$config_file" ]] || return 1
    
    while IFS='=' read -r key val; do
        # Skip comments and empty lines
        [[ -z "$key" ]] && continue
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        
        # Only allow valid env var names: UPPER_CASE with underscores
        if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
            # Remove inline comments from value
            val="${val%%#*}"
            val="${val%%*( )}"  # trim trailing spaces
            export "$key=$val"
        fi
    done < <(grep -E '^[A-Z_][A-Z0-9_]*=' "$config_file" 2>/dev/null || true)
}

# ── Termux Detection & Fixes ──────────────────────────────────────────────────
is_termux() { [[ -d "/data/data/com.termux" ]] || cmd_exists termux-info 2>/dev/null; }

termux_fix_env() {
    if is_termux; then
        info "Termux detected — applying environment fixes..."
        
        # Fix PATH for termux
        export PATH="$PREFIX/bin:$PATH"
        
        # pg_config path fix (common issue)
        if cmd_exists pg_config; then
            log "pg_config: $(command -v pg_config)"
            export PG_CONFIG="$(command -v pg_config)"
        else
            warn "pg_config not found — pg gem install may fail"
            info "Install: pkg install postgresql-dev"
        fi
        
        # Termux: set LD_LIBRARY_PATH for ruby pg gem
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-$PREFIX/lib}"
        
        # Termux: fix TMPDIR
        export TMPDIR="${TMPDIR:-$PREFIX/tmp}"
        
        # Termux: no systemctl, use service commands
        export TERMUX_NO_SYSTEMD=1
    fi
}

# ── Run all bridge checks ─────────────────────────────────────────────────────
bridge_all() {
    bridge_check
    termux_fix_env
}

# ── Trap & Cleanup ────────────────────────────────────────────────────────────
on_exit() {
    local exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        log "Done."
    else
        warn "Exited with code: $exit_code"
    fi
}
trap on_exit EXIT
