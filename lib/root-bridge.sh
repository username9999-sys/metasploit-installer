#!/usr/bin/env bash
# ==============================================================================
# ROOT BRIDGE — Safe execution for both root and non-root users (FIXED)
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/root-bridge.sh"
# ==============================================================================
ROOT_BRIDGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_BRIDGE_DIR/common.sh" 2>/dev/null || true

# ── Check if running as root ──────────────────────────────────────────────────
ROOT_BRIDGE_WARNED=false

bridge_check() {
    if is_root; then
        warn "=============================================================="
        warn "  RUNNING AS ROOT — PostgreSQL initdb and Ruby gems MAY FAIL"
        warn "=============================================================="
        warn ""
        warn "  initdb refuses to run as root (security restriction)"
        warn "  Some Ruby gems also refuse to install as root"
        warn ""
        info "  SOLUTION: Create a normal user and run this script as that user"
        info ""
        info "  Quick fix:"
        info "    useradd -m -s /bin/bash msfuser"
        info "    su - msfuser"
        info "    cd \$(pwd) && bash setup-metasploit.sh"
        info ""

        if ask_yesno "Continue anyway? (likely to fail)" "n"; then
            ROOT_BRIDGE_WARNED=true
            return 0
        else
            info "Exiting. Create a user and re-run."
            exit 0
        fi
    fi
}

# ── Create a safe non-root user for PostgreSQL ─────────────────────────────────
bridge_create_user() {
    local username="${1:-msfuser}"

    if ! is_root; then
        warn "Cannot create user — not running as root"
        return 1
    fi

    if id "$username" &>/dev/null; then
        log "User '$username' already exists"
    else
        info "Creating user '$username'..."
        useradd -m -s /bin/bash "$username" 2>/dev/null || {
            err "Failed to create user '$username'"
            return 1
        }
        log "User '$username' created"
    fi

    local target="/home/${username}/$(basename "$(pwd)")"
    if [[ ! -d "$target" ]]; then
        info "Copying project to /home/${username}/..."
        cp -r "$(pwd)" "/home/${username}/" 2>/dev/null || warn "Could not copy — user will need to clone manually"
    fi
    chown -R "$username:$username" "/home/${username}/$(basename "$(pwd)")" 2>/dev/null || true

    echo ""
    info "Now switch to the user and re-run:"
    echo -e "  ${BOLD}su - ${username}${NC}"
    echo -e "  ${BOLD}cd $(basename "$(pwd)") && bash setup-metasploit.sh${NC}"
    echo ""

    return 0
}

# ── Fix PostgreSQL permissions after initdb (root-broken scenario) ─────────────
bridge_fix_pg_perms() {
    local data_dir="${1:-$HOME/.msf4/postgres}"

    if [[ -f "$data_dir/PG_VERSION" ]]; then
        local owner
        owner=$(stat -c '%U' "$data_dir/PG_VERSION" 2>/dev/null || echo "")
        if [[ "$owner" == "root" && ! $(is_root) ]]; then
            warn "PG data owned by root — fixing ownership..."
            sudo chown -R "$(whoami):$(whoami)" "$data_dir" 2>/dev/null || {
                err "Failed to fix ownership. Run: sudo chown -R \$(whoami):\$(whoami) $data_dir"
                return 1
            }
            log "Ownership fixed: $data_dir"
        fi
    fi
}

# ── Environment fixups for Termux ─────────────────────────────────────────────
bridge_termux_fix() {
    if is_termux; then
        info "Termux detected — applying fixes..."

        if ! termux-setup-storage --help &>/dev/null 2>&1; then
            warn "termux-setup-storage may not be available"
        fi

        if command -v pg_config &>/dev/null; then
            log "pg_config: $(command -v pg_config)"
        else
            warn "pg_config not found — pg gem install may fail"
            info "Install: pkg install postgresql-dev"
        fi

        export PG_CONFIG="${PG_CONFIG:-$(command -v pg_config 2>/dev/null || echo '')}"
        
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-/data/data/com.termux/files/usr/lib}"
        
        export TMPDIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
    fi
}

# ── Run all bridge checks ─────────────────────────────────────────────────────
bridge_all() {
    bridge_check
    bridge_termux_fix

    if is_root && [[ "$ROOT_BRIDGE_WARNED" == "true" ]]; then
        echo ""
        if ask_yesno "Create a normal user 'msfuser' to continue?" "y"; then
            bridge_create_user "msfuser"
            exit 0
        fi
    fi
}
