#!/usr/bin/env bash
# Fails if real personal or company data leaks into the plugin files.
# Number patterns: whole repo except docs/, research/ (legitimate statute numbers), .gaspol/, .cache/, .git/ and this script.
# Personal-name and personal-path patterns: ALSO docs/ and research/ (only .gaspol/, .cache/, .git/ and this script are skipped).
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SELF="tests/guard-generic.sh"
fail=0
scan() {
  local label="$1" pattern="$2"
  local hits
  hits=$(cd "$ROOT" && grep -rEIn \
    --exclude-dir=docs --exclude-dir=research --exclude-dir=.gaspol --exclude-dir=.git --exclude-dir=.cache --exclude-dir=node_modules \
    --exclude="$(basename "$SELF")" -e "$pattern" . 2>/dev/null)
  if [ -n "$hits" ]; then
    echo "FAIL guard-generic: $label"
    echo "$hits" | head -5
    fail=1
  fi
}
scan_all() {
  local label="$1" pattern="$2" hits
  hits=$(cd "$ROOT" && grep -rEIni \
    --exclude-dir=.gaspol --exclude-dir=.git --exclude-dir=.cache --exclude-dir=node_modules \
    --exclude="$(basename "$SELF")" -e "$pattern" . 2>/dev/null)
  if [ -n "$hits" ]; then
    echo "FAIL guard-generic: $label"
    echo "$hits" | head -5
    fail=1
  fi
}
scan_all "employee first name Herry (case-insensitive, docs/ and research/ included)" 'herry'
scan_all "personal employee folder path my-data/.../Karyawan/" 'my-data/[^ ]*/Karyawan/'
# Absolute home or session paths: allowed only in the INDUSIA-specific default-path files (scripts/, skills/, README), never in tests/ or templates/ or references/.
hits=$(cd "$ROOT" && grep -rEIn --exclude-dir=docs --exclude-dir=research --exclude-dir=.gaspol --exclude-dir=.git --exclude-dir=.cache --exclude-dir=node_modules \
  --exclude="$(basename "$SELF")" -e '/Users/[A-Za-z0-9_.-]+/|/private/tmp/claude-' . 2>/dev/null \
  | grep -vE '^\./(scripts/(build\.sh|md2docx\.js)|skills/[a-z-]+/SKILL\.md|README\.md):' | grep -v '^$')
# in the allow-listed files only the vault and my-data defaults are tolerated, and a session scratch path never
allowed=$(cd "$ROOT" && grep -rEIn --exclude-dir=.cache --exclude-dir=node_modules -e '/Users/[A-Za-z0-9_.-]+/|/private/tmp/claude-' scripts skills README.md 2>/dev/null \
  | sed -E 's#/Users/[A-Za-z0-9_.-]+/Drive-D/(Obsidian-Vault|my-data)/##g' | grep -E '/Users/|/private/tmp/claude-')
hits="$hits$allowed"
if [ -n "$hits" ]; then echo "FAIL guard-generic: absolute /Users/<name>/ or session path outside the allow-list"; echo "$hits" | head -5; fail=1; fi
scan "16-digit number (NIK pattern)" '[0-9]{16}'
scan "forbidden token ktp-" 'ktp-'
scan "forbidden token npwp-" 'npwp-'
scan "literal formatted NPWP value" '[0-9]{2}\.[0-9]{3}\.[0-9]{3}\.[0-9]-[0-9]{3}\.[0-9]{3}'
scan "literal NIB value (13 digits)" '(^|[^0-9])[0-9]{13}([^0-9]|$)'
[ "$fail" -eq 0 ] && echo "PASS guard-generic"
exit "$fail"
