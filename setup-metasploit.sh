#!/usr/bin/env bash
# ============================================================================
# Metasploit Framework Auto-Installer & Setup Wizard (FULLY FIXED FOR TERMUX/NON-ROOT)
# ============================================================================
# Supports: Debian/Ubuntu/Kali, Fedora/RHEL, Arch, SUSE, Termux (non-root)
# ============================================================================

set -euo pipefail
IFS=$'\n\t'

SCRIPT_VERSION="2.1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Defaults ---
MSF_INSTALL_DIR="${MSF_INSTALL_DIR:-$HOME/metasploit-framework}"
MSF_DIR="${MSF_DIR:-$HOME/.msf4}"
MSF_BRANCH="${MSF_BRANCH:-main}"
MSF_USER="${MSF_USER:-msf}"
MSF_DB="${MSF_DB:-msf}"
MSF_PASS="${MSF_PASS:-}"
PG_PORT="${PG_PORT:-5432}"
USE_PASSWORD="${USE_PASSWORD:-true}"
INTERACTIVE=true
STATE_FILE="$HOME/.msf-setup-state"

# --- PostgreSQL runtime ---
PG_HOST="${PG_HOST:-127.0.0.1}"
PG_SUPERUSER="${PG_SUPERUSER:-}"
PG_SUPERUSER_PASS="${PG_SUPERUSER_PASS:-}"
PG_MODE="${PG_MODE:-}"
PG_DATA_DIR="${PG_DATA_DIR:-$HOME/.msf4/postgres}"
PG_RUNNING_PORT="${PG_RUNNING_PORT:-}"
HAS_PGISREADY=false

# --- Colors ---
: "${RED:=\033[0;31m}"; : "${GREEN:=\033[0;32m}"; : "${YELLOW:=\033[1;33m}"
: "${BLUE:=\033[0;34m}"; : "${MAGENTA:=\033[0;35m}"; : "${CYAN:=\033[0;36m}"
: "${BOLD:=\033[1m}"; : "${DIM:=\033[2m}"; : "${NC:=\033[0m}"

#==============================================================================
# HELPER FUNCTIONS
#==============================================================================
log() { echo -e "${GREEN}[✓]${NC} $*"; }
info() { echo -e "${BLUE}[*]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err() { echo -e "${RED}[✗]${NC} $*" >&2; }
step() { echo -e "\n${CYAN}${BOLD}═══ $* ═══${NC}\n"; }

ask_yesno() {
    local prompt="${1:-Continue?}" default="${2:-y}"
    local yn="[y/N]"; [[ "$default" =~ ^[Yy]$ ]] && yn="[Y/n]"
    local reply
    read -r -p "  [?] ${prompt} ${yn}: " reply
    reply="${reply:-$default}"
    [[ "$reply" =~ ^[Yy]$ ]]
}

ask_input() {
    local prompt="$1" default="${2:-}" reply
    read -r -p "  [?] ${prompt} [${default}]: " reply
    echo "${reply:-$default}"
}

ask_password() {
    local prompt="${1:-Enter password}" pass1 pass2
    while true; do
        read -r -s -p "  [?] ${prompt}: " pass1; echo
        read -r -s -p "  [?] Confirm: " pass2; echo
        [[ "$pass1" == "$pass2" ]] && { echo "$pass1"; return; }
        warn "Passwords don't match - try again"
    done
}

# --- Termux Detection ---
is_termux() { [[ -d "/data/data/com.termux" ]] && [[ -n "${PREFIX:-}" ]]; }

# --- User Mode Detection ---
is_root() { [[ "${EUID:-$(id -u)}" -eq 0 ]]; }
has_sudo() { command -v sudo &>/dev/null && sudo -n true 2>/dev/null; }
user_mode() { if is_root; then echo "root"; elif has_sudo; then echo "sudo"; else echo "normal"; fi; }

# Safe privileged command execution
priv_run() {
    case "$(user_mode)" in
        root)   "$@" ;;
        sudo)   sudo "$@" ;;
        normal) "$@" 2>/dev/null || { warn "Need sudo for: $*"; return 1; } ;;
    esac
}

# Save state (KEY=VALUE format, safe)
save_state() {
    local pass_b64=""
    [[ -n "$MSF_PASS" ]] && pass_b64=$(echo -n "$MSF_PASS" | base64)
    cat > "$STATE_FILE" << EOF
MSF_INSTALL_DIR="$MSF_INSTALL_DIR"
MSF_DIR="$MSF_DIR"
MSF_BRANCH="$MSF_BRANCH"
MSF_USER="$MSF_USER"
MSF_DB="$MSF_DB"
MSF_PASS_B64="$pass_b64"
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

load_state() {
    [[ -f "$STATE_FILE" ]] && { source "$STATE_FILE"; [[ -n "${MSF_PASS_B64:-}" && -z "${MSF_PASS:-}" ]] && MSF_PASS=$(echo -n "$MSF_PASS_B64" | base64 -d 2>/dev/null || true); log "Loaded state from $STATE_FILE"; }
}

#==============================================================================
# INTERACTIVE WIZARD
#==============================================================================
run_wizard() {
    step "Metasploit Setup Wizard v${SCRIPT_VERSION}"
    cat << WIZ

  This wizard configures Metasploit Framework with PostgreSQL.
  Works on: Ubuntu/Debian/Kali, Fedora/RHEL, Arch, Termux (non-root)

WIZ
    MSF_INSTALL_DIR=$(ask_input "Metasploit install directory" "$MSF_INSTALL_DIR")
    MSF_DIR=$(ask_input "Metasploit config directory (~/.msf4)" "$MSF_DIR")

    echo ""
    if ask_yesno "Use password authentication for PostgreSQL?" "y"; then
        USE_PASSWORD="true"
        MSF_PASS=$(ask_password "PostgreSQL / Metasploit DB password")
        MSF_USER=$(ask_input "Database username" "$MSF_USER")
        MSF_DB=$(ask_input "Database name" "$MSF_DB")
    else
        USE_PASSWORD="false"; MSF_PASS=""
        MSF_USER=$(ask_input "Database username (trust auth)" "$MSF_USER")
        MSF_DB=$(ask_input "Database name" "$MSF_DB")
    fi

    MSF_BRANCH=$(ask_input "Metasploit Git branch (main = latest, or specific tag)" "$MSF_BRANCH")

    echo ""; echo -e "  ${BOLD}Summary:${NC}"
    echo -e "    Install: ${MSF_INSTALL_DIR} | Config: ${MSF_DIR}"
    echo -e "    DB: ${MSF_USER}@${MSF_DB} | Pass: $([[ -n "$MSF_PASS" ]] && echo "***" || echo "trust") | Branch: ${MSF_BRANCH}"
    echo ""
    ask_yesno "Proceed with installation?" "y" || { info "Cancelled"; exit 0; }
}

#==============================================================================
# ENVIRONMENT DETECTION
#==============================================================================
detect_environment() {
    step "Detecting Environment"

    if is_termux; then
        DISTRO_SLOT=1; PKG_MGR="pkg"; PKG_CHECK="dpkg"
        export PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
        export PATH="$PREFIX/bin:$PATH"
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-$PREFIX/lib}"
        info "Termux detected (non-root)"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release 2>/dev/null || true
        case "${ID:-}" in
            ubuntu|debian|kali|linuxmint|pop|elementary|zorin|raspbian|parrot)
                DISTRO_SLOT=0; PKG_MGR="apt"; PKG_CHECK="dpkg" ;;
            fedora|rhel|centos|rocky|almalinux|ol)
                DISTRO_SLOT=2; PKG_MGR="dnf"; PKG_CHECK="rpm"; command -v dnf &>/dev/null || PKG_MGR="yum" ;;
            arch|manjaro|endeavouros|garuda|arcolinux)
                DISTRO_SLOT=3; PKG_MGR="pacman"; PKG_CHECK="pacman" ;;
            opensuse*|sles)
                DISTRO_SLOT=4; PKG_MGR="zypper"; PKG_CHECK="rpm" ;;
            *)
                warn "Unknown distro: ${ID:-unknown} - assuming Debian/Ubuntu"
                DISTRO_SLOT=0; PKG_MGR="apt"; PKG_CHECK="dpkg" ;;
        esac
        info "Distro: ${PRETTY_NAME:-$ID} (slot: $DISTRO_SLOT, mgr: $PKG_MGR)"
    else
        warn "Cannot detect OS - assuming Debian/Ubuntu"
        DISTRO_SLOT=0; PKG_MGR="apt"; PKG_CHECK="dpkg"
    fi

    # Detect existing PostgreSQL
    if command -v pg_isready &>/dev/null; then
        HAS_PGISREADY=true
        for p in 5432 5433 5434 5435 15432 54321; do
            if pg_isready -h 127.0.0.1 -p "$p" -q 2>/dev/null; then PG_RUNNING_PORT="$p"; info "PostgreSQL on port $p"; break; fi
        done
        if [[ -z "${PG_RUNNING_PORT:-}" ]]; then
            if pg_isready -q 2>/dev/null; then PG_RUNNING_PORT="5432"; info "PostgreSQL via Unix socket"; fi
        fi
        # Termux: try localhost
        if [[ -z "${PG_RUNNING_PORT:-}" && $(is_termux; echo $?) -eq 0 ]]; then
            for p in 5432 5433; do pg_isready -h localhost -p "$p" -q 2>/dev/null && { PG_RUNNING_PORT="$p"; info "PostgreSQL on localhost:$p (Termux)"; break; }; done
        fi
    elif command -v pg_ctl &>/dev/null; then
        for d in /var/lib/postgresql/*/main "$HOME/.msf4/postgres" "$HOME/db_data"; do
            [[ -d "$d" ]] && pg_ctl -D "$d" status 2>/dev/null | grep -q "running" && { info "PostgreSQL running at $d"; break; }
        done
    fi

    for t in git curl; do command -v "$t" &>/dev/null || INSTALL_DEPS=("$t"); done
}

#==============================================================================
# PACKAGE HELPERS
#==============================================================================
_pkg_is_installed() {
    case "$PKG_CHECK" in
        dpkg) dpkg -s "$1" &>/dev/null ;;
        rpm)  rpm -q "$1" &>/dev/null ;;
        pacman) pacman -Q "$1" &>/dev/null ;;
        *) return 0 ;;
    esac
}

_pkg_available() {
    case "$PKG_MGR" in
        pkg)     pkg search "$1" 2>/dev/null | grep -q "^${1}/" ;;
        apt)     apt-cache show "$1" &>/dev/null ;;
        dnf|yum) $PKG_MGR list "$1" &>/dev/null ;;
        zypper)  zypper search -x "$1" &>/dev/null ;;
        pacman)  pacman -Si "$1" &>/dev/null ;;
        *)       return 1 ;;
    esac
}

#==============================================================================
# PHASE 1 - SYSTEM DEPENDENCIES
#==============================================================================
install_dependencies() {
    step "Phase 1: System Dependencies"

    declare -A PKG_MAP=(
        [ruby]="ruby ruby ruby ruby"
        [ruby-dev]="ruby-dev ruby-dev ruby-devel ruby"
        [postgresql]="postgresql postgresql postgresql-server postgresql"
        [postgresql-client]="postgresql-client postgresql postgresql postgresql"
        [postgresql-dev]="libpq-dev postgresql-dev postgresql-devel postgresql"
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

    local pkgs_to_install=""
    for logical in $(printf '%s\n' "${!PKG_MAP[@]}" | sort); do
        local slot_pkg=""
        case $DISTRO_SLOT in
            0) slot_pkg="${PKG_MAP[$logical]%% *}" ;;
            1) slot_pkg="${PKG_MAP[$logical]#* }"; slot_pkg="${slot_pkg%% *}" ;;
            2) slot_pkg="${PKG_MAP[$logical]#* * }"; slot_pkg="${slot_pkg%% *}" ;;
            3) slot_pkg="${PKG_MAP[$logical]##* }" ;;
            *) slot_pkg="${PKG_MAP[$logical]%% *}" ;;
        esac
        [[ -z "$slot_pkg" || "$slot_pkg" == "-" ]] && continue

        if [[ "$slot_pkg" == *,* ]]; then
            IFS=',' read -ra alts <<< "$slot_pkg"
            for alt in "${alts[@]}"; do _pkg_available "$alt" && { slot_pkg="$alt"; break; }; done
        fi

        _pkg_is_installed "$slot_pkg" || pkgs_to_install="$pkgs_to_install $slot_pkg"
    done

    # PostgreSQL server
    local pg_server_pkg
    case $DISTRO_SLOT in
        0|1) pg_server_pkg="postgresql" ;;
        2|4) pg_server_pkg="postgresql-server" ;;
        3) pg_server_pkg="postgresql" ;;
    esac
    if ! command -v pg_ctl &>/dev/null || ! command -v initdb &>/dev/null; then
        _pkg_is_installed "$pg_server_pkg" || pkgs_to_install="$pkgs_to_install $pg_server_pkg"
    else
        log "PostgreSQL binaries found - skipping server package"
    fi

    pkgs_to_install=$(echo "$pkgs_to_install" | xargs)

    if [[ -z "$pkgs_to_install" ]]; then
        log "All packages already installed"
    else
        info "Installing: $pkgs_to_install"
        case "$PKG_MGR" in
            pkg)
                pkg update -qq 2>/dev/null || warn "Update failed"
                for p in $pkgs_to_install; do info "  Installing $p"; pkg install -y "$p" 2>&1 | tail -3 || warn "Failed: $p"; done ;;
            apt)
                apt-get update -qq 2>/dev/null || warn "Update failed"
                apt-get install -y $pkgs_to_install 2>&1 | tail -15 || {
                    warn "Retrying individually..."
                    for p in $pkgs_to_install; do apt-get install -y "$p" 2>/dev/null || warn "  Failed: $p"; done
                } ;;
            dnf|yum)
                $PKG_MGR install -y $pkgs_to_install 2>&1 | tail -15 || {
                    for p in $pkgs_to_install; do $PKG_MGR install -y "$p" 2>/dev/null || warn "  Failed: $p"; done
                } ;;
            zypper)
                zypper --non-interactive install $pkgs_to_install 2>&1 | tail -15 || {
                    for p in $pkgs_to_install; do zypper --non-interactive install "$p" 2>/dev/null || warn "  Failed: $p"; done
                } ;;
            pacman)
                pacman -Sy --noconfirm --needed $pkgs_to_install 2>&1 | tail -15 || {
                    for p in $pkgs_to_install; do pacman -S --noconfirm --needed "$p" 2>/dev/null || warn "  Failed: $p"; done
                } ;;
        esac
        log "Package installation complete"
        fi

    # PostgreSQL fallback: if pg_ctl/initdb not available, try source compile
    if ! command -v pg_ctl &>/dev/null || ! command -v initdb &>/dev/null; then
        warn "PostgreSQL binaries missing - attempting source compilation fallback..."
        compile_postgresql_from_source || warn "Source compilation failed - manual install may be needed"
    fi
}
#==============================================================================
compile_postgresql_from_source() {
    step "Phase X: PostgreSQL Source Compilation (no-sudo fallback)"
    
    local PG_VERSION="${PG_VERSION:-16.2}"
    local PG_SRC_URL="https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.gz"
    local BUILD_DIR="$HOME/postgresql-build"
    local INSTALL_DIR="$HOME/postgresql"
    
    info "Building PostgreSQL ${PG_VERSION} from source (no sudo required)..."
    
    # Check for build dependencies
    local build_deps=("gcc" "make" "libreadline-dev" "zlib1g-dev" "libssl-dev" "libxml2-dev" "libxslt-dev" "flex" "bison")
    local missing_deps=()
    
    for dep in "${build_deps[@]}"; do
        if ! _pkg_is_installed "$dep"; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        warn "Missing build dependencies: ${missing_deps[*]}"
        if [[ "$(user_mode)" == "normal" ]]; then
            warn "Cannot install build deps without sudo. Attempting to find alternatives..."
            # Try to use pkg-config if available
            command -v pkg-config &>/dev/null || { err "pkg-config needed for compilation"; return 1; }
        else
            info "Installing build dependencies..."
            case "$PKG_MGR" in
                apt)    apt-get update -qq && apt-get install -y "${missing_deps[@]}" 2>&1 | tail -5 ;;
                pkg)    pkg install -y "${missing_deps[@]}" 2>&1 | tail -5 ;;
                dnf)    dnf install -y "${missing_deps[@]}" 2>&1 | tail -5 ;;
                pacman) pacman -S --noconfirm "${missing_deps[@]}" 2>&1 | tail -5 ;;
                zypper) zypper --non-interactive install "${missing_deps[@]}" 2>&1 | tail -5 ;;
            esac
        fi
    fi
    
    # Download source
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    if [[ ! -f "postgresql-${PG_VERSION}.tar.gz" ]]; then
        info "Downloading PostgreSQL ${PG_VERSION}..."
        curl -fsSL -o "postgresql-${PG_VERSION}.tar.gz" "$PG_SRC_URL" || { err "Download failed"; return 1; }
    fi
    
    if [[ ! -d "postgresql-${PG_VERSION}" ]]; then
        info "Extracting..."
        tar -xzf "postgresql-${PG_VERSION}.tar.gz" || { err "Extract failed"; return 1; }
    fi
    
    # Configure
    info "Configuring..."
    cd "postgresql-${PG_VERSION}"
    ./configure \
        --prefix="$INSTALL_DIR" \
        --without-icu \
        --without-openssl \
        --without-readline \
        --without-zlib \
        2>&1 | tail -20 || { err "Configure failed"; return 1; }
    
    # Compile (this takes a while)
    info "Compiling (this takes 5-15 minutes)..."
    make -j"$(nproc 2>/dev/null || echo 4)" 2>&1 | tail -30 || { err "Build failed"; return 1; }
    
    # Install
    info "Installing to $INSTALL_DIR..."
    make install 2>&1 | tail -10 || { err "Install failed"; return 1; }
    
    # Add to PATH
    export PATH="$INSTALL_DIR/bin:$PATH"
    
    # Add to shell profiles
    for p in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        [[ -f "$p" ]] && ! grep -q "postgresql/bin" "$p" 2>/dev/null && echo 'export PATH="$HOME/postgresql/bin:$PATH"' >> "$p"
    done
    
    # Verify
    command -v initdb &>/dev/null && command -v pg_ctl &>/dev/null && command -v psql &>/dev/null || { err "Build incomplete"; return 1; }
    
    log "PostgreSQL ${PG_VERSION} built and installed to $INSTALL_DIR"
    log "Added to PATH in shell profiles"
    
    return 0
}

# Integrate into install_dependencies() - call this when postgresql packages fail
# PHASE 2 - POSTGRESQL SETUP
#==============================================================================
setup_postgresql() {
    step "Phase 2: PostgreSQL Setup"

    PG_HOST="127.0.0.1"
    PG_DATA_DIR="$HOME/.msf4/postgres"

    # Termux: use home directory, no system privileges needed
    if is_termux; then
        info "Termux: Using home directory PostgreSQL (no root needed)"
        PG_DATA_DIR="$HOME/db_data"
        PG_MODE="home"
    fi

    command -v psql &>/dev/null || { err "psql not found!"; exit 1; }
    command -v pg_isready &>/dev/null && HAS_PGISREADY=true

    # Check existing PostgreSQL
    if [[ -n "${PG_RUNNING_PORT:-}" ]]; then
        info "PostgreSQL running on port ${PG_RUNNING_PORT}"
        for u in postgres "$USER" root; do
            for d in template1 postgres template0; do
                if psql -h "$PG_HOST" -p "$PG_RUNNING_PORT" -U "$u" -d "$d" -c "SELECT 1" >/dev/null 2>&1; then
                    PG_SUPERUSER="$u"; PG_PORT="$PG_RUNNING_PORT"; PG_MODE="existing"
                    log "Using existing PG - superuser: $PG_SUPERUSER"; break 2
                fi
            done
        done
    fi

    # Try Unix socket (Termux)
    if [[ "${PG_MODE:-}" != "existing" ]]; then
        for u in "" postgres "$USER"; do
            for d in template1 postgres template0; do
                if psql ${u:+-U "$u"} -d "$d" -c "SELECT 1" >/dev/null 2>&1; then
                    PG_SUPERUSER="${u:-$(whoami)}"; PG_PORT="5432"; PG_MODE="existing"; PG_HOST=""
                    log "PG via Unix socket - user: $PG_SUPERUSER"; break 2
                fi
            done
        done
    fi

    # No existing PG: create new in home
    if [[ "${PG_MODE:-}" != "existing" ]]; then
        echo ""
        echo -e "  ${YELLOW}${BOLD}No running PostgreSQL - creating new instance in $HOME${NC}"
        echo ""

        mkdir -p "$PG_DATA_DIR"

        if [[ -f "${PG_DATA_DIR}/PG_VERSION" ]]; then
            warn "Data dir exists: $PG_DATA_DIR"
            ask_yesno "Use existing?" "y" || { warn "Remove $PG_DATA_DIR and re-run"; exit 1; }
        else
            info "Initializing PostgreSQL..."
            initdb "$PG_DATA_DIR" 2>&1 | tail -10 || { err "initdb failed!"; [[ "$EUID" -eq 0 ]] && err "Running as root causes initdb to fail - in real Termux (non-root) this works."; exit 1; }
        fi

        # Configure pg_hba.conf
        local AUTH_METHOD="md5"; [[ -z "$MSF_PASS" ]] && AUTH_METHOD="trust"
        cat > "${PG_DATA_DIR}/pg_hba.conf" << HBACONF
local   all     all                         ${AUTH_METHOD}
host    all     all         127.0.0.1/32    ${AUTH_METHOD}
host    all     all         ::1/128         ${AUTH_METHOD}
HBACONF

        # Start PostgreSQL
        info "Starting PostgreSQL..."
        pg_ctl -D "$PG_DATA_DIR" -l "${PG_DATA_DIR}/pg.log" start 2>&1 || { err "pg_ctl start failed! Check log"; exit 1; }

        for i in {1..30}; do
            if [[ "$HAS_PGISREADY" == "true" ]]; then pg_isready -p "$PG_PORT" -q 2>/dev/null && break; fi
            psql -p "$PG_PORT" -d postgres -c "SELECT 1" &>/dev/null && break
            sleep 1
        done
        log "PostgreSQL started on ${PG_HOST:-localhost}:${PG_PORT}"

        PG_SUPERUSER="$(whoami)"
        PG_MODE="home"

        # Create helper scripts
        mkdir -p "$HOME/bin"
        cat > "$HOME/bin/pg-start" << 'PGSTART'
#!/usr/bin/env bash
DATA_DIR="${PG_DATA_DIR:-$HOME/.msf4/postgres}"
PG_PORT="${PG_PORT:-5432}"
[[ -f "${DATA_DIR}/PG_VERSION" ]] || { echo "[✗] Invalid data dir"; exit 1; }
command -v pg_ctl &>/dev/null || { echo "[✗] pg_ctl not found"; exit 1; }
cd "$HOME"
pg_ctl -D "${DATA_DIR}" -l "${DATA_DIR}/pg.log" start 2>/dev/null || { echo "[✗] Failed"; exit 1; }
for i in {1..15}; do command -v pg_isready &>/dev/null && pg_isready -p "${PG_PORT}" -q && break; psql -p "${PG_PORT}" -d postgres -c "SELECT 1" &>/dev/null && break; sleep 1; done
echo "[✓] PostgreSQL ready on localhost:${PG_PORT}"
PGSTART
        cat > "$HOME/bin/pg-stop" << 'PGSTOP'
#!/usr/bin/env bash
DATA_DIR="${PG_DATA_DIR:-$HOME/.msf4/postgres}"
command -v pg_ctl &>/dev/null || { echo "[✗] pg_ctl not found"; exit 1; }
[[ -f "${DATA_DIR}/PG_VERSION" ]] || { echo "[*] Nothing to stop"; exit 0; }
pg_ctl -D "${DATA_DIR}" stop 2>/dev/null && echo "[✓] Stopped" || echo "[*] Not running"
PGSTOP
        sed -i "s|\${PG_DATA_DIR}|${PG_DATA_DIR}|g" "$HOME/bin/pg-start"
        sed -i "s|\${PG_PORT}|${PG_PORT}|g" "$HOME/bin/pg-start"
        sed -i "s|\${PG_DATA_DIR}|${PG_DATA_DIR}|g" "$HOME/bin/pg-stop"
        chmod +x "$HOME/bin/pg-start" "$HOME/bin/pg-stop"
        log "Helpers: ~/bin/pg-start, ~/bin/pg-stop"
    fi

    # Create MSF user & database
    info "Creating Metasploit user & database..."
    local PSQL_CMD=""
    if [[ "$PG_MODE" == "existing" ]]; then
        [[ -z "$PG_HOST" ]] && PSQL_CMD="psql -U ${PG_SUPERUSER} -d template1" || PSQL_CMD="psql -h ${PG_HOST} -p ${PG_PORT} -U ${PG_SUPERUSER} -d template1"
    else
        PSQL_CMD="psql -p ${PG_PORT} -d postgres"
    fi

    # Create role
    $PSQL_CMD -tAc "SELECT 1 FROM pg_roles WHERE rolname='${MSF_USER}'" 2>/dev/null | grep -q 1 && log "Role exists" || {
        if [[ -n "$MSF_PASS" ]]; then
            $PSQL_CMD -c "CREATE ROLE ${MSF_USER} LOGIN PASSWORD '${MSF_PASS}'" 2>/dev/null || { warn "With password failed"; $PSQL_CMD -c "CREATE ROLE ${MSF_USER} LOGIN" 2>/dev/null || { err "Create role failed"; exit 1; }; }
        else
            $PSQL_CMD -c "CREATE ROLE ${MSF_USER} LOGIN" 2>/dev/null || { err "Create role failed"; exit 1; }
        fi
        log "Role ${MSF_USER} created"
    }

    # Create database
    $PSQL_CMD -tAc "SELECT 1 FROM pg_database WHERE datname='${MSF_DB}'" 2>/dev/null | grep -q 1 && log "Database exists" || {
        $PSQL_CMD -c "CREATE DATABASE ${MSF_DB} OWNER ${MSF_USER}" 2>/dev/null || { err "Create DB failed"; exit 1; }
        log "Database ${MSF_DB} created"
    }
    $PSQL_CMD -c "GRANT ALL PRIVILEGES ON DATABASE ${MSF_DB} TO ${MSF_USER}" 2>/dev/null || true

    # Test connection
    local ok=false
    if [[ -n "$MSF_PASS" ]]; then
        [[ -z "$PG_HOST" ]] && PGPASSWORD="$MSF_PASS" psql -U "$MSF_USER" -d "$MSF_DB" -c "SELECT 1" &>/dev/null && ok=true
        PGPASSWORD="$MSF_PASS" psql -h "${PG_HOST:-127.0.0.1}" -p "$PG_PORT" -U "$MSF_USER" -d "$MSF_DB" -c "SELECT 1" &>/dev/null && ok=true
    else
        [[ -z "$PG_HOST" ]] && psql -U "$MSF_USER" -d "$MSF_DB" -c "SELECT 1" &>/dev/null && ok=true
        psql -h "${PG_HOST:-127.0.0.1}" -p "$PG_PORT" -U "$MSF_USER" -d "$MSF_DB" -c "SELECT 1" &>/dev/null && ok=true
    fi
    $ok && log "Connection verified ✓" || { warn "Connection test failed - will retry in msfconsole"; }
}

#==============================================================================
# PHASE 3 - METASPLOIT CLONE
#==============================================================================
install_metasploit() {
    step "Phase 3: Metasploit Framework"

    command -v git &>/dev/null || { err "git not installed"; exit 1; }

    if [[ -d "${MSF_INSTALL_DIR}/.git" ]]; then
        info "Updating existing repo..."
        cd "$MSF_INSTALL_DIR"
        git stash save "msf-setup-$(date +%s)" 2>/dev/null || true
        git fetch --all --prune 2>/dev/null || warn "fetch failed"
        git checkout "$MSF_BRANCH" 2>/dev/null || git checkout master 2>/dev/null || true
        git pull origin "$MSF_BRANCH" 2>/dev/null || warn "pull failed"
        log "Updated: ${MSF_INSTALL_DIR}"; return 0
    fi

    [[ -d "$MSF_INSTALL_DIR" ]] && { mv "$MSF_INSTALL_DIR" "${MSF_INSTALL_DIR}.bak.$(date +%s)"; log "Backed up old dir"; }

    mkdir -p "$(dirname "$MSF_INSTALL_DIR")"
    info "Cloning Metasploit Framework (~150MB)..."

    local ok=false
    for attempt in 1 2 3; do
        info "Attempt $attempt/3..."
        if git clone --depth=1 --branch "$MSF_BRANCH" https://github.com/rapid7/metasploit-framework.git "$MSF_INSTALL_DIR" 2>&1 | tail -5; then ok=true; break; fi
        [[ $attempt -lt 3 ]] && { warn "Retrying in 5s..."; sleep 5; rm -rf "$MSF_INSTALL_DIR" 2>/dev/null; }
    done

    $ok || {
        warn "Shallow clone failed - trying full clone..."
        rm -rf "$MSF_INSTALL_DIR" 2>/dev/null
        git clone https://github.com/rapid7/metasploit-framework.git "$MSF_INSTALL_DIR" 2>&1 | tail -5 && ok=true
        cd "$MSF_INSTALL_DIR" && git checkout "$MSF_BRANCH" 2>/dev/null || git checkout master 2>/dev/null || true
    }

    $ok || { err "Clone failed!"; info "Manual: git clone https://github.com/rapid7/metasploit-framework.git $MSF_INSTALL_DIR"; exit 1; }

    [[ -f "${MSF_INSTALL_DIR}/msfconsole" ]] || { err "Incomplete clone"; exit 1; }
    log "Source verified: ${MSF_INSTALL_DIR}"
}

#==============================================================================
# PHASE 4 - RUBY GEMS
#==============================================================================
install_gems() {
    step "Phase 4: Ruby Gems (Bundler)"

    cd "$MSF_INSTALL_DIR" || { err "Cannot cd"; return 1; }

    info "Installing pg gem..."
    gem install pg --no-document 2>/dev/null || warn "pg gem failed - will try via bundler"

    info "Installing bundler..."
    gem install bundler -v '~> 2.5' --no-document 2>/dev/null || gem install bundler --no-document 2>/dev/null || warn "bundler install failed"

    bundle config set --local path 'vendor/bundle' 2>/dev/null || true
    bundle config set --local without 'development test' 2>/dev/null || true
    bundle config set --local jobs "$(nproc 2>/dev/null || echo 4)" 2>/dev/null || true
    bundle config set --local retry 3 2>/dev/null || true

    echo ""; info "Running bundle install (5-15 min)..."; echo ""

    local max_tries=2; local try=1
    while [[ $try -le $max_tries ]]; do
        info "Bundle attempt $try/$max_tries..."
        if bundle install 2>&1 | tail -30; then log "Bundle complete"; break; fi
        warn "Bundle failed - retrying"
        rm -rf vendor/bundle 2>/dev/null; bundle config unset --local path 2>/dev/null
        ((try++))
    done
    [[ $try -gt $max_tries ]] && { warn "Bundle failed after retries - run manually: cd $MSF_INSTALL_DIR && bundle install"; }
}

#==============================================================================
# PHASE 5 - CONFIG FILES & LAUNCHERS
#==============================================================================
create_config_and_launchers() {
    step "Phase 5: Config Files & Launchers"

    mkdir -p "$MSF_DIR" "$HOME/bin" "$MSF_DIR/logs" "$MSF_DIR/loot"

    # database.yml
    cat > "$MSF_DIR/database.yml" << YAMLEOF
production:
  adapter: postgresql
  database: ${MSF_DB}
  username: ${MSF_USER}
  password: ${MSF_PASS}
  host: ${PG_HOST:-127.0.0.1}
  port: ${PG_PORT}
  pool: 75
  timeout: 5
YAMLEOF

    # config.yml
    cat > "$MSF_DIR/config.yml" << YAMLEOF
:msf_dir: "${MSF_INSTALL_DIR}"
:enable_database: true
:workspace: default
:log_level: info
:trace_console: false
:log_file: ${MSF_DIR}/logs/%R.log
:loot_dir: ${MSF_DIR}/loot
YAMLEOF

    # Fix permissions for security
    chmod 600 "$MSF_DIR/database.yml" "$MSF_DIR/config.yml" 2>/dev/null || true

    # msfconsole launcher
    cat > "$HOME/bin/msfconsole" << 'MSFCONEOF'
#!/usr/bin/env bash
INSTALL_DIR="${MSF_INSTALL_DIR}"
MSF_DIR="${MSF_DIR}"
MSF_USER="${MSF_USER}"
MSF_PASS="${MSF_PASS}"
PG_HOST="${PG_HOST:-127.0.0.1}"
PG_PORT="${PG_PORT}"
MSF_DB="${MSF_DB}"
PG_MODE="${PG_MODE}"
PG_DATA_DIR="${PG_DATA_DIR}"

cd "$INSTALL_DIR"

# Auto-start PostgreSQL if home mode
if [[ "$PG_MODE" == "home" ]]; then
    need_start=false
    if command -v pg_isready &>/dev/null; then
        pg_isready -p "$PG_PORT" -q 2>/dev/null || need_start=true
    else
        PGPASSWORD="$MSF_PASS" psql -p "$PG_PORT" -U "$MSF_USER" -d "$MSF_DB" -c "SELECT 1" &>/dev/null || need_start=true
    fi
    if [[ "$need_start" == "true" ]]; then
        echo "[*] PostgreSQL not running - auto-starting..."
        "$HOME/bin/pg-start"
        echo ""
    fi
fi

echo "┌─────────────────────────────────────────────┐"
echo "│  Metasploit Framework                       │"
echo "│  DB: ${MSF_USER}@${PG_HOST:-localhost}:${PG_PORT}/${MSF_DB}                  │"
echo "└─────────────────────────────────────────────┘"
echo "  Type 'db_status' to check database"
echo ""

exec bundle exec ./msfconsole "$@"
MSFCONEOF

    # msfvenom launcher
    cat > "$HOME/bin/msfvenom" << 'MSFVENEOF'
#!/usr/bin/env bash
INSTALL_DIR="${MSF_INSTALL_DIR}"
cd "$INSTALL_DIR"
exec bundle exec ./msfvenom "$@"
MSFVENEOF

    # msfdb launcher
    cat > "$HOME/bin/msfdb" << 'MSFDBEOF'
#!/usr/bin/env bash
echo "╔══════════════════════════════════════════════╗"
echo "║  Metasploit Database Status                  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Config: ${MSF_DIR}/database.yml"
cat "${MSF_DIR}/database.yml"
echo ""
echo "Quick connect:"
echo "  db_connect ${MSF_USER}:${MSF_PASS}@${PG_HOST:-127.0.0.1}:${PG_PORT}/${MSF_DB}"
echo ""
echo "PostgreSQL:"
if command -v pg_isready &>/dev/null; then
    pg_isready -p ${PG_PORT} -q 2>/dev/null && echo "  Status: [✓] Running on ${PG_HOST:-localhost}:${PG_PORT}" || echo "  Status: [✗] NOT running (run: pg-start)"
else
    PGPASSWORD="${MSF_PASS}" psql -p ${PG_PORT} -U ${MSF_USER} -d ${MSF_DB} -c "SELECT 1" &>/dev/null && echo "  Status: [✓] Running (verified)" || echo "  Status: [?] Unknown - try pg-start"
fi
echo ""
echo "Commands:"
echo "  msfconsole  → Start Metasploit"
echo "  msfvenom    → Payload generator"
echo "  msfdb       → Database status"
echo "  pg-start    → Start PostgreSQL"
echo "  pg-stop     → Stop PostgreSQL"
MSFDBEOF

    # Substitute placeholders
    for f in "$HOME/bin/msfconsole" "$HOME/bin/msfvenom" "$HOME/bin/msfdb"; do
        sed -i "s|\${MSF_INSTALL_DIR}|${MSF_INSTALL_DIR}|g" "$f"
        sed -i "s|\${MSF_DIR}|${MSF_DIR}|g" "$f"
        sed -i "s|\${MSF_USER}|${MSF_USER}|g" "$f"
        sed -i "s|\${MSF_PASS}|${MSF_PASS}|g" "$f"
        sed -i "s|\${PG_HOST}|${PG_HOST:-127.0.0.1}|g" "$f"
        sed -i "s|\${PG_PORT}|${PG_PORT}|g" "$f"
        sed -i "s|\${MSF_DB}|${MSF_DB}|g" "$f"
        sed -i "s|\${PG_MODE}|${PG_MODE}|g" "$f"
        sed -i "s|\${PG_DATA_DIR}|${PG_DATA_DIR}|g" "$f"
        chmod +x "$f"
    done

    # Add ~/bin to PATH
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        export PATH="$HOME/bin:$PATH"
        for p in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
            [[ -f "$p" ]] && ! grep -q 'PATH.*\$HOME/bin' "$p" 2>/dev/null && echo 'export PATH="$HOME/bin:$PATH"' >> "$p"
        done
    fi

    log "Launchers created: ~/bin/msfconsole, ~/bin/msfvenom, ~/bin/msfdb"
    [[ "$PG_MODE" == "home" ]] && log "PG helpers: ~/bin/pg-start, ~/bin/pg-stop"
}

#==============================================================================
# VERIFICATION
#==============================================================================
verify_installation() {
    step "Phase 6: Verification"
    local pass=0 fail=0

    check() { eval "$2" &>/dev/null && { echo -e "  ${GREEN}[✓]${NC} $1"; ((pass++)); } || { echo -e "  ${RED}[✗]${NC} $1"; ((fail++)); }; }

    if command -v pg_isready &>/dev/null; then
        check "PostgreSQL running" "pg_isready -p ${PG_PORT} -q"
    else
        [[ -n "$MSF_PASS" ]] && check "DB (password)" "PGPASSWORD='${MSF_PASS}' psql -p ${PG_PORT} -U ${MSF_USER} -d ${MSF_DB} -c 'SELECT 1'" || check "DB (trust)" "psql -p ${PG_PORT} -U ${MSF_USER} -d ${MSF_DB} -c 'SELECT 1'"
    fi

    [[ -n "$MSF_PASS" ]] && check "DB (password)" "PGPASSWORD='${MSF_PASS}' psql -p ${PG_PORT} -U ${MSF_USER} -d ${MSF_DB} -c 'SELECT 1'" || check "DB (trust)" "psql -p ${PG_PORT} -U ${MSF_USER} -d ${MSF_DB} -c 'SELECT 1'"

    check "Ruby" "ruby --version"
    check "pg gem" "ruby -e 'require \"pg\"' 2>/dev/null"
    check "MSF source" "[ -d ${MSF_INSTALL_DIR}/lib ]"
    check "msfconsole" "[ -f ${MSF_INSTALL_DIR}/msfconsole ]"
    check "msfvenom" "[ -f ${MSF_INSTALL_DIR}/msfvenom ]"
    check "database.yml" "[ -f ${MSF_DIR}/database.yml ]"
    check "config.yml" "[ -f ${MSF_DIR}/config.yml ]"
    check "launcher" "[ -x $HOME/bin/msfconsole ]"

    echo ""; echo -e "  ${BOLD}Results: ${GREEN}$pass${NC} passed / ${RED}$fail${NC} failed${NC}"
    [[ $fail -gt 0 ]] && warn "Some checks failed - run 'msfdb' for DB diagnostics"
}

#==============================================================================
# SUMMARY
#==============================================================================
print_summary() {
    echo ""
    echo -e "${RED}${BOLD}  ╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}  ║     SETUP COMPLETE - Metasploit Framework Ready      ║${NC}"
    echo -e "${RED}${BOLD}  ╚══════════════════════════════════════════════════════╝${NC}"
    echo ""

    cat << SUMMARY
  ${BOLD}▸ Start:${NC}       ${GREEN}source ~/.bashrc && msfconsole${NC}
  ${BOLD}▸ Inside MSF:${NC}  db_status, workspace -a <name>, search <keyword>, use <module>
  ${BOLD}▸ Tools:${NC}       msfconsole | msfvenom | msfdb
SUMMARY
    [[ "$PG_MODE" == "home" ]] && echo "  ${BOLD}▸ PG:${NC}         pg-start | pg-stop"
    cat << SUMMARY3

  ${BOLD}▸ Config:${NC}      ~/.msf4/database.yml (600) | ~/.msf4/config.yml
  ${BOLD}▸ Database:${NC}    ${PG_HOST:-localhost}:${PG_PORT} | ${MSF_USER}/${MSF_DB} | $([[ -n "$MSF_PASS" ]] && echo "***" || echo "trust")
  ${BOLD}▸ Update:${NC}      cd ${MSF_INSTALL_DIR} && git pull && bundle install
  ${BOLD}▸ Troubleshoot:${NC} msfdb
SUMMARY3
    echo ""
}

#==============================================================================
# MAIN
#==============================================================================
main() {
    # Parse args
    case "${1:-}" in
        --auto) INTERACTIVE=false; shift ;;
        --check) detect_environment; exit 0 ;;
        --help|-h) cat << HELP
Usage: bash setup-metasploit.sh [--auto|--check|--help]
  --auto   Non-interactive (uses env vars or defaults)
  --check  Pre-flight check only
  --help   This help

Env vars: MSF_INSTALL_DIR, MSF_DIR, MSF_BRANCH, MSF_USER, MSF_DB, MSF_PASS, PG_PORT, USE_PASSWORD
HELP
            exit 0 ;;
    esac

    load_state
    [[ "$INTERACTIVE" == "true" ]] && run_wizard
    detect_environment
    install_dependencies
    setup_postgresql
    install_metasploit
    install_gems
    create_config_and_launchers
    verify_installation
    print_summary

    save_state
    log "Setup complete! Run: source ~/.bashrc && msfconsole"
}
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
