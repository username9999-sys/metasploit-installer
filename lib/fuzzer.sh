#!/usr/bin/env bash
# ==============================================================================
# FUZZER LIBRARY — HTTP fuzzing helpers for Metasploit modules
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/fuzzer.sh"
# ==============================================================================

# ── Dependencies ──────────────────────────────────────────────────────────────
cmd_exists() { command -v "$1" &>/dev/null; }

# ── HTTP Fuzzing ──────────────────────────────────────────────────────────────
# Generic HTTP request with fuzzing capabilities
# Usage: http_fuzz_request "URL" "METHOD" "WORDLIST" "HEADER_TEMPLATE"
# Example: http_fuzz_request "http://target.com/FUZZ" "GET" "/usr/share/wordlists/dirb/common.txt" "User-Agent: Mozilla"
http_fuzz_request() {
    local url_template="$1"
    local method="${2:-GET}"
    local wordlist="$3"
    local header_template="${4:-}"
    local threads="${5:-10}"
    local timeout="${6:-10}"
    
    [[ -z "$url_template" || -z "$wordlist" ]] && { echo "Usage: http_fuzz_request <url_template> [method] <wordlist> [header] [threads] [timeout]"; return 1; }
    [[ ! -f "$wordlist" ]] && { echo "Wordlist not found: $wordlist"; return 1; }
    
    if cmd_exists ffuf; then
        local ffuf_cmd=(
            ffuf
            -u "$url_template"
            -w "$wordlist"
            -X "$method"
            -t "$threads"
            -timeout "$timeout"
            -fc 404
            -mc 200,204,301,302,307,401,403,500
            -o /dev/stdout
            -of json
        )
        
        [[ -n "$header_template" ]] && ffuf_cmd+=(-H "$header_template")
        
        "${ffuf_cmd[@]}" 2>/dev/null | jq -r '.results[] | "\(.url) -> \(.status) (\(.length) bytes)"'
    elif cmd_exists gobuster; then
        gobuster dir -u "${url_template/FUZZ/}" -w "$wordlist" -t "$threads" --timeout "${timeout}s" -q 2>/dev/null
    else
        # Fallback: simple curl loop
        while IFS= read -r word; do
            [[ -z "$word" ]] && continue
            local url="${url_template//FUZZ/$word}"
            local status
            status=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" \
                ${header_template:+-H "$header_template"} \
                --max-time "$timeout" "$url" 2>/dev/null || echo 000)
            [[ "$status" =~ ^(200|204|301|302|307|401|403|500)$ ]] && echo "$url -> $status"
        done < "$wordlist"
    fi
}

# Parameter fuzzing (query string / POST body)
# Usage: http_fuzz_params "http://target.com/page" "POST" "param=FUZZ" "/usr/share/wordlists/fuzz.txt"
http_fuzz_params() {
    local base_url="$1"
    local method="${2:-POST}"
    local param_template="$3"
    local wordlist="$4"
    local threads="${5:-10}"
    
    [[ -z "$base_url" || -z "$param_template" || -z "$wordlist" ]] && { echo "Usage: http_fuzz_params <url> [method] <param_template> <wordlist> [threads]"; return 1; }
    [[ ! -f "$wordlist" ]] && { echo "Wordlist not found"; return 1; }
    
    if cmd_exists ffuf; then
        ffuf -u "$base_url" -X "$method" -d "$param_template" -w "$wordlist" -t "$threads" -fc 404 -mc 200,302,500 -of json 2>/dev/null | \
            jq -r '.results[] | "\(.url) [\(.status)] \(.length)"'
    else
        while IFS= read -r word; do
            [[ -z "$word" ]] && continue
            local data="${param_template//FUZZ/$word}"
            local status
            status=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" -d "$data" --max-time 10 "$base_url" 2>/dev/null || echo 000)
            [[ "$status" =~ ^(200|302|500)$ ]] && echo "$base_url $data -> $status"
        done < "$wordlist"
    fi
}

# ── Header Fuzzing ───────────────────────────────────────────────────────────
# Usage: http_fuzz_headers "http://target.com" "X-Forwarded-For" "/usr/share/wordlists/headers.txt"
http_fuzz_headers() {
    local url="$1"
    local header_name="$2"
    local wordlist="$3"
    local threads="${4:-10}"
    
    [[ -z "$url" || -z "$header_name" || -z "$wordlist" ]] && { echo "Usage: http_fuzz_headers <url> <header_name> <wordlist> [threads]"; return 1; }
    [[ ! -f "$wordlist" ]] && { echo "Wordlist not found"; return 1; }
    
    if cmd_exists ffuf; then
        ffuf -u "$url" -H "${header_name}: FUZZ" -w "$wordlist" -t "$threads" -fc 404 -mc 200,301,302,401,403,500 -of json 2>/dev/null | \
            jq -r '.results[] | "\(.input.FUZZ) -> \(.status) (\(.length) bytes)"'
    else
        while IFS= read -r value; do
            [[ -z "$value" ]] && continue
            local status
            status=$(curl -s -o /dev/null -w "%{http_code}" -H "${header_name}: ${value}" --max-time 10 "$url" 2>/dev/null || echo 000)
            [[ "$status" =~ ^(200|301|302|401|403|500)$ ]] && echo "${header_name}: ${value} -> $status"
        done < "$wordlist"
    fi
}

# ── JSON/API Fuzzing ──────────────────────────────────────────────────────────
# Usage: api_fuzz "http://api.target.com/endpoint" "POST" '{"user":"FUZZ","pass":"test"}' wordlist.txt
api_fuzz() {
    local url="$1"
    local method="${2:-POST}"
    local json_template="$3"
    local wordlist="$4"
    local header="${5:-Content-Type: application/json}"
    local threads="${6:-5}"
    
    [[ -z "$url" || -z "$json_template" || -z "$wordlist" ]] && { echo "Usage: api_fuzz <url> [method] <json_template> <wordlist> [header] [threads]"; return 1; }
    [[ ! -f "$wordlist" ]] && { echo "Wordlist not found"; return 1; }
    
    if cmd_exists ffuf; then
        ffuf -u "$url" -X "$method" -H "$header" -d "$json_template" -w "$wordlist" -t "$threads" -fc 404 -mc 200,201,400,401,403,500 -of json 2>/dev/null | \
            jq -r '.results[] | "\(.input.FUZZ) -> \(.status) (\(.length) bytes)"'
    else
        while IFS= read -r word; do
            [[ -z "$word" ]] && continue
            local data="${json_template//FUZZ/$word}"
            local status
            status=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" -H "$header" -d "$data" --max-time 10 "$url" 2>/dev/null || echo 000)
            [[ "$status" =~ ^(200|201|400|401|403|500)$ ]] && echo "$data -> $status"
        done < "$wordlist"
    fi
}

# ── Helpers ───────────────────────────────────────────────────────────────────
# Get common wordlist paths
get_wordlist() {
    local type="$1"
    case "$type" in
        dirs|directories)  ls /usr/share/wordlists/dirb/common.txt /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt /usr/share/seclists/Discovery/Web-Content/common.txt 2>/dev/null | head -1 ;;
        params|parameters) ls /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt /usr/share/wordlists/wfuzz/generic.txt 2>/dev/null | head -1 ;;
        subdomains)        ls /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt /usr/share/wordlists/subdomains.txt 2>/dev/null | head -1 ;;
        passwords)         ls /usr/share/wordlists/rockyou.txt /usr/share/seclists/Passwords/rockyou.txt 2>/dev/null | head -1 ;;
        headers)           ls /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt 2>/dev/null | head -1 ;;
        *)                 echo "" ;;
    esac
}

# Run ffuf with common presets
ffuf_dirscan() {
    local url="$1"
    local wordlist="${2:-$(get_wordlist dirs)}"
    local threads="${3:-20}"
    local ext="${4:-php,html,txt,js,json,xml,asp,aspx,jsp}"
    
    [[ -z "$wordlist" ]] && { err "No wordlist found for directory scan"; return 1; }
    
    ffuf -u "${url%/}/FUZZ" -w "$wordlist" -t "$threads" -e "$ext" -fc 404 -mc 200,204,301,302,307,401,403,500 -of json 2>/dev/null | \
        jq -r '.results[] | "\(.url) [\(.status)] \(.length)B \(.contentType)"'
}

# Export functions
export -f http_fuzz_request http_fuzz_params http_fuzz_headers api_fuzz get_wordlist ffuf_dirscan
