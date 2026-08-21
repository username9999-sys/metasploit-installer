#!/usr/bin/env bash
# ==============================================================================
# MSF-AI — AI Assistant for Metasploit Framework
# Uses Ollama (local) or OpenAI API for intelligent pentesting guidance
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/lib/llm_helper.sh" 2>/dev/null || true

# Colors fallback
: "${RED:=\033[0;31m}"; : "${GREEN:=\033[0;32m}"; : "${YELLOW:=\033[1;33m}"
: "${BLUE:=\033[0;34m}"; : "${MAGENTA:=\033[0;35m}"; : "${CYAN:=\033[0;36m}"
: "${BOLD:=\033[1m}"; : "${NC:=\033[0m}"

MODEL="${OLLAMA_MODEL:-llama3.1}"
OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"
OPENAI_KEY="${OPENAI_API_KEY:-}"
OPENAI_MODEL="${OPENAI_MODEL:-gpt-4o}"

show_banner() {
    echo -e "${MAGENTA}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║     MSF-AI — Metasploit AI Assistant (Ollama/OpenAI)       ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_ollama() {
    if command -v ollama &>/dev/null; then
        if curl -sf "$OLLAMA_URL/api/tags" >/dev/null 2>&1; then
            log "Ollama running at $OLLAMA_URL"
            return 0
        fi
        warn "Ollama installed but not running. Start: ollama serve"
    else
        warn "Ollama not installed. Install: curl -fsSL https://ollama.com/install.sh | sh"
    fi
    return 1
}

check_openai() {
    [[ -n "$OPENAI_KEY" ]] && return 0
    return 1
}

ask_llm() {
    local prompt="$1"
    local system_prompt="${2:-You are an expert penetration tester and Metasploit Framework specialist. Provide practical, safe, and ethical guidance only.}"
    
    if check_ollama; then
        local payload
        payload=$(jq -n --arg model "$MODEL" --arg prompt "$prompt" --arg system "$system_prompt" \
            '{model: $model, prompt: $prompt, system: $system, stream: false}')
        curl -sf "$OLLAMA_URL/api/generate" -d "$payload" -H "Content-Type: application/json" \
            | jq -r '.response'
    elif check_openai; then
        local payload
        payload=$(jq -n --arg model "$OPENAI_MODEL" --arg prompt "$prompt" --arg system "$system_prompt" \
            '{model: $model, messages: [{"role": "system", "content": $system}, {"role": "user", "content": $prompt}], temperature: 0.3}')
        curl -sf https://api.openai.com/v1/chat/completions \
            -H "Authorization: Bearer $OPENAI_KEY" \
            -H "Content-Type: application/json" \
            -d "$payload" | jq -r '.choices[0].message.content'
    else
        warn "No LLM backend available. Set OPENAI_API_KEY or run ollama serve."
        return 1
    fi
}

analyze_target() {
    local target="${1:-}"
    [[ -z "$target" ]] && read -r -p "Target IP/hostname: " target
    [[ -z "$target" ]] && { err "Target required"; return 1; }
    
    info "Analyzing target: $target"
    local prompt="Target: $target. Provide a step-by-step Metasploit recon and exploitation plan. Include nmap scans, MSF modules to try, and privilege escalation paths. Be specific with commands."
    ask_llm "$prompt"
}

generate_payload() {
    local os="${1:-windows}"
    local lhost="${2:-}"
    local lport="${3:-4444}"
    
    [[ -z "$lhost" ]] && read -r -p "LHOST: " lhost
    [[ -z "$lhost" ]] && { err "LHOST required"; return 1; }
    
    info "Generating payload for $os -> $lhost:$lport"
    local prompt="Generate msfvenom command for $os meterpreter reverse_tcp to $lhost:$lport. Include exe, elf, apk, php, jsp formats. Show handler commands."
    ask_llm "$prompt"
}

suggest_exploit() {
    local service="${1:-}"
    local version="${2:-}"
    [[ -z "$service" ]] && read -r -p "Service (smb/rdp/ssh/http/mssql): " service
    [[ -z "$version" ]] && read -r -p "Version (optional): " version
    
    info "Finding exploits for $service $version"
    local prompt="Service: $service $version. List Metasploit exploit modules with full paths. Include check/exploit commands."
    ask_llm "$prompt"
}

privilege_escalation() {
    local os="${1:-windows}"
    info "Privilege escalation for $os"
    local prompt="OS: $os. Provide Metasploit post-exploitation modules for privilege escalation. Include local_exploit_suggester, getsystem, bypassuac, token manipulation, kernel exploits. Show exact commands."
    ask_llm "$prompt"
}

post_exploitation() {
    local os="${1:-windows}"
    info "Post-exploitation for $os"
    local prompt="OS: $os. Provide post-exploitation: credential harvesting (kiwi/mimikatz), persistence (registry/service/WMI), lateral movement (psexec/wmi/pass-hash), pivoting (autoroute/socks), data exfil, cleanup (clearev/timestomp)."
    ask_llm "$prompt"
}

explain_module() {
    local module="${1:-}"
    [[ -z "$module" ]] && read -r -p "Module path (e.g., exploit/windows/smb/ms17_010_eternalblue): " module
    [[ -z "$module" ]] && { err "Module required"; return 1; }
    
    info "Explaining $module"
    local prompt="Explain Metasploit module $module: description, options, payloads, targets, example usage, common issues."
    ask_llm "$prompt"
}

troubleshoot() {
    local error="${1:-}"
    [[ -z "$error" ]] && read -r -p "Paste error/message: " error
    [[ -z "$error" ]] && { err "Error required"; return 1; }
    
    info "Troubleshooting: $error"
    local prompt="Metasploit error/log: '$error'. Explain cause and fix. Include common solutions for: database connection, payload staging, session dies, AV detection, network issues."
    ask_llm "$prompt"
}

interactive_mode() {
    show_banner
    echo "Commands: target, payload, exploit, privesc, post, explain, debug, quit"
    echo ""
    
    while true; do
        read -r -p "msf-ai> " cmd args
        case "$cmd" in
            target|t) analyze_target "$args" ;;
            payload|p) generate_payload $args ;;
            exploit|e) suggest_exploit $args ;;
            privesc|priv) privilege_escalation "$args" ;;
            post) post_exploitation "$args" ;;
            explain|x) explain_module "$args" ;;
            debug|d) troubleshoot "$args" ;;
            quit|q|exit) info "Bye!"; exit 0 ;;
            help|h|"") 
                echo "  target <ip>      - Full recon/exploit plan"
                echo "  payload <os> <lhost> <lport> - Generate msfvenom"
                echo "  exploit <service> [version]  - Find exploits"
                echo "  privesc [os]     - Privilege escalation modules"
                echo "  post [os]        - Post-exploitation guide"
                echo "  explain <module> - Module documentation"
                echo "  debug <error>    - Troubleshoot error"
                echo "  quit             - Exit"
                ;;
            *) warn "Unknown: $cmd. Type 'help'" ;;
        esac
        echo ""
    done
}

main() {
    case "${1:-}" in
        --help|-h)
            cat << HELP
MSF-AI — AI Assistant for Metasploit

Usage: bash msf-ai.sh [COMMAND] [ARGS...]

Commands:
  target <ip>              Full analysis & exploit plan
  payload <os> <lhost> <lport>  Generate msfvenom commands
  exploit <service> [version]   Find exploit modules
  privesc [os]             Privilege escalation guide
  post [os]                Post-exploitation guide
  explain <module>         Module documentation
  debug <error>            Troubleshoot error
  interactive              Interactive mode (default)

Env vars:
  OLLAMA_MODEL=llama3.1    Local model (default)
  OLLAMA_URL=http://localhost:11434
  OPENAI_API_KEY=sk-...    Use OpenAI instead
  OPENAI_MODEL=gpt-4o

Examples:
  bash msf-ai.sh target 192.168.1.50
  bash msf-ai.sh payload windows 192.168.1.100 4444
  bash msf-ai.sh exploit smb
  bash msf-ai.sh interactive
HELP
            ;;
        target) analyze_target "${2:-}" ;;
        payload) generate_payload "${2:-windows}" "${3:-}" "${4:-4444}" ;;
        exploit) suggest_exploit "${2:-}" "${3:-}" ;;
        privesc) privilege_escalation "${2:-windows}" ;;
        post) post_exploitation "${2:-windows}" ;;
        explain) explain_module "${2:-}" ;;
        debug) troubleshoot "${2:-}" ;;
        interactive|"") interactive_mode ;;
        *) err "Unknown: $1. Use --help"; exit 1 ;;
    esac
}

main "$@"
