#!/usr/bin/env bash
# ==============================================================================
# VULNERABILITY VALIDATOR — Validate and verify findings from scans
# Usage: source "$SCRIPT_DIR/lib/validator.sh"
# ==============================================================================

# ── Nmap JSON Output Parser ───────────────────────────────────────────────────
# Parse nmap -oJ output and extract actionable data
nmap_parse_json() {
    local json_file="$1"
    [[ ! -f "$json_file" ]] && { echo "File not found: $json_file" >&2; return 1; }
    
    if ! command -v jq &>/dev/null; then
        echo "jq required for JSON parsing" >&2
        return 1
    fi
    
    jq -r '
        .nmaprun.host[]? |
        select(.status.state == "up") |
        [
            .address[] | select(.addrtype == "ipv4") | .addr,
            (.ports.port[]? | select(.state.state == "open") |
                [
                    .portid,
                    .protocol,
                    .service.name,
                    .service.product,
                    .service.version,
                    .service.extrainfo,
                    (.scripts.script[]? | "\(.id):\(.output)")
                ] | @csv
            )
        ] | @csv
    ' "$json_file" 2>/dev/null | sed 's/""//g'
}

# Extract nmap template IDs from JSON for Nuclei correlation
nmap_extract_cpes() {
    local json_file="$1"
    jq -r '.nmaprun.host[]?.ports.port[]?.service.cpe[]? // empty' "$json_file" 2>/dev/null | sort -u
}

# ── Nuclei Template Validation ────────────────────────────────────────────────
# Validate nuclei template IDs match installed templates
nuclei_validate_templates() {
    local template_list="$1"
    local nuclei_bin="${2:-$(command -v nuclei)}"
    
    [[ -z "$nuclei_bin" ]] && { echo "Nuclei not found" >&2; return 1; }
    
    # Get available templates
    local available_templates
    available_templates=$($nuclei_bin -tl 2>/dev/null | awk '{print $1}' | sort -u)
    
    if [[ -f "$template_list" ]]; then
        while IFS= read -r template_id; do
            [[ -z "$template_id" ]] && continue
            if echo "$available_templates" | grep -qx "$template_id"; then
                echo "✓ $template_id"
            else
                echo "✗ $template_id (NOT INSTALLED)"
            fi
        done < "$template_list"
    else
        # Single template ID
        if echo "$available_templates" | grep -qx "$template_list"; then
            echo "✓ $template_list"
        else
            echo "✗ $template_list (NOT INSTALLED)"
            return 1
        fi
    fi
}

# Run nuclei with validation and deduplication
nuclei_validate_scan() {
    local target="$1"
    local template_dir="${2:-}"
    local severity="${3:-critical,high,medium}"
    local output_file="${4:-}"
    
    local nuclei_opts=(-u "$target" -severity "$severity" -json -silent)
    
    [[ -n "$template_dir" && -d "$template_dir" ]] && nuclei_opts+=(-t "$template_dir")
    
    if [[ -n "$output_file" ]]; then
        nuclei "${nuclei_opts[@]}" -o "$output_file"
    else
        nuclei "${nuclei_opts[@]}"
    fi
}

# ── Vulnerability Verification ────────────────────────────────────────────────
# Verify if a specific CVE is exploitable against a target
verify_cve() {
    local target="$1"
    local cve_id="$2"
    local msf_exploit="${3:-}"
    
    info "Verifying $cve_id against $target..."
    
    # Check if we have a Metasploit module for this CVE
    if [[ -n "$msf_exploit" ]]; then
        if msfconsole -q -x "use $msf_exploit; set RHOSTS $target; set VERBOSE false; run; exit" 2>&1 | grep -q "Exploit completed"; then
            log "EXPLOITABLE: $cve_id via $msf_exploit"
            return 0
        fi
    fi
    
    # Try nuclei
    if command -v nuclei &>/dev/null; then
        if nuclei -u "$target" -tags cve -filter "cve:$cve_id" -silent -json 2>/dev/null | grep -q "$cve_id"; then
            log "DETECTED: $cve_id via Nuclei"
            return 0
        fi
    fi
    
    warn "NOT VERIFIED: $cve_id against $target"
    return 1
}

# Verify SMB vulnerabilities
verify_smb_vulns() {
    local target="$1"
    
    local vulns=("ms17-010" "ms08-067" "smbghost" "smbghost-cve-2020-0796")
    local verified=()
    
    for vuln in "${vulns[@]}"; do
        if timeout 30 nmap --script "smb-vuln-${vuln}" "$target" 2>/dev/null | grep -q "VULNERABLE"; then
            log "SMB $vuln: VULNERABLE"
            verified+=("$vuln")
        else
            info "SMB $vuln: Not vulnerable"
        fi
    done
    
    printf '%s\n' "${verified[@]}"
}

# Verify RDP vulnerabilities
verify_rdp_vulns() {
    local target="$1"
    
    # BlueKeep
    if timeout 30 nmap -p 3389 --script rdp-vuln-ms12-020 "$target" 2>/dev/null | grep -q "VULNERABLE"; then
        log "BlueKeep (MS12-020): VULNERABLE"
        echo "bluekeep"
    fi
    
    # CVE-2019-0708
    if timeout 30 nmap -p 3389 --script rdp-vuln-cve2019-0708 "$target" 2>/dev/null | grep -q "VULNERABLE"; then
        log "BlueKeep CVE-2019-0708: VULNERABLE"
        echo "cve-2019-0708"
    fi
}

# Verify web vulnerabilities
verify_web_vulns() {
    local target="$1"
    local verified=()
    
    # Shellshock
    if timeout 30 nmap --script http-shellshock "$target" 2>/dev/null | grep -q "VULNERABLE"; then
        log "Shellshock: VULNERABLE"
        verified+=("shellshock")
    fi
    
    # Struts
    if timeout 30 nmap --script http-vuln-cve2017-5638 "$target" 2>/dev/null | grep -q "VULNERABLE"; then
        log "Struts CVE-2017-5638: VULNERABLE"
        verified+=("struts-cve2017-5638")
    fi
    
    # Jenkins
    if timeout 30 nmap --script http-jenkins-enum "$target" 2>/dev/null | grep -q "VULNERABLE"; then
        log "Jenkins: VULNERABLE"
        verified+=("jenkins")
    fi
    
    printf '%s\n' "${verified[@]}"
}

# ── Cross-reference with ExploitDB ────────────────────────────────────────────
# Search exploitdb for verified exploits
search_exploitdb() {
    local search_term="$1"
    local exact="${2:-false}"
    
    if command -v searchsploit &>/dev/null; then
        if [[ "$exact" == "true" ]]; then
            searchsploit -e "$search_term"
        else
            searchsploit "$search_term"
        fi
    else
        warn "searchsploit not installed"
    fi
}

# ── Metasploit Module Verification ────────────────────────────────────────────
# Check if exploit module exists and get details
msf_check_module() {
    local module="$1"
    msfconsole -q -x "use $module; info; exit" 2>&1 | head -50
}

# Get compatible payloads for exploit
msf_compatible_payloads() {
    local exploit="$1"
    msfconsole -q -x "use $exploit; show payloads; exit" 2>&1 | grep -E '^   \w+/\w+' | awk '{print $1}'
}

# ── Report Validation ─────────────────────────────────────────────────────────
# Validate a pentest report for completeness
validate_report() {
    local report_file="$1"
    local issues=0
    
    [[ ! -f "$report_file" ]] && { err "Report not found"; return 1; }
    
    # Required sections
    local required=("Executive Summary" "Methodology" "Findings" "Risk Rating" "Recommendations" "Appendices")
    
    for section in "${required[@]}"; do
        if grep -qi "$section" "$report_file"; then
            log "Section found: $section"
        else
            warn "Missing section: $section"
            ((issues++))
        fi
    done
    
    # Check for CVSS scores
    if grep -qE "CVSS.*[0-9]\.[0-9]" "$report_file"; then
        log "CVSS scores present"
    else
        warn "No CVSS scores found"
        ((issues++))
    fi
    
    # Check for evidence/screenshots
    if grep -qiE "(screenshot|evidence|proof|poc)" "$report_file"; then
        log "Evidence references found"
    else
        warn "No evidence/Poc references"
        ((issues++))
    fi
    
    [[ $issues -eq 0 ]] && log "Report validation PASSED" || warn "Report validation: $issues issues found"
}

# ── Export ────────────────────────────────────────────────────────────────────
export -f nmap_parse_json nmap_extract_cpes nuclei_validate_templates nuclei_validate_scan
export -f verify_cve verify_smb_vulns verify_rdp_vulns verify_web_vulns
export -f search_exploitdb msf_check_module msf_compatible_payloads validate_report
