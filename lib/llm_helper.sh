#!/usr/bin/env bash
# ==============================================================================
# LLM HELPER — Common functions for AI integration (Ollama/OpenAI)
# Source this in scripts that need AI capabilities
# ==============================================================================

# Defaults - can be overridden by env vars
: "${OLLAMA_URL:=http://localhost:11434}"
: "${OLLAMA_MODEL:=llama3.1}"
: "${OPENAI_API_KEY:=}"
: "${OPENAI_MODEL:=gpt-4o}"

# ── Query Ollama ─────────────────────────────────────────────────────────────
llm_ollama() {
    local prompt="$1"
    local system_prompt="${2:-You are a cybersecurity expert. Provide practical, safe guidance.}"
    
    if ! command -v jq &>/dev/null; then
        echo "Error: jq required for JSON processing" >&2
        return 1
    fi
    
    if ! curl -sf "$OLLAMA_URL/api/tags" >/dev/null 2>&1; then
        echo "Error: Ollama not running at $OLLAMA_URL" >&2
        return 1
    fi
    
    local payload
    payload=$(jq -n \
        --arg model "$OLLAMA_MODEL" \
        --arg prompt "$prompt" \
        --arg system "$system_prompt" \
        '{model: $model, prompt: $prompt, system: $system, stream: false}')
    
    curl -sf "$OLLAMA_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d "$payload" | jq -r '.response'
}

# ── Query OpenAI ─────────────────────────────────────────────────────────────
llm_openai() {
    local prompt="$1"
    local system_prompt="${2:-You are a cybersecurity expert. Provide practical, safe guidance.}"
    
    [[ -z "$OPENAI_API_KEY" ]] && { echo "Error: OPENAI_API_KEY not set" >&2; return 1; }
    
    if ! command -v jq &>/dev/null; then
        echo "Error: jq required" >&2
        return 1
    fi
    
    local payload
    payload=$(jq -n \
        --arg model "$OPENAI_MODEL" \
        --arg system "$system_prompt" \
        --arg user "$prompt" \
        '{model: $model, messages: [{"role": "system", "content": $system}, {"role": "user", "content": $user}], temperature: 0.3}')
    
    curl -sf https://api.openai.com/v1/chat/completions \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$payload" | jq -r '.choices[0].message.content'
}

# ── Smart Dispatch (tries Ollama first, falls back to OpenAI) ────────────────
llm_query() {
    local prompt="$1"
    local system_prompt="${2:-}"
    
    if curl -sf "$OLLAMA_URL/api/tags" >/dev/null 2>&1; then
        llm_ollama "$prompt" "$system_prompt"
    elif [[ -n "$OPENAI_API_KEY" ]]; then
        llm_openai "$prompt" "$system_prompt"
    else
        echo "Error: No LLM backend available. Start ollama serve or set OPENAI_API_KEY" >&2
        return 1
    fi
}

# ── Structured Output Helpers ────────────────────────────────────────────────
llm_json() {
    local prompt="$1"
    local schema="$2"
    local system="Output ONLY valid JSON matching this schema: $schema"
    
    llm_query "$prompt" "$system"
}

# ── Metasploit-specific prompts ──────────────────────────────────────────────
msf_recon_prompt() {
    local target="$1"
    cat << PROMPT
Target: $target
Provide a step-by-step Metasploit reconnaissance plan including:
1. Nmap scan commands (with specific flags)
2. MSF auxiliary/scanner modules to run
3. Database import commands
4. Service enumeration steps
5. Vulnerability scanning approach
Format as copy-pasteable msfconsole commands.
PROMPT
}

msf_exploit_prompt() {
    local service="$1"
    local version="${2:-unknown}"
    cat << PROMPT
Service: $service $version
List Metasploit exploit modules with:
- Full module path
- Required options (RHOSTS, LHOST, etc.)
- Recommended payloads
- Check command syntax
- Common pitfalls
PROMPT
}

msf_post_prompt() {
    local os="$1"
    cat << PROMPT
Post-exploitation for $os target. Provide Metasploit modules/commands for:
1. Privilege escalation (getsystem, local exploits, UAC bypass)
2. Credential harvesting (kiwi/mimikatz, hashdump, browser creds)
3. Persistence (registry, services, WMI, scheduled tasks)
4. Lateral movement (psexec, wmi, pass-the-hash, pivoting)
5. Data exfiltration (screenshot, keylog, download, search)
6. Cleanup (clearev, timestomp, artifact removal)
Format as msfconsole/meterpreter commands.
PROMPT
}

# Export functions
export -f llm_ollama llm_openai llm_query llm_json
export -f msf_recon_prompt msf_exploit_prompt msf_post_prompt
