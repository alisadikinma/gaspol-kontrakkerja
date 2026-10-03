#!/usr/bin/env bash
# Fails if real personal or company data leaks into the plugin files.
# Scans the whole repo except docs/, research/, .gaspol/, .git/ and this script.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SELF="tests/guard-generic.sh"
fail=0
scan() {
  local label="$1" pattern="$2"
  local hits
  hits=$(cd "$ROOT" && grep -rEIn \
    --exclude-dir=docs --exclude-dir=research --exclude-dir=.gaspol --exclude-dir=.git \
    --exclude="$(basename "$SELF")" -e "$pattern" . 2>/dev/null)
  if [ -n "$hits" ]; then
    echo "FAIL guard-generic: $label"
    echo "$hits" | head -5
    fail=1
  fi
}
scan "16-digit number (NIK pattern)" '[0-9]{16}'
scan "forbidden word Herry" 'Herry'
scan "forbidden token ktp-" 'ktp-'
scan "forbidden token npwp-" 'npwp-'
scan "literal formatted NPWP value" '[0-9]{2}\.[0-9]{3}\.[0-9]{3}\.[0-9]-[0-9]{3}\.[0-9]{3}'
scan "literal NIB value (13 digits)" '(^|[^0-9])[0-9]{13}([^0-9]|$)'
[ "$fail" -eq 0 ] && echo "PASS guard-generic"
exit "$fail"
