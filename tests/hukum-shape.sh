#!/usr/bin/env bash
# Asserts references/hukum/<domain>.md exist with frontmatter (domain, verified, sources)
# and that every body bullet ends with [dasar: ...].
# HUKUM_ONLY="a b c" restricts the checked domains (used while the library is built in two phases).
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ALL="ketenagakerjaan perdata hki-rahasia-dagang pidana data-pribadi pajak-jaminan-sosial signing-authority"
LIST="${HUKUM_ONLY:-$ALL}"
fail=0
for d in $LIST; do
  f="$ROOT/references/hukum/$d.md"
  rel="references/hukum/$d.md"
  [ -f "$f" ] || { echo "$rel: No such file or directory"; fail=1; continue; }
  [ "$(sed -n '1p' "$f")" = "---" ] || { echo "$rel: line 1 must be '---'"; fail=1; continue; }
  end=$(awk 'NR>1 && /^---[[:space:]]*$/ {print NR; exit}' "$f")
  [ -n "$end" ] || { echo "$rel: frontmatter not closed"; fail=1; continue; }
  fm=$(sed -n "2,$((end-1))p" "$f")
  echo "$fm" | grep -Eq "^domain: $d[[:space:]]*$" || { echo "$rel: frontmatter 'domain: $d' missing"; fail=1; }
  echo "$fm" | grep -Eq '^verified: [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*$' || { echo "$rel: frontmatter 'verified: YYYY-MM-DD' missing"; fail=1; }
  echo "$fm" | grep -Eq '^sources: \[.+\][[:space:]]*$' || { echo "$rel: frontmatter 'sources: [...]' missing"; fail=1; }
  body=$(sed -n "$((end+1)),\$p" "$f")
  echo "$body" | grep -Eq '^# .+' || { echo "$rel: missing '# Title' heading"; fail=1; }
  nb=$(echo "$body" | grep -c '^- ')
  [ "$nb" -ge 1 ] || { echo "$rel: no bullets"; fail=1; }
  # every non-blank body line must be a heading or a bullet ending in [dasar: ...]
  bad=$(echo "$body" | awk 'NF && $0 !~ /^#/ && $0 !~ /^- .*\[dasar: [^]]+\][[:space:]]*$/ {print NR": "$0}')
  if [ -n "$bad" ]; then
    echo "$rel: lines without trailing [dasar: ...]:"
    echo "$bad" | cut -c1-140
    fail=1
  fi
done
exit $fail
