#!/usr/bin/env bash
# ==============================================================================
# EXTERNAL API — VirusTotal, Shodan, Censys, NVD integration
# Usage: source "$SCRIPT_DIR/lib/external_api.sh"
# ==============================================================================

# ── Config ────────────────────────────────────────────────────────────────────
VT_API_KEY="${VT_API_KEY:-}"
SHODAN_API_KEY="${SHODAN_API_KEY:-}"
CENSYS_API_ID="${CENSYS_API_ID:-}"
CENSYS_API_SECRET="${CENSYS_API_SECRET:-}"
NVD_API_KEY="${NVD_API_KEY:-}"

CONFIG_FILE="${HOME}/.msf4/external_api.env"

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        while IFS='=' read -r key val; do
            [[ -z "$key" ]] && continue
            [[ "$key" =~ ^# ]] && continue
            if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
                val="${val%%#*}"; val="${val%%*( )}"
                export "$key=$val"
            fi
        done < <(grep -E '^[A-Z_][A-Z0-9_]*=' "$CONFIG_FILE" 2>/dev/null || true)
    fi
    
    VT_API_KEY="${VT_API_KEY:-}"
    SHODAN_API_KEY="${SHODAN_API_KEY:-}"
    CENSYS_API_ID="${CENSYS_API_ID:-}"
    CENSYS_API_SECRET="${CENSYS_API_SECRET:-}"
    NVD_API_KEY="${NVD_API_KEY:-}"
}

# ── VirusTotal ────────────────────────────────────────────────────────────────
vt_query_ip() {
    local ip="$1"
    [[ -z "$VT_API_KEY" ]] && { echo "VT_API_KEY not set" >&2; return 1; }
    curl -s -H "x-apikey: $VT_API_KEY" "https://www.virustotal.com/api/v3/ip_addresses/$ip" | jq .
}

vt_query_domain() {
    local domain="$1"
    [[ -z "$VT_API_KEY" ]] && { echo "VT_API_KEY not set" >&2; return 1; }
    curl -s -H "x-apikey: $VT_API_KEY" "https://www.virustotal.com/api/v3/domains/$domain" | jq .
}

vt_query_url() {
    local url="$1"
    [[ -z "$VT_API_KEY" ]] && { echo "VT_API_KEY not set" >&2; return 1; }
    local url_id
    url_id=$(echo -n "$url" | base64 | tr -d '=' | tr '/+' '_-')
    curl -s -H "x-apikey: $VT_API_KEY" "https://www.virustotal.com/api/v3/urls/$url_id" | jq .
}

vt_query_hash() {
    local hash="$1"
    [[ -z "$VT_API_KEY" ]] && { echo "VT_API_KEY not set" >&2; return 1; }
    curl -s -H "x-apikey: $VT_API_KEY" "https://www.virustotal.com/api/v3/files/$hash" | jq .
}

# ── Shodan ────────────────────────────────────────────────────────────────────
shodan_host() {
    local ip="$1"
    [[ -z "$SHODAN_API_KEY" ]] && { echo "SHODAN_API_KEY not set" >&2; return 1; }
    curl -s "https://api.shodan.io/shodan/host/$ip?key=$SHODAN_API_KEY" | jq .
}

shodan_search() {
    local query="$1"
    [[ -z "$SHODAN_API_KEY" ]] && { echo "SHODAN_API_KEY not set" >&2; return 1; }
    curl -s "https://api.shodan.io/shodan/host/search?key=$SHODAN_API_KEY&query=$(urlencode "$query")" | jq .
}

shodan_count() {
    local query="$1"
    [[ -z "$SHODAN_API_KEY" ]] && { echo "SHODAN_API_KEY not set" >&2; return 1; }
    curl -s "https://api.shodan.io/shodan/host/count?key=$SHODAN_API_KEY&query=$(urlencode "$query")" | jq .
}

# ── Censys (Bearer Token Auth) ────────────────────────────────────────────────
censys_get_token() {
    [[ -z "$CENSYS_API_ID" || -z "$CENSYS_API_SECRET" ]] && { echo "CENSYS credentials not set" >&2; return 1; }
    curl -s -X POST "https://search.censys.io/api/v1/auth/token" \
        -u "$CENSYS_API_ID:$CENSYS_API_SECRET" \
        -H "Content-Type: application/json" | jq -r '.access_token'
}

censys_search() {
    local query="$1"
    local index="${2:-hosts}"
    local page="${3:-1}"
    local token
    token=$(censys_get_token) || return 1
    
    curl -s -X POST "https://search.censys.io/api/v2/$index/search" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg q "$query" --argjson pg "$page" '{query: $q, page: $pg, per_page: 100}')" | jq .
}

censys_view_host() {
    local ip="$1"
    local token
    token=$(censys_get_token) || return 1
    curl -s "https://search.censys.io/api/v2/hosts/$ip" \
        -H "Authorization: Bearer $token" | jq .
}

# ── NVD (National Vulnerability Database) ────────────────────────────────────
nvd_search_cve() {
    local cve_id="$1"
    local url="https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=$cve_id"
    [[ -n "$NVD_API_KEY" ]] && url+="&apiKey=$NVD_API_KEY"
    curl -s "$url" | jq .
}

nvd_search_keyword() {
    local keyword="$1"
    local results="${2:-10}"
    local url="https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=$(urlencode "$keyword")&resultsPerPage=$results"
    [[ -n "$NVD_API_KEY" ]] && url+="&apiKey=$NVD_API_KEY"
    curl -s "$url" | jq .
}

nvd_search_cpe() {
    local cpe="$1"
    local url="https://services.nvd.nist.gov/rest/json/cves/2.0?cpeName=$(urlencode "$cpe")"
    [[ -n "$NVD_API_KEY" ]] && url+="&apiKey=$NVD_API_KEY"
    curl -s "$url" | jq .
}

# ── Helpers ───────────────────────────────────────────────────────────────────
urlencode() {
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

# ── Setup ─────────────────────────────────────────────────────────────────────
setup_apis() {
    step "External API Configuration"
    
    local vt_key shodan_key censys_id censys_secret nvd_key
    vt_key=$(ask_input "VirusTotal API Key" "$VT_API_KEY")
    shodan_key=$(ask_input "Shodan API Key" "$SHODAN_API_KEY")
    censys_id=$(ask_input "Censys API ID" "$CENSYS_API_ID")
    censys_secret=$(ask_input "Censys API Secret" "$CENSYS_API_SECRET")
    nvd_key=$(ask_input "NVD API Key (optional)" "$NVD_API_KEY")
    
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << CFGEOF
# External API Keys
# Generated: $(date)
VT_API_KEY="$vt_key"
SHODAN_API_KEY="$shodan_key"
CENSYS_API_ID="$censys_id"
CENSYS_API_SECRET="$censys_secret"
NVD_API_KEY="$nvd_key"
CFGEOF
    chmod 600 "$CONFIG_FILE"
    
    log "Config saved to $CONFIG_FILE (chmod 600)"
}

# ── Combined Recon ────────────────────────────────────────────────────────────
recon_all() {
    local target="$1"
    
    info "Running comprehensive recon on $target..."
    
    echo ""
    echo "=== VirusTotal ==="
    vt_query_ip "$target" 2>/dev/null | jq -r '.data.attributes.last_analysis_stats' || echo "VT query failed"
    
    echo ""
    echo "=== Shodan ==="
    shodan_host "$target" 2>/dev/null | jq -r '{ip: .ip_str, ports: .ports, org: .org, asn: .asn, vulns: .vulns}' || echo "Shodan query failed"
    
    echo ""
    echo "=== Censys ==="
    censys_view_host "$target" 2>/dev/null | jq -r '{ip: .ip, ports: .services[].port, labels: .labels}' || echo "Censys query failed"
    
    echo ""
    echo "=== NVD (recent CVEs for common services) ==="
    for port in 22 80 443 445 3389; do
        nvd_search_keyword "port $port" 3 2>/dev/null | jq -r '.vulnerabilities[]?.cve.id' | head -3 || true
    done
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    load_config
    
    case "${1:-}" in
        --setup) setup_apis ;;
        vt-ip) vt_query_ip "${2:-}" ;;
        vt-domain) vt_query_domain "${2:-}" ;;
        vt-url) vt_query_url "${2:-}" ;;
        vt-hash) vt_query_hash "${2:-}" ;;
        shodan-host) shodan_host "${2:-}" ;;
        shodan-search) shodan_search "${2:-}" ;;
        shodan-count) shodan_count "${2:-}" ;;
        censys-search) censys_search "${2:-}" ;;
        censys-host) censys_view_host "${2:-}" ;;
        nvd-cve) nvd_search_cve "${2:-}" ;;
        nvd-keyword) nvd_search_keyword "${2:-}" ;;
        nvd-cpe) nvd_search_cpe "${2:-}" ;;
        recon) recon_all "${2:-}" ;;
        --help|-h)
            cat << USAGE
Usage: bash external_api.sh [COMMAND] [ARGS]

Commands:
  --setup              Interactive API configuration
  vt-ip IP             VirusTotal IP lookup
  vt-domain DOMAIN     VirusTotal domain lookup
  vt-url URL           VirusTotal URL lookup
  vt-hash HASH         VirusTotal file hash lookup
  shodan-host IP       Shodan host lookup
  shodan-search QUERY  Shodan search
  shodan-count QUERY   Shodan result count
  censys-search QUERY  Censys search
  censys-host IP       Censys host view
  nvd-cve CVE-ID       NVD CVE lookup
  nvd-keyword WORD     NVD keyword search
  nvd-cpe CPE          NVD CPE search
  recon TARGET         Full recon (VT + Shodan + Censys + NVD)

Config: ~/.msf4/external_api.env (chmod 600)

USAGE
            ;;
        *) err "Unknown command: $1"; main --help ;;
    esac
}

main "$@"
