# Metasploit Installer & Toolkit

Installer modular untuk Metasploit Framework + modul referensi pentest terorganisir.

## 🚀 Quick Start

```bash
# Clone repo
git clone https://github.com/username9999-sys/metasploit-installer.git
cd metasploit-installer

# Jalankan launcher
bash msf-run.sh
```

Atau download satu file:

```bash
# Download installer only
curl -O https://raw.githubusercontent.com/username9999-sys/metasploit-installer/main/setup-metasploit.sh
chmod +x setup-metasploit.sh
bash setup-metasploit.sh
```

## 📂 Struktur Direktori

```
metasploit-installer/
├── msf-run.sh                    # 🎯 Launcher utama
├── README.md
├── setup-metasploit.sh           # ⚙️  Installer inti (original)
├── msf-cheatsheet.sh             # 📖 Contekan referensi (original)
├── msf-runbooks.sh               # 📋 Runbook praktis (original)
├── msf-pentest-framework.sh      # 🧠 Framework 5-fase (original)
├── lib/                          # 🔧 Library pendukung
│   ├── common.sh                 #     Colors, logging, helpers
│   ├── env.sh                    #     Deteksi OS/user/path
│   ├── checker.sh                #     Pre-flight prerequisite check
│   ├── deps.sh                   #     Smart dependency installer
│   └── root-bridge.sh            #     Root/non-root bridge helper
├── modules/                      # 📦 Modul-modul (Rapid7-style)
│   ├── scanner/
│   │   ├── smb/smb_scanner.sh
│   │   ├── http/http_scanner.sh
│   │   ├── ssh/ssh_scanner.sh
│   │   └── network/arp_sweep.sh
│   ├── exploit/
│   │   ├── windows/smb_exploits.sh
│   │   ├── windows/rdp_exploits.sh
│   │   └── linux/linux_exploits.sh
│   ├── post/
│   │   ├── windows/windows_post.sh
│   │   └── linux/linux_post.sh
│   ├── auxiliary/
│   │   ├── dos/
│   │   ├── fuzzers/
│   │   └── spoof/
│   └── gather/
│       ├── dns/
│       ├── email/
│       └── web/
├── runbooks/                     # 📋 Runbook per skenario
│   ├── ad-attack.sh              #     Active Directory attack
│   └── web-attack.sh             #     Web application attack
└── cheatsheets/                  # 📖 Contekan per topik
    ├── msf-commands.sh           #     Semua command msfconsole
    └── payloads.sh               #     msfvenom payload generator
```

## 📖 Penggunaan

### Launcher

```bash
bash msf-run.sh              # Menu interaktif
bash msf-run.sh check        # Pre-flight prerequisite check
bash msf-run.sh deps         # Install dependencies saja
bash msf-run.sh install       # Install Metasploit
bash msf-run.sh quick         # Auto-install non-interaktif
bash msf-run.sh cheatsheet    # Referensi command
bash msf-run.sh runbooks      # Runbook pentest
bash msf-run.sh framework     # Framework 5-fase
bash msf-run.sh modules       # Browse modul
bash msf-run.sh module scanner/smb/smb_scanner  # Run modul spesifik
```

### Modul Scanner

```bash
bash modules/scanner/smb/smb_scanner.sh 192.168.1.0/24
bash modules/scanner/http/http_scanner.sh 10.0.0.100
bash modules/scanner/ssh/ssh_scanner.sh 192.168.1.0/24
bash modules/scanner/network/arp_sweep.sh eth0 192.168.1.0/24
```

Setiap modul mencetak perintah `msfconsole` siap-pakai — copy-paste ke msfconsole.

### Modul Exploit

```bash
bash modules/exploit/windows/smb_exploits.sh 10.0.0.50 192.168.1.100
bash modules/exploit/windows/rdp_exploits.sh 10.0.0.50 192.168.1.100
bash modules/exploit/linux/linux_exploits.sh 10.0.0.100 192.168.1.100
```

### Runbook

```bash
bash runbooks/ad-attack.sh corp.local 10.0.0.10 192.168.1.100
bash runbooks/web-attack.sh http://10.0.0.100:8080 192.168.1.100
```

### Cheatsheet

```bash
bash cheatsheets/msf-commands.sh    # Semua command msfconsole
bash cheatsheets/payloads.sh 192.168.1.100  # Payload generator
```

## 🔧 Root vs Non-Root

Script ini mendukung **root** dan **non-root**. Jika Anda root:

```bash
bash msf-run.sh root-bridge    # Buat user normal otomatis
```

Atau manual:
```bash
useradd -m -s /bin/bash msfuser
su - msfuser
cd metasploit-installer && bash msf-run.sh install
```

**Kenapa non-root:** PostgreSQL `initdb` menolak jalan sebagai root (security restriction).

## ✅ Pre-flight Check

Sebelum install, jalankan checker:

```bash
bash msf-run.sh check
# atau:
bash lib/checker.sh --json    # Output JSON untuk CI
```

Checker memvalidasi: OS, disk space, RAM, git, curl, ruby, bundler, PostgreSQL, build tools, libpcap, internet access.

## 📦 Dependency Installer

```bash
bash msf-run.sh deps              # Install semua dependensi
bash lib/deps.sh --dry-run        # Dry run (lihat tanpa install)
bash lib/deps.sh --auto           # Auto mode tanpa prompt
```

Supports: Debian/Ubuntu, Fedora/RHEL, Arch, SUSE, Termux.

## ⚙️ Installer Utama

```bash
bash msf-run.sh install           # Interactive wizard
bash msf-run.sh quick             # Full auto-install
bash setup-metasploit.sh --auto   # Bare auto-install
bash setup-metasploit.sh --check  # Pre-flight only
bash setup-metasploit.sh --help   # Help
```

## 📋 Dependensi Sistem

| Package | Debian/Ubuntu | Fedora/RHEL |
|---------|---------------|-------------|
| Ruby >= 2.7 | `ruby ruby-dev` | `ruby ruby-devel` |
| PostgreSQL | `postgresql postgresql-contrib libpq-dev` | `postgresql postgresql-server postgresql-devel` |
| Build tools | `build-essential` | `gcc gcc-c++ make` |
| Git | `git` | `git` |
| Nmap | `nmap` | `nmap` |
| Libpcap | `libpcap-dev` | `libpcap-devel` |

## 🤝 Contributing

Tambahkan modul baru:
1. Buat file `.sh` di `modules/<category>/<subcategory>/`
2. Format: print perintah msfconsole siap-pakai
3. Test: `bash msf-run.sh module <path>`
4. Submit PR

## ⚠️ Legal

Tools ini untuk **ethical hacking**, **CTF**, dan **penetration testing yang diotorisasi** saja. Penggunaan tanpa izin adalah ilegal. Author tidak bertanggung jawab atas penyalahgunaan.

## License

MIT