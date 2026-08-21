#!/usr/bin/env bash
# ==============================================================================
# WORDLIST GENERATOR — Generate custom wordlists for brute forcing
# Usage: bash wordlist_gen.sh [OUTPUT_FILE]
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
source "$SCRIPT_DIR/../../../lib/env.sh" 2>/dev/null || true
OUTPUT="${1:-$HOME/wordlists/custom.txt}"
IN_MSF=false; [[ "${MSF_CONSOLE:-}" == "1" ]] || [[ -n "${MSFCONSOLE_BIN:-}" ]] && IN_MSF=true
mkdir -p "$(dirname "$OUTPUT")"
echo ""; echo "=== WORDLIST GENERATOR ==="; echo "Output: $OUTPUT"; echo ""
echo -e "--- ${BLUE}Base Wordlists${NC} ---"
echo "# RockYou: /usr/share/wordlists/rockyou.txt"
echo "# SecLists: /usr/share/seclists/"
echo "# Weakpass: https://weakpass.com/wordlist/"
echo ""
echo -e "--- ${BLUE}Generate Custom${NC} ---"
cat > /tmp/gen_wordlist.py << 'PYEOF'
import sys, itertools, string
out = sys.argv[1]
base = sys.argv[2] if len(sys.argv) > 2 else {}
chars = string.ascii_lowercase + string.digits + "!@#$%"
min_len = int(sys.argv[3]) if len(sys.argv) > 3 else 8
max_len = int(sys.argv[4]) if len(sys.argv) > 4 else 12
words = set()
# From base wordlist
if base:
    with open(base) as f:
        for line in f:
            w = line.strip()
            if min_len <= len(w) <= max_len:
                words.add(w)
# Mutate: append numbers, caps
for w in list(words)[:1000]:
    for i in range(100): words.add(f"{w}{i}")
    words.add(w.capitalize()); words.add(w.upper())
# Generate
with open(out, 'w') as f:
    for w in words:
        if min_len <= len(w) <= max_len: f.write(w + "\n")
print(f"Generated {len(words)} words in {out}")
PYEOF
echo "python3 /tmp/gen_wordlist.py $OUTPUT /usr/share/wordlists/rockyou.txt 8 12"
echo ""
echo -e "--- ${BLUE}Crunch (install: apt install crunch)${NC} ---"
echo "crunch 8 12 abcdefghijklmnopqrstuvwxyz0123456789!@# -o $OUTPUT"
echo ""
echo -e "--- ${BLUE}Hashcat Rule Generation${NC} ---"
echo "hashcat --generate-rules=/usr/share/hashcat/rules/d3ad0ne.rule --stdout wordlist.txt > mutated.txt"
echo ""
echo -e "--- ${BLUE}CeWL (web spider)${NC} ---"
echo "cewl -d 2 -m 5 -w $OUTPUT https://target.com"
echo "# Install: gem install cewl"
