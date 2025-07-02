#!/usr/bin/env bash
set -euo pipefail

# Usage: ./check-gentx.sh gentx1.json [gentx2.json ...]
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <gentx-file> [gentx-file ...]" >&2
  exit 1
fi

fail() {
  echo "❌ $1" >&2
  exit 1
}

for file in "$@"; do
  echo "🔍 Checking $file …"

  [[ -f "$file" ]] || fail "File not found: $file"
  if ! jq empty "$file" &>/dev/null; then
    fail "Invalid JSON: $file"
  fi

  memo=$(jq -r '.body.memo'                       "$file")
  denom=$(jq -r '.body.messages[0].value.denom'   "$file")
  amount=$(jq -r '.body.messages[0].value.amount' "$file")

  # 1) memo must NOT contain private/loopback IPv4
  if printf '%s\n' "$memo" | grep -Eq '([0-9]{1,3}\.){3}[0-9]{1,3}'; then
    ip=$(printf '%s\n' "$memo" \
         | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' \
         | head -n1)
    case $ip in
      10.*|127.*|192.168.*|172.1[6-9].*|172.2[0-9].*|172.3[0-1].*)
        fail "Memo contains private or loopback IP ($ip)";;
    esac
  fi

  # 2) denom must be exactly "utsaga"
  [[ $denom == "utsaga" ]] \
    || fail "Denom is '$denom' (expected 'utsaga')"

  # 3) amount must be exactly "8000000"
  [[ $amount == "8000000" ]] \
    || fail "Amount is '$amount' (expected '8000000')"

  echo "✅ $file passed"
done

echo "All gentx files passed validation."
