#!/usr/bin/env bash
# ==============================================================================
# ENVIRONMENT DETECTION — Distro, package manager, paths, compatibility (FULLY FIXED)
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/env.sh"
# ==============================================================================

# Local helpers - NO dependency on common.sh
cmd_exists() { command -v "$1" &>/dev/null; }
is_root() { [[ "${EUID:-$(id -u)}" -eq 0 ]]; }
has_sudo() { cmd_exists sudo && sudo -n true 2>/dev/null; }
user_mode() { if is_root; then echo "root"; elif has_sudo; then echo "sudo"; else echo "normal"; fi; }

: "${RED:=\033[0;31m}"
: "${GREEN:=\033[0;32m}"
: "${YELLOW:=\033[1;33m}"
: "${BLUE:=\033[0;34m}"
: "${MAGENTA:=\033[0;35m}"
: "${CYAN:=\033[0;36m}"
: "${BOLD:=\033[1m}"
: "${DIM:=\033[2m}"
: "${NC:=\033[0m}"

log()   { echo -e "  ${GREEN}[✓]${NC} $*"; }
info()  { echo -e "  ${BLUE}[*]${NC} $*"; }
warn()  { echo -e "  ${YELLOW}[!]${NC} $*"; }
err()   { echo -e "  ${RED}[✗]${NC} $*" >&2; }

# ── Termux Detection ──────────────────────────────────────────────────────────
is_termux() { [[ -d "/data/data/com.termux" ]] || cmd_exists termux-info 2>/dev/null; }

# ── OS & Platform Detection ───────────────────────────────────────────────────
detect_os() {
    export OS_TYPE OS_FAMILY ARCH
    ARCH="$(uname -m)"

    case "$(uname -s)" in
        Linux)  OS_TYPE="linux" ;;
        Darwin) OS_TYPE="macos" ;;
        *)      OS_TYPE="$(uname -s)" ;;
    esac

    # Detect distro
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release 2>/dev/null || true
        export DISTRO_ID="${ID,,}"
        export DISTRO_VERSION="${VERSION_ID:-}"
    elif [[ -f /etc/arch-release ]]; then
        export DISTRO_ID="arch"
    elif is_termux; then
        export DISTRO_ID="termux"
    else
        export DISTRO_ID="unknown"
    fi

    # Distro family
    case "$DISTRO_ID" in
        ubuntu|debian|kali|parrot|linuxmint|pop|raspbian|zorin)
            OS_FAMILY="debian" ;;
        fedora|rhel|centos|rocky|alma|oracle)
            OS_FAMILY="redhat" ;;
        arch|manjaro|endeavouros|artix|garuda)
            OS_FAMILY="arch" ;;
        opensuse*|sles)
            OS_FAMILY="suse" ;;
        termux)
            OS_FAMILY="termux" ;;
        *)  OS_FAMILY="unknown" ;;
    esac

    export PACKAGE_MANAGER=""
    export PKG_INSTALL_CMD=""
    export PKG_UPDATE_CMD=""
    case "$OS_FAMILY" in
        debian) 
            PACKAGE_MANAGER="apt"; 
            PKG_INSTALL_CMD="sudo apt-get install -y --no-install-recommends"; 
            PKG_UPDATE_CMD="sudo apt-get update -qq" ;;
        redhat) 
            PACKAGE_MANAGER="dnf"; 
            PKG_INSTALL_CMD="sudo dnf install -y"; 
            PKG_UPDATE_CMD="sudo dnf check-update -qq" ;;
        arch)   
            PACKAGE_MANAGER="pacman"; 
            PKG_INSTALL_CMD="sudo pacman -Sy --noconfirm --needed"; 
            PKG_UPDATE_CMD="sudo pacman -Sy --noconfirm" ;;
        suse)   
            PACKAGE_MANAGER="zypper"; 
            PKG_INSTALL_CMD="sudo zypper install -y"; 
            PKG_UPDATE_CMD="" ;;
        termux) 
            PACKAGE_MANAGER="pkg"; 
            PKG_INSTALL_CMD="pkg install -y"; 
            PKG_UPDATE_CMD="pkg update -qq" ;;
        *)      
            PACKAGE_MANAGER=""; 
            PKG_INSTALL_CMD=""; 
            PKG_UPDATE_CMD="" ;;
    esac

    # Architecture bin mapping
    case "$ARCH" in
        x86_64|amd64) export BIN_ARCH="amd64"; export GO_ARCH="amd64" ;;
        aarch64|arm64) export BIN_ARCH="arm64"; export GO_ARCH="arm64" ;;
        armv7l|arm) export BIN_ARCH="arm"; export GO_ARCH="armv6l" ;;
        *) export BIN_ARCH="$ARCH"; export GO_ARCH="$ARCH"; warn "Unknown arch: $ARCH — using as-is" ;;
    esac

    info "OS: $OS_TYPE | Distro: $DISTRO_ID | Family: $OS_FAMILY | Arch: $ARCH"
}

# ── User Capability Check ─────────────────────────────────────────────────────
detect_user() {
    export CURRENT_USER="$(whoami)"
    export HOME_DIR="$HOME"
    export MY_EUID="${EUID:-$(id -u)}"
    export USER_MODE="$(user_mode)"

    info "User: $CURRENT_USER | Mode: $USER_MODE | Home: $HOME_DIR"

    case "$USER_MODE" in
        root)
            warn "Running as root. Some operations may fail (e.g., initdb)."
            warn "Consider running as a normal user with sudo access."
            ;;
        sudo)
            log "Running as normal user with sudo — optimal."
            ;;
        normal)
            warn "Running without sudo. Package installation may fail."
            info "If you have sudo access, you will be prompted for password."
            ;;
    esac
}

# ── Default Paths (overridable via env) ────────────────────────────────────────
resolve_paths() {
    export MSF_INSTALL_DIR="${MSF_INSTALL_DIR:-$HOME/metasploit-framework}"
    export MSF_DIR="${MSF_DIR:-$HOME/.msf4}"
    export PG_DATA_DIR="${PG_DATA_DIR:-$MSF_DIR/postgres}"
    export BIN_DIR="${BIN_DIR:-$HOME/bin}"
    export STATE_FILE="${STATE_FILE:-$HOME/.msf-setup-state}"

    info "Install dir: $MSF_INSTALL_DIR"
    info "Config dir:  $MSF_DIR"
    info "Bin dir:     $BIN_DIR"
}

# ── Run All Detections ────────────────────────────────────────────────────────
detect_all() {
    detect_os
    detect_user
    resolve_paths
}
