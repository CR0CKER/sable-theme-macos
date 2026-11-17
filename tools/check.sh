#!/bin/sh
# check.sh: the repo's one gate, run locally and in CI.
#   1. The built *.sable.css files are current (./build.sh changes nothing).
#   2. Each built theme has a complete @sable-theme header.
#   3. No selector uses Sable's per-build svelte-* class hashes.
set -eu
cd "$(dirname "$0")/.."
fail=0

./build.sh >/dev/null
if ! git diff --quiet -- '*.sable.css'; then
  echo "FAIL: built themes are out of date; run ./build.sh and commit the result" >&2
  git diff --stat -- '*.sable.css' >&2
  fail=1
fi

for f in macos-light macos-dark macos-flat-light macos-flat-dark; do
  file="$f.sable.css"
  [ -f "$file" ] || { echo "FAIL: $file missing" >&2; fail=1; continue; }
  head -1 "$file" | grep -qx '/\*' || { echo "FAIL: $file does not start with the header comment" >&2; fail=1; }
  grep -qx '@sable-theme' "$file" || { echo "FAIL: $file: no @sable-theme line" >&2; fail=1; }
  grep -qx "id: $f" "$file" || { echo "FAIL: $file: id is not $f" >&2; fail=1; }
  for key in name author description kind contrast tags; do
    grep -q "^$key: ." "$file" || { echo "FAIL: $file: header field '$key' missing" >&2; fail=1; }
  done
done

if grep -nE 'svelte-[a-z0-9]{5,}' src/*.css >&2; then
  echo "FAIL: selectors above use svelte-* hashes, which change with every Sable build" >&2
  fail=1
fi

[ "$fail" -eq 0 ] && echo "OK: themes current, headers complete, no svelte-* hashes"
exit "$fail"
