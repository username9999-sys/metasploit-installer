#!/usr/bin/env bash
# ==============================================================================
# AUTO CRACK — Automated hash cracking with multiple tools
# Usage: bash auto_crack.sh <HASH_FILE> [HASH_TYPE]
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
HASH_FILE="${1:-}"; HASH_TYPE="${2:-}"
[[ -z "$HASH_FILE" ]] && { echo "Usage: bash auto_crack.sh <hash_file> [hash_type]"; exit 1; }
[[ -f "$HASH_FILE" ]] || { echo "File not found: $HASH_FILE"; exit 1; }
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
echo ""; echo "=== AUTO CRACK ===Hash file: $HASH_FILE"; [[ -n "$HASH_TYPE" ]] && echo "Type: $HASH_TYPE"; echo ""
echo -e "--- ${BLUE}Identify Hash Type${NC} ---"
echo "hash-identifier $HASH_FILE"
echo "hashid -m $HASH_FILE"
echo ""
echo -e "--- ${BLUE}Hashcat${NC} ---"
echo "# Install: apt install hashcat"
echo "# Common hash types: 0=MD5, 100=SHA1, 1400=SHA256, 1800=SHA512, 1000=NTLM, 3200=bcrypt"
if [[ -n "$HASH_TYPE" ]]; then
    echo "hashcat -m $HASH_TYPE -a 0 $HASH_FILE /usr/share/wordlists/rockyou.txt"
    echo "hashcat -m $HASH_TYPE -a 3 $HASH_FILE ?d?d?d?d?d?d?d?d  # 8-digit mask"
    echo "hashcat -m $HASH_TYPE -a 6 $HASH_FILE /usr/share/wordlists/rockyou.txt /usr/share/hashcat/rules/best64.rule"
else
    echo "hashcat -m 1000 -a 0 $HASH_FILE /usr/share/wordlists/rockyou.txt  # NTLM"
    echo "hashcat -m 0 -a 0 $HASH_FILE /usr/share/wordlists/rockyou.txt      # MD5"
fi
echo ""
echo -e "--- ${BLUE}John the Ripper${NC} ---"
echo "# Install: apt install john"
echo "john --wordlist=/usr/share/wordlists/rockyou.txt $HASH_FILE"
echo "john --format=nt --wordlist=/usr/share/wordlists/rockyou.txt $HASH_FILE  # NTLM"
echo "john --show $HASH_FILE"
echo ""
echo -e "--- ${BLUE}CrackMapExec${NC} ---"
echo "# For SMB/AD hashes"
echo "crackmapexec smb <target> -u <user> -H <hash>"
echo ""
echo -e "--- ${BLUE}Online Resources${NC} ---"
echo "# Upload to: https://crackstation.net/, https://hashes.com/, https://www.onlinehashcrack.com/"
echo "# Or: https://github.com/HashPals/Name-That-Hash"
