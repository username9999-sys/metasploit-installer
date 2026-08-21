#!/usr/bin/env bash
# ==============================================================================
# MSF RUN — Unified Launcher for Metasploit Installer (FULLY FIXED)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export PATH="$SCRIPT_DIR/bin:$PATH"

# ── Source core libs in CORRECT ORDER ──────────────────────────────────────────
# env.sh must be first (defines cmd_exists), then common.sh, then root-bridge.sh
source "$SCRIPT_DIR/lib/env.sh"
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/root-bridge.sh"
detect_all

show_banner() {
    echo ""
    echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}║  METASPLOIT FRAMEWORK — Modular Installer & Toolkit         ║${NC}"
    echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${DIM}User:${NC} ${CURRENT_USER} | ${DIM}Mode:${NC} ${USER_MODE}"
    echo -e "  ${DIM}OS:${NC}   ${DISTRO_ID} (${OS_FAMILY}) | ${DIM}Arch:${NC} ${ARCH}"
    echo -e "  ${DIM}Home:${NC} ${HOME_DIR}"
    echo ""
}

show_menu() {
    echo -e "${BOLD}Pilih aksi:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} 🔍  ${BOLD}Pre-flight Check${NC}        — Cek semua prerequisite"
    echo -e "  ${GREEN}2)${NC} 📦  ${BOLD}Install Dependencies${NC}    — Install paket sistem"
    echo -e "  ${GREEN}3)${NC} ⚙️   ${BOLD}Install Metasploit${NC}       — Setup + PostgreSQL + clone + bundle"
    echo -e "  ${GREEN}4)${NC} 📖  ${BOLD}Cheatsheet${NC}              — Referensi perintah Metasploit"
    echo -e "  ${GREEN}5)${NC} 📋  ${BOLD}Runbooks${NC}                — Runbook praktis (AD, Web, Wireless)"
    echo -e "  ${GREEN}6)${NC} 🧠  ${BOLD}Pentest Framework${NC}       — Framework 5-fase PTES/NIST"
    echo -e "  ${GREEN}7)${NC} 🌐  ${BOLD}Module Browser${NC}          — Browse & run modules"
    echo -e "  ${GREEN}8)${NC} 🔧  ${BOLD}Root Bridge${NC}             — Setup untuk user non-root"
    echo -e "  ${GREEN}9)${NC} 🤖  ${BOLD}AI Assistant${NC}            — MSF-AI (Ollama/OpenAI)"
    echo -e "  ${GREEN}10)${NC} 🦊 ${BOLD}C2 Launcher${NC}            — Sliver/Havoc/Mythic"
    echo -e "  ${GREEN}0)${NC} Keluar"
    echo ""
}

# ── Run pre-flight checker ────────────────────────────────────────────────────
do_check() {
    bridge_all
    step "Running Pre-flight Check..."
    if [[ -f "$SCRIPT_DIR/lib/checker.sh" ]]; then
        bash "$SCRIPT_DIR/lib/checker.sh"
    else
        warn "checker.sh not found — running basic checks"
        for tool in git curl ruby bundle psql; do
            cmd_exists "$tool" && log "$tool ✓" || err "$tool ✗ — required"
        done
    fi
}

# ── Install dependencies ──────────────────────────────────────────────────────
do_deps() {
    bridge_all
    step "Installing Dependencies..."
    if [[ -f "$SCRIPT_DIR/lib/deps.sh" ]]; then
        bash "$SCRIPT_DIR/lib/deps.sh" "${1:-}"
    else
        warn "deps.sh not found"
        info "Run setup-metasploit.sh directly — it will install deps"
    fi
}

# ── Run main installer ────────────────────────────────────────────────────────
do_install() {
    bridge_all
    step "Running Metasploit Installer..."
    if [[ -f "$SCRIPT_DIR/setup-metasploit.sh" ]]; then
        if [[ "${1:-}" == "--auto" ]]; then
            bash "$SCRIPT_DIR/setup-metasploit.sh" --auto
        else
            bash "$SCRIPT_DIR/setup-metasploit.sh"
        fi
    else
        err "setup-metasploit.sh not found!"
        exit 1
    fi
}

# ── Quick install (auto mode with checks) ─────────────────────────────────────
do_quick() {
    bridge_all
    step "Quick Install (Auto Mode)"
    info "Step 1/3: Pre-flight check..."
    if bash "$SCRIPT_DIR/lib/checker.sh" --quiet 2>/dev/null; then
        log "Pre-flight passed"
    else
        warn "Some checks failed — continuing anyway"
    fi
    info "Step 2/3: Installing dependencies..."
    bash "$SCRIPT_DIR/lib/deps.sh" --auto 2>/dev/null || warn "Deps partial — continuing"
    info "Step 3/3: Installing Metasploit..."
    bash "$SCRIPT_DIR/setup-metasploit.sh" --auto
}

# ── Show cheatsheet ───────────────────────────────────────────────────────────
do_cheatsheet() {
    step "Metasploit Command Reference"
    show_cheatsheet 2>/dev/null || bash "$SCRIPT_DIR/msf-cheatsheet.sh"
}

# ── Show runbooks ─────────────────────────────────────────────────────────────
do_runbooks() {
    step "Penetration Testing Runbooks"
    run_runbook_menu 2>/dev/null || bash "$SCRIPT_DIR/msf-runbooks.sh"
}

# ── Show pentest framework ────────────────────────────────────────────────────
do_framework() {
    step "5-Phase Pentest Framework"
    print_professional_framework 2>/dev/null || bash "$SCRIPT_DIR/msf-pentest-framework.sh"
}

# ── Browse modules ────────────────────────────────────────────────────────────
do_modules() {
    step "Module Browser"
    echo -e "${BOLD}Available module categories:${NC}"
    echo ""
    for dir in "$SCRIPT_DIR"/modules/*/; do
        [[ -d "$dir" ]] || continue
        local cat_name
        cat_name="$(basename "$dir")"
        local count
        count=$(find "$dir" -type f -name '*.sh' 2>/dev/null | wc -l)
        echo -e "  ${CYAN}$cat_name${NC} — $count modules"
        for sub in "$dir"/*/; do
            [[ -d "$sub" ]] || continue
            local sub_name sub_count
            sub_name="$(basename "$sub")"
            sub_count=$(find "$sub" -type f -name '*.sh' 2>/dev/null | wc -l)
            echo -e "    ${DIM}$sub_name${NC} ($sub_count)"
        done
    done
    echo ""
    info "To run a module: bash msf-run.sh module <category>/<subcategory>/<name>"
    info "Example: bash msf-run.sh module scanner/smb/smb_scanner 192.168.1.0/24"
}

# ── Run single module ─────────────────────────────────────────────────────────
do_run_module() {
    local module_path="$1"
    local full_path="$SCRIPT_DIR/modules/$module_path"

    [[ -z "$module_path" ]] && { err "Usage: bash msf-run.sh module <category>/<sub>/<name> [args...]"; return 1; }

    # Try with .sh extension
    if [[ -f "$full_path.sh" ]]; then
        full_path="$full_path.sh"
    fi

    if [[ -f "$full_path" ]]; then
        step "Running module: $module_path"
        shift
        bash "$full_path" "$@"
    else
        err "Module not found: $module_path"
        info "Try: bash msf-run.sh modules to browse"
        return 1
    fi
}

# ── Root bridge ───────────────────────────────────────────────────────────────
do_root_bridge() {
    step "Root Bridge — User Setup Helper"
    bridge_all
}

# ── Launch Dashboard ──────────────────────────────────────────────────────────
do_dashboard() {
    bridge_all
    step "Starting Web Dashboard..."
    if [[ -f "$SCRIPT_DIR/dashboard/app.py" ]]; then
        info "Dashboard will be available at http://localhost:5000"
        python3 "$SCRIPT_DIR/dashboard/app.py"
    else
        err "Dashboard not found!"
        return 1
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    case "${1:-menu}" in
        check)
            show_banner
            do_check
            ;;
        deps)
            show_banner
            do_deps "${2:-}"
            ;;
        install)
            show_banner
            do_install "${2:-}"
            ;;
        quick|auto)
            show_banner
            do_quick
            ;;
        cheatsheet|cheat)
            do_cheatsheet
            ;;
        runbooks|runbook)
            do_runbooks
            ;;
        framework|pentest)
            do_framework
            ;;
        modules|browse|list)
            do_modules
            ;;
        module)
            do_run_module "${2:-}" "${@:3}"
            ;;
        ai|assistant)
            shift
            bash "$SCRIPT_DIR/msf-ai.sh" "$@"
            ;;
        c2)
            shift
            bash "$SCRIPT_DIR/c2-run.sh" "$@"
            ;;
        dashboard|web)
            show_banner
            do_dashboard
            ;;
        root-bridge|bridge|fix)
            show_banner
            do_root_bridge
            ;;
        menu|"")
            show_banner
            show_menu
            local choice
            read -r -p "  [?] Pilih (0-10): " choice
            case "$choice" in
                1) do_check ;;
                2) do_deps ;;
                3) do_install ;;
                4) do_cheatsheet ;;
                5) do_runbooks ;;
                6) do_framework ;;
                7) do_modules ;;
                8) do_root_bridge ;;
                9) bash "$SCRIPT_DIR/msf-ai.sh" interactive ;;
                10) bash "$SCRIPT_DIR/c2-run.sh" menu ;;
                0) info "Sampai jumpa!"; exit 0 ;;
                *) warn "Pilihan tidak valid" ;;
            esac
            ;;
        *)
            warn "Unknown command: $1"
            echo "Usage: bash msf-run.sh [check|deps|install|quick|cheatsheet|runbooks|framework|modules|module|ai|c2|dashboard|root-bridge]"
            exit 1
            ;;
    esac
}

main "$@"
