#!/usr/bin/env bash
# ==============================================================================
# TELEGRAM NOTIFY — Send notifications via Telegram Bot
# Usage: bash scripts/telegram_notify.sh "Message text" [chat_id]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh" 2>/dev/null || {
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
    log() { echo -e "${GREEN}[✓]${NC} $*"; }
    info() { echo -e "${BLUE}[*]${NC} $*"; }
    warn() { echo -e "${YELLOW}[!]${NC} $*"; }
    err() { echo -e "${RED}[✗]${NC} $*" >&2; }
}

# ── Config ────────────────────────────────────────────────────────────────────
CONFIG_FILE="${HOME}/.msf4/telegram.env"
BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
CHAT_ID="${TELEGRAM_CHAT_ID:-}"

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # Safe load: only KEY=VALUE
        while IFS='=' read -r key val; do
            [[ -z "$key" ]] && continue
            [[ "$key" =~ ^# ]] && continue
            if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
                val="${val%%#*}"
                val="${val%%*( )}"
                export "$key=$val"
            fi
        done < <(grep -E '^[A-Z_][A-Z0-9_]*=' "$CONFIG_FILE" 2>/dev/null || true)
    fi
    BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-$BOT_TOKEN}"
    CHAT_ID="${TELEGRAM_CHAT_ID:-$CHAT_ID}"
}

# ── URL Encode ────────────────────────────────────────────────────────────────
url_encode() {
    local string="$1"
    local strlen=${#string}
    local encoded=""
    local pos c o
    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="$c" ;;
            * ) printf -v o '%%%02X' "'$c" ;;
        esac
        encoded+="$o"
    done
    echo "$encoded"
}

# ── Send Message ──────────────────────────────────────────────────────────────
send_telegram() {
    local message="$1"
    local target_chat="${2:-$CHAT_ID}"
    local parse_mode="${3:-HTML}"
    local max_retries=3
    local retry_delay=2
    
    [[ -z "$BOT_TOKEN" ]] && { err "TELEGRAM_BOT_TOKEN not set"; return 1; }
    [[ -z "$target_chat" ]] && { err "Chat ID not provided"; return 1; }
    
    local encoded_msg
    encoded_msg=$(url_encode "$message")
    
    local url="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"
    local payload="chat_id=${target_chat}&text=${encoded_msg}&parse_mode=${parse_mode}&disable_web_page_preview=true"
    
    for attempt in $(seq 1 $max_retries); do
        info "Attempt $attempt/$max_retries..."
        if curl -s -X POST "$url" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "$payload" \
            --max-time 10 \
            --connect-timeout 5 2>/dev/null | grep -q '"ok":true'; then
            log "Message sent to chat $target_chat"
            return 0
        else
            warn "Attempt $attempt failed"
            [[ $attempt -lt $max_retries ]] && sleep $retry_delay
        fi
    done
    
    err "Failed to send after $max_retries attempts"
    return 1
}

# ── Send File ─────────────────────────────────────────────────────────────────
send_file() {
    local file_path="$1"
    local target_chat="${2:-$CHAT_ID}"
    local caption="${3:-}"
    
    [[ -z "$BOT_TOKEN" ]] && { err "TELEGRAM_BOT_TOKEN not set"; return 1; }
    [[ -z "$target_chat" ]] && { err "Chat ID not provided"; return 1; }
    [[ ! -f "$file_path" ]] && { err "File not found: $file_path"; return 1; }
    
    local url="https://api.telegram.org/bot${BOT_TOKEN}/sendDocument"
    local max_retries=3
    local retry_delay=2
    
    for attempt in $(seq 1 $max_retries); do
        info "Uploading $file_path (attempt $attempt/$max_retries)..."
        if curl -s -X POST "$url" \
            -F "chat_id=${target_chat}" \
            -F "document=@${file_path}" \
            -F "caption=${caption}" \
            --max-time 30 \
            --connect-timeout 10 2>/dev/null | grep -q '"ok":true'; then
            log "File sent to chat $target_chat"
            return 0
        else
            warn "Upload attempt $attempt failed"
            [[ $attempt -lt $max_retries ]] && sleep $retry_delay
        fi
    done
    
    err "Failed to upload after $max_retries attempts"
    return 1
}

# ── Setup Config ──────────────────────────────────────────────────────────────
setup_config() {
    step "Telegram Bot Configuration"
    
    local bot_token chat_id
    bot_token=$(ask_input "Bot Token (from @BotFather)" "$BOT_TOKEN")
    chat_id=$(ask_input "Chat ID (from @userinfobot or group)" "$CHAT_ID")
    
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << CFGEOF
# Telegram Bot Configuration
# Generated: $(date)
TELEGRAM_BOT_TOKEN="$bot_token"
TELEGRAM_CHAT_ID="$chat_id"
CFGEOF
    chmod 600 "$CONFIG_FILE"
    
    log "Config saved to $CONFIG_FILE (chmod 600)"
    
    # Test
    info "Testing connection..."
    export TELEGRAM_BOT_TOKEN="$bot_token"
    export TELEGRAM_CHAT_ID="$chat_id"
    send_telegram "🤖 <b>Metasploit Installer Bot Connected</b>" "$chat_id" && log "Test message sent!" || warn "Test failed - check token/chat ID"
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    case "${1:-}" in
        --setup|setup)
            load_config
            setup_config
            ;;
        --file|-f)
            load_config
            [[ $# -lt 2 ]] && { err "Usage: $0 -f <file> [chat_id] [caption]"; exit 1; }
            send_file "$2" "${3:-$CHAT_ID}" "${4:-Sent from Metasploit Installer}"
            ;;
        --test|test)
            load_config
            send_telegram "🧪 <b>Test message from Metasploit Installer</b>" "$CHAT_ID"
            ;;
        --help|-h|help)
            cat << USAGE
Usage: bash $(basename "$0") [OPTIONS] "message" [chat_id]

Options:
  --setup            Interactive configuration setup
  -f, --file FILE    Send file/document
  --test             Send test message
  -h, --help         Show this help

Environment variables (or config at ~/.msf4/telegram.env):
  TELEGRAM_BOT_TOKEN    Bot token from @BotFather
  TELEGRAM_CHAT_ID      Target chat ID

Examples:
  $0 "Scan complete"
  $0 "Exploit successful!" 123456789
  $0 -f report.html 123456789 "Daily Report"
  $0 --setup
USAGE
            ;;
        *)
            load_config
            [[ $# -lt 1 ]] && { err "Message required"; exit 1; }
            send_telegram "$1" "${2:-$CHAT_ID}"
            ;;
    esac
}

main "$@"
