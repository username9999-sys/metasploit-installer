#!/usr/bin/env bash
# ==============================================================================
# REPORT GENERATOR — Generate pentest reports from Metasploit data
# Usage: bash report_gen.sh [--format html|pdf|md] [--workspace WS] [--output FILE]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/env.sh" 2>/dev/null || true
detect_all 2>/dev/null || true

# ── Defaults ──────────────────────────────────────────────────────────────────
FORMAT="html"
WORKSPACE="default"
OUTPUT_FILE=""
MSF_DIR="${MSF_DIR:-$HOME/.msf4}"
MSF_INSTALL_DIR="${MSF_INSTALL_DIR:-$HOME/metasploit-framework}"
DB_CONFIG="${MSF_DIR}/database.yml"

# ── Helpers ───────────────────────────────────────────────────────────────────
log()   { echo -e "  [✓] $*"; }
info()  { echo -e "  [*] $*"; }
warn()  { echo -e "  [!] $*"; }
err()   { echo -e "  [✗] $*" >&2; }

usage() {
    cat << USAGE
Report Generator - Generate penetration test reports from Metasploit data

Usage: bash report_gen.sh [OPTIONS]

Options:
  --format FORMAT    Output format: html, pdf, md, json (default: html)
  --workspace WS     Metasploit workspace name (default: default)
  --output FILE      Output file path (default: ~/pentest-report-<date>.<ext>)
  --help             Show this help

USAGE
    exit 0
}

# ── Parse Args ────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --format) FORMAT="$2"; shift 2 ;;
        --workspace) WORKSPACE="$2"; shift 2 ;;
        --output) OUTPUT_FILE="$2"; shift 2 ;;
        --help|-h) usage ;;
        *) err "Unknown: $1"; usage ;;
    esac
done

[[ -z "$OUTPUT_FILE" ]] && OUTPUT_FILE="$HOME/pentest-report-$(date +%F).${FORMAT}"

# ── Check DB ──────────────────────────────────────────────────────────────────
[[ -f "$DB_CONFIG" ]] || { err "No database.yml at $DB_CONFIG"; exit 1; }

# ── Load DB Config ────────────────────────────────────────────────────────────
eval "$(grep -E '^\s*(database|username|password|host|port):' "$DB_CONFIG" | sed 's/:\s*/=/' | sed 's/^\s*//')"
[[ -z "${database:-}" ]] && { err "Could not parse database.yml"; exit 1; }

info "Generating report from workspace: $WORKSPACE"
info "Output: $OUTPUT_FILE"

# ── Build Report Data ─────────────────────────────────────────────────────────
REPORT_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
REPORT_TITLE="Penetration Test Report"
REPORT_WORKSPACE="$WORKSPACE"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Export data from report

PSQL_CMD="psql -h ${host:-127.0.0.1} -p ${port:-5432} -U ${username:-msf} -d $database"

[[ -n "${password:-}" ]] && export PGPASSWORD="$password"

# Test connection
$PSQL_CMD -c "SELECT 1" &>/dev/null || { err "Cannot connect to database"; exit 1; }

# ── Extract Data ──────────────────────────────────────────────────────────────
info "Extracting data from database..."

# Hosts
$PSQL_CMD -t -A -F, -c "
    SELECT address, mac, name, os_name, os_flavor, os_sp, purpose, info, comments
    FROM hosts
    WHERE workspace_id = (SELECT id FROM workspaces WHERE name='$WORKSPACE')
" > "$TEMP_DIR/hosts.csv" 2>/dev/null && log "Hosts: $(wc -l < "$TEMP_DIR/hosts.csv")"

# Services
$PSQL_CMD -t -A -F, -c "
    SELECT h.address, s.port, s.proto, s.name, s.info, s.state
    FROM services s
    JOIN hosts h ON s.host_id = h.id
    WHERE h.workspace_id = (SELECT id FROM workspaces WHERE name='$WORKSPACE')
" > "$TEMP_DIR/services.csv" 2>/dev/null && log "Services: $(wc -l < "$TEMP_DIR/services.csv")"

# Vulns
$PSQL_CMD -t -A -F, -c "
    SELECT h.address, v.title, v.name, v.severity, v.description, v.exploited_at
    FROM vulns v
    JOIN hosts h ON v.host_id = h.id
    WHERE h.workspace_id = (SELECT id FROM workspaces WHERE name='$WORKSPACE')
" > "$TEMP_DIR/vulns.csv" 2>/dev/null && log "Vulns: $(wc -l < "$TEMP_DIR/vulns.csv")"

# Creds
$PSQL_CMD -t -A -F, -c "
    SELECT h.address, c.type, c.user, c.password, c.realm, c.source_type
    FROM creds c
    JOIN hosts h ON c.host_id = h.id
    WHERE h.workspace_id = (SELECT id FROM workspaces WHERE name='$WORKSPACE')
" > "$TEMP_DIR/creds.csv" 2>/dev/null && log "Creds: $(wc -l < "$TEMP_DIR/creds.csv")"

# Loot
$PSQL_CMD -t -A -F, -c "
    SELECT h.address, l.ltype, l.path, l.content_type, l.info
    FROM loot l
    JOIN hosts h ON l.host_id = h.id
    WHERE h.workspace_id = (SELECT id FROM workspaces WHERE name='$WORKSPACE')
" > "$TEMP_DIR/loot.csv" 2>/dev/null && log "Loot: $(wc -l < "$TEMP_DIR/loot.csv")"

# Notes
$PSQL_CMD -t -A -F, -c "
    SELECT h.address, n.ntype, n.data
    FROM notes n
    JOIN hosts h ON n.host_id = h.id
    WHERE h.workspace_id = (SELECT id FROM workspaces WHERE name='$WORKSPACE')
" > "$TEMP_DIR/notes.csv" 2>/dev/null && log "Notes: $(wc -l < "$TEMP_DIR/notes.csv")"

# Sessions
$PSQL_CMD -t -A -F, -c "
    SELECT h.address, s.type, s.session_host, s.session_port, s.exploit_uuid, s.last_checkin
    FROM sessions s
    JOIN hosts h ON s.host_id = h.id
    WHERE h.workspace_id = (SELECT id FROM workspaces WHERE name='$WORKSPACE')
" > "$TEMP_DIR/sessions.csv" 2>/dev/null && log "Sessions: $(wc -l < "$TEMP_DIR/sessions.csv")"

# ── Generate Report ───────────────────────────────────────────────────────────
generate_html() {
    cat > "$OUTPUT_FILE" << HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$REPORT_TITLE - $REPORT_WORKSPACE</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; background: #f5f5f5; }
        .header { background: #1a1a2e; color: white; padding: 30px; border-radius: 8px 8px 0 0; }
        .header h1 { margin: 0; font-size: 2em; }
        .header .meta { opacity: 0.8; margin-top: 10px; }
        .section { background: white; margin: 20px 0; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .section h2 { color: #1a1a2e; border-bottom: 2px solid #e94560; padding-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f9fa; font-weight: 600; color: #333; }
        tr:hover { background: #f8f9fa; }
        .severity-critical { background: #fee; color: #c00; font-weight: bold; }
        .severity-high { background: #ffeaa7; color: #b80; font-weight: bold; }
        .severity-medium { background: #e1f0fa; color: #069; }
        .severity-low { background: #e8f8f5; color: #087; }
        .badge { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 0.8em; font-weight: bold; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 15px; margin: 20px 0; }
        .stat-card { background: #1a1a2e; color: white; padding: 20px; border-radius: 8px; text-align: center; }
        .stat-card .num { font-size: 2.5em; font-weight: bold; }
        .stat-card .label { opacity: 0.8; }
    </style>
</head>
<body>
    <div class="header">
        <h1>$REPORT_TITLE</h1>
        <div class="meta">
            Workspace: $REPORT_WORKSPACE | Generated: $REPORT_DATE | Metasploit Framework
        </div>
    </div>
HTML

    # Summary stats
    local h_count=$(wc -l < "$TEMP_DIR/hosts.csv" 2>/dev/null || echo 0)
    local s_count=$(wc -l < "$TEMP_DIR/services.csv" 2>/dev/null || echo 0)
    local v_count=$(wc -l < "$TEMP_DIR/vulns.csv" 2>/dev/null || echo 0)
    local c_count=$(wc -l < "$TEMP_DIR/creds.csv" 2>/dev/null || echo 0)
    local l_count=$(wc -l < "$TEMP_DIR/loot.csv" 2>/dev/null || echo 0)
    local n_count=$(wc -l < "$TEMP_DIR/notes.csv" 2>/dev/null || echo 0)

    cat >> "$OUTPUT_FILE" << STATS
    <div class="section">
        <h2>Executive Summary</h2>
        <div class="stats">
            <div class="stat-card"><div class="num">$h_count</div><div class="label">Hosts</div></div>
            <div class="stat-card"><div class="num">$s_count</div><div class="label">Services</div></div>
            <div class="stat-card"><div class="num">$v_count</div><div class="label">Vulnerabilities</div></div>
            <div class="stat-card"><div class="num">$c_count</div><div class="label">Credentials</div></div>
            <div class="stat-card"><div class="num">$l_count</div><div class="label">Loot Items</div></div>
            <div class="stat-card"><div class="num">$n_count</div><div class="label">Notes</div></div>
        </div>
    </div>
STATS

    # Hosts table
    if [[ $h_count -gt 0 ]]; then
        cat >> "$OUTPUT_FILE" << 'HOSTS'
    <div class="section">
        <h2>Discovered Hosts</h2>
        <table><thead><tr><th>Address</th><th>MAC</th><th>Name</th><th>OS</th><th>Purpose</th><th>Info</th></tr></thead><tbody>
HOSTS
        while IFS=',' read -r addr mac name os_name os_flavor os_sp purpose info comments; do
            cat >> "$OUTPUT_FILE" << HOSTROW
        <tr><td>$addr</td><td>$mac</td><td>$name</td><td>$os_name $os_flavor $os_sp</td><td>$purpose</td><td>$info</td></tr>
HOSTROW
        done < "$TEMP_DIR/hosts.csv"
        cat >> "$OUTPUT_FILE" << 'HOSTEND'
        </tbody></table>
    </div>
HOSTEND
    fi

    # Services
    if [[ $s_count -gt 0 ]]; then
        cat >> "$OUTPUT_FILE" << 'SVCS'
    <div class="section">
        <h2>Services</h2>
        <table><thead><tr><th>Host</th><th>Port</th><th>Proto</th><th>Name</th><th>Info</th><th>State</th></tr></thead><tbody>
SVCS
        while IFS=',' read -r addr port proto name info state; do
            cat >> "$OUTPUT_FILE" << SVCROW
        <tr><td>$addr</td><td>$port</td><td>$proto</td><td>$name</td><td>$info</td><td>$state</td></tr>
SVCROW
        done < "$TEMP_DIR/services.csv"
        cat >> "$OUTPUT_FILE" << 'SVCEND'
        </tbody></table>
    </div>
SVCEND
    fi

    # Vulnerabilities
    if [[ $v_count -gt 0 ]]; then
        cat >> "$OUTPUT_FILE" << 'VULNS'
    <div class="section">
        <h2>Vulnerabilities</h2>
        <table><thead><tr><th>Host</th><th>Title</th><th>Name</th><th>Severity</th><th>Description</th><th>Exploited</th></tr></thead><tbody>
VULNS
        while IFS=',' read -r addr title name severity desc exploited; do
            local sev_class="severity-$(echo "$severity" | tr '[:upper:]' '[:lower:]')"
            cat >> "$OUTPUT_FILE" << VULNROW
        <tr><td>$addr</td><td>$title</td><td>$name</td><td><span class="badge $sev_class">$severity</span></td><td>$desc</td><td>$exploited</td></tr>
VULNROW
        done < "$TEMP_DIR/vulns.csv"
        cat >> "$OUTPUT_FILE" << 'VULNEND'
        </tbody></table>
    </div>
VULNEND
    fi

    # Credentials
    if [[ $c_count -gt 0 ]]; then
        cat >> "$OUTPUT_FILE" << 'CREDS'
    <div class="section">
        <h2>Credentials</h2>
        <table><thead><tr><th>Host</th><th>Type</th><th>User</th><th>Password</th><th>Realm</th><th>Source</th></tr></thead><tbody>
CREDS
        while IFS=',' read -r addr type user pass realm source; do
            cat >> "$OUTPUT_FILE" << CREDSROW
        <tr><td>$addr</td><td>$type</td><td>$user</td><td><code>$pass</code></td><td>$realm</td><td>$source</td></tr>
CREDSROW
        done < "$TEMP_DIR/creds.csv"
        cat >> "$OUTPUT_FILE" << 'CREDSEND'
        </tbody></table>
    </div>
CREDSEND
    fi

    # Footer
    cat >> "$OUTPUT_FILE" << 'FOOTER'
    <div class="section" style="text-align:center; color:#888; font-size:0.9em;">
        Generated by Metasploit Installer Report Generator | Confidential
    </div>
</body>
</html>
FOOTER
}

generate_markdown() {
    {
        echo "# $REPORT_TITLE"
        echo ""
        echo "**Workspace:** $REPORT_WORKSPACE  "
        echo "**Generated:** $REPORT_DATE  "
        echo ""
        echo "---"
        echo ""
        echo "## Executive Summary"
        echo ""
        echo "| Metric | Count |"
        echo "|--------|-------|"
        echo "| Hosts | $(wc -l < "$TEMP_DIR/hosts.csv" 2>/dev/null || echo 0) |"
        echo "| Services | $(wc -l < "$TEMP_DIR/services.csv" 2>/dev/null || echo 0) |"
        echo "| Vulnerabilities | $(wc -l < "$TEMP_DIR/vulns.csv" 2>/dev/null || echo 0) |"
        echo "| Credentials | $(wc -l < "$TEMP_DIR/creds.csv" 2>/dev/null || echo 0) |"
        echo "| Loot Items | $(wc -l < "$TEMP_DIR/loot.csv" 2>/dev/null || echo 0) |"
        echo "| Notes | $(wc -l < "$TEMP_DIR/notes.csv" 2>/dev/null || echo 0) |"
        echo ""

        # Hosts
        if [[ $(wc -l < "$TEMP_DIR/hosts.csv" 2>/dev/null || echo 0) -gt 0 ]]; then
            echo "## Discovered Hosts"
            echo ""
            echo "| Address | MAC | Name | OS | Purpose | Info |"
            echo "|---------|-----|------|----|---------|------|"
            while IFS=',' read -r addr mac name os_name os_flavor os_sp purpose info comments; do
                echo "| $addr | $mac | $name | $os_name $os_flavor $os_sp | $purpose | $info |"
            done < "$TEMP_DIR/hosts.csv"
            echo ""
        fi

        # Vulns
        if [[ $(wc -l < "$TEMP_DIR/vulns.csv" 2>/dev/null || echo 0) -gt 0 ]]; then
            echo "## Vulnerabilities"
            echo ""
            echo "| Host | Title | Name | Severity | Description | Exploited |"
            echo "|------|-------|------|----------|-------------|-----------|"
            while IFS=',' read -r addr title name severity desc exploited; do
                echo "| $addr | $title | $name | **$severity** | $desc | $exploited |"
            done < "$TEMP_DIR/vulns.csv"
            echo ""
        fi

        # Creds
        if [[ $(wc -l < "$TEMP_DIR/creds.csv" 2>/dev/null || echo 0) -gt 0 ]]; then
            echo "## Credentials"
            echo ""
            echo "| Host | Type | User | Password | Realm | Source |"
            echo "|------|------|------|----------|-------|--------|"
            while IFS=',' read -r addr type user pass realm source; do
                echo "| $addr | $type | $user | \`$pass\` | $realm | $source |"
            done < "$TEMP_DIR/creds.csv"
            echo ""
        fi
    } > "$OUTPUT_FILE"
}

generate_json() {
    # Use psql JSON output
    $PSQL_CMD -t -c "
        SELECT json_build_object(
            'workspace', '$WORKSPACE',
            'generated', '$REPORT_DATE',
            'hosts', (SELECT json_agg(json_build_object(
                'address', address, 'mac', mac, 'name', name, 'os', os_name
            )) FROM hosts WHERE workspace_id = (SELECT id FROM workspaces WHERE name='$WORKSPACE')),
            'services', (SELECT json_agg(json_build_object(
                'host', h.address, 'port', s.port, 'proto', s.proto, 'name', s.name, 'info', s.info, 'state', s.state
            )) FROM services s JOIN hosts h ON s.host_id = h.id WHERE h.workspace_id = (SELECT id FROM workspaces WHERE name='$WORKSPACE')),
            'vulns', (SELECT json_agg(json_build_object(
                'host', h.address, 'title', v.title, 'name', v.name, 'severity', v.severity
            )) FROM vulns v JOIN hosts h ON v.host_id = h.id WHERE h.workspace_id = (SELECT id FROM workspaces WHERE name='$WORKSPACE')),
            'creds', (SELECT json_agg(json_build_object(
                'host', h.address, 'type', c.type, 'user', c.user, 'password', c.password, 'realm', c.realm
            )) FROM creds c JOIN hosts h ON c.host_id = h.id WHERE h.workspace_id = (SELECT id FROM workspaces WHERE name='$WORKSPACE'))
        )
    " > "$OUTPUT_FILE" 2>/dev/null
}

# ── Execute ────────────────────────────────────────────────────────────────────
case "$FORMAT" in
    html) generate_html ;;
    md|markdown) generate_markdown ;;
    json) generate_json ;;
    pdf)
        if command -v pandoc &>/dev/null; then
            generate_markdown
            pandoc "$OUTPUT_FILE" -o "${OUTPUT_FILE%.md}.pdf" 2>/dev/null && \
                OUTPUT_FILE="${OUTPUT_FILE%.md}.pdf" && log "PDF generated" || err "Pandoc failed"
        else
            err "pandoc not installed — install for PDF support"
            generate_markdown
        fi
        ;;
    *) err "Unknown format: $FORMAT"; exit 1 ;;
esac

log "Report saved: $OUTPUT_FILE"
info "Open with: xdg-open $OUTPUT_FILE 2>/dev/null || open $OUTPUT_FILE"
