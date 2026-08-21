#!/usr/bin/env bash
# ==============================================================================
# DEPENDENCY INSTALLER — Smart package installer for all distros
# Usage: bash lib/deps.sh [--dry-run] [--auto]
# ==============================================================================
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$script_dir/common.sh" ]]; then
    source "$script_dir/common.sh"
    source "$script_dir/env.sh"
    detect_all
fi

DRY_RUN=false
AUTO_MODE=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true
[[ "${1:-}" == "--auto" || "${2:-}" == "--auto" ]] && AUTO_MODE=true

# ── Package maps per distro family ────────────────────────────────────────────
declare -A PKG_MAP

case "${OS_FAMILY:-debian}" in
    debian)
        PKG_MAP=(
            [git]="git"
            [curl]="curl"
            [ruby]="ruby ruby-dev"
            [build]="build-essential"
            [postgresql]="postgresql postgresql-contrib libpq-dev"
            [nmap]="nmap"
            [libpcap]="libpcap-dev"
            [libsqlite]="libsqlite3-dev"
            [libxml]="libxml2-dev libxslt1-dev"
            [libcurl]="libcurl4-openssl-dev"
            [ruby_nokogiri]="pkg-config"
        )
        INSTALL_CMD="apt-get install -y --no-install-recommends"
        UPDATE_CMD="apt-get update -qq"
        ;;
    redhat)
        PKG_MAP=(
            [git]="git"
            [curl]="curl"
            [ruby]="ruby ruby-devel"
            [build]="gcc gcc-c++ make"
            [postgresql]="postgresql postgresql-server postgresql-devel"
            [nmap]="nmap"
            [libpcap]="libpcap-devel"
            [libsqlite]="sqlite-devel"
            [libxml]="libxml2-devel libxslt-devel"
            [libcurl]="libcurl-devel"
            [ruby_nokogiri]="pkgconfig"
        )
        INSTALL_CMD="dnf install -y"
        UPDATE_CMD=""
        ;;
    arch)
        PKG_MAP=(
            [git]="git"
            [curl]="curl"
            [ruby]="ruby"
            [build]="base-devel"
            [postgresql]="postgresql postgresql-libs"
            [nmap]="nmap"
            [libpcap]="libpcap"
            [libsqlite]="sqlite"
            [libxml]="libxml2 libxslt"
            [libcurl]="curl"
            [ruby_nokogiri]="pkg-config"
        )
        INSTALL_CMD="pacman -Sy --noconfirm --needed"
        UPDATE_CMD="pacman -Sy --noconfirm"
        ;;
    termux)
        PKG_MAP=(
            [git]="git"
            [curl]="curl"
            [ruby]="ruby"
            [build]="clang make binutils"
            [postgresql]="postgresql"
            [nmap]="nmap"
            [libpcap]="libpcap"
            [libsqlite]="libsqlite"
            [libxml]="libxml2 libxslt"
            [libcurl]="libcurl"
            [ruby_nokogiri]="pkg-config"
        )
        # Termux never needs sudo
        INSTALL_CMD="pkg install -y"
        UPDATE_CMD="pkg update -qq"
        ;;
    *)
        warn "Unknown OS family — cannot auto-install"
        echo ""
        echo "Please install manually:"
        echo "  git curl ruby ruby-dev build-essential"
        echo "  postgresql postgresql-contrib libpq-dev"
        echo "  libpcap-dev libsqlite3-dev libxml2-dev libxslt1-dev"
        exit 1
        ;;
esac

# ── Install packages ──────────────────────────────────────────────────────────
install_packages() {
    local category="$1"
    local pkgs="${PKG_MAP[$category]:-}"
    [[ -z "$pkgs" ]] && { warn "No package map for '$category'"; return 1; }

    if $DRY_RUN; then
        info "DRY RUN: $INSTALL_CMD $pkgs"
        return 0
    fi

    info "Installing: $pkgs"

    # UPDATE_CMD is now run ONCE in install_all(), not here
    if priv_run $INSTALL_CMD $pkgs 2>&1 | tail -20; then
        log "Installed: $category ($pkgs)"
    else
        warn "Batch install failed — trying one by one..."
        for pkg in $pkgs; do
            info "  Installing: $pkg"
            if priv_run $INSTALL_CMD "$pkg" 2>/dev/null; then
                log "  $pkg ✓"
            else
                err "  $pkg ✗ — skipped"
            fi
        done
    fi
}

# ── Install all Metasploit dependencies ──────────────────────────────────────
install_all() {
    step "Installing Metasploit Dependencies"

    if $DRY_RUN; then
        info "DRY RUN only — no packages will be installed"
        echo ""
    fi

    if [[ "$(user_mode)" == "normal" ]] && ! $DRY_RUN; then
        warn "No sudo access detected. Package install will likely fail."
        if [[ "$AUTO_MODE" != "true" ]]; then
            ask_yesno "Continue anyway?" "n" || exit 1
        fi
    fi

    # Run package update ONCE at the beginning (fix: was running in each install_packages call)
    if [[ -n "$UPDATE_CMD" ]] && ! $DRY_RUN; then
        info "Updating package repositories..."
        priv_run $UPDATE_CMD 2>/dev/null || warn "Repo update failed — continuing anyway"
    fi

    install_packages "git"
    install_packages "curl"
    install_packages "ruby"
    install_packages "build"
    install_packages "postgresql"
    install_packages "nmap"
    install_packages "libpcap"
    install_packages "libsqlite"
    install_packages "libxml"
    install_packages "libcurl"
    install_packages "ruby_nokogiri"

    echo ""
    log "All dependency groups processed"

    # Verify critical tools
    echo ""
    info "Critical tool check:"
    for tool in git curl ruby bundle psql pg_isready gcc nmap; do
        if command -v "$tool" &>/dev/null; then
            log "$tool ✓"
        else
            warn "$tool ✗ — may need manual install"
        fi
    done
}

# ── Main ──────────────────────────────────────────────────────────────────────
echo ""
if $DRY_RUN; then
    echo -e "${CYAN}DEPENDENCY CHECK (dry run)${NC}"
else
    echo -e "${CYAN}DEPENDENCY INSTALLER${NC}"
fi
echo ""

install_all
