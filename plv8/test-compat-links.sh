#!/usr/bin/env bash
# Tests compat-links.sh against a stub lib and extension dir; no V8 build needed.
#   bash plv8/test-compat-links.sh
set -euo pipefail

script=$(cd "$(dirname "$0")" && pwd)/compat-links.sh
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
failed=0

# A stub of what `make install` leaves: the library, the upgrade scripts.
stub() {
  local version=$1; shift
  rm -rf "$tmp/ext" "$tmp/lib"
  mkdir -p "$tmp/ext" "$tmp/lib"
  touch "$tmp/lib/plv8-$version.so" "$tmp/ext/plv8.control" "$tmp/ext/plv8--$version.sql"
  for old in "$@"; do touch "$tmp/ext/plv8--$old--$version.sql"; done
}

# A lib dir as the image gets it: the library plus the made links.
image() {
  local version=$1; shift
  stub "$version" "$@"
  bash "$script" make "$tmp/ext" "$version" "$tmp/links"
  cp -a "$tmp/links/." "$tmp/lib/"
  rm -rf "$tmp/links"
}

expect() { # expect pass|fail <name> -- command...
  local want=$1 name=$2; shift 3
  if "$@" >"$tmp/out" 2>&1; then got=pass; else got=fail; fi
  if [ "$got" = "$want" ]; then echo "ok   $name"; else
    echo "FAIL $name (wanted $want, got $got)"; cat "$tmp/out"; failed=1
  fi
}

check() { bash "$script" check "$tmp/lib" "$tmp/ext" "$1"; }

image 3.2.5 3.2.3 3.2.4
expect pass "links for every upgrade script pass the check" -- check 3.2.5
[ "$(readlink "$tmp/lib/plv8-3.2.4.so")" = plv8-3.2.5.so ] || { echo "FAIL link target"; failed=1; }
[ "$(readlink "$tmp/lib/plv8-3.2.3.so")" = plv8-3.2.5.so ] || { echo "FAIL link target"; failed=1; }

image 3.2.5 3.2.4
rm "$tmp/lib/plv8-3.2.4.so"
expect fail "missing link fails" -- check 3.2.5

image 3.2.5 3.2.4
rm "$tmp/lib/plv8-3.2.4.so"; cp "$tmp/lib/plv8-3.2.5.so" "$tmp/lib/plv8-3.2.4.so"
expect fail "regular file instead of a link fails" -- check 3.2.5

image 3.2.5 3.2.4
ln -sf "$tmp/lib/plv8-3.2.5.so" "$tmp/lib/plv8-3.2.4.so"
expect fail "absolute link fails" -- check 3.2.5

image 3.2.5 3.2.4
ln -sf "../lib/plv8-3.2.5.so" "$tmp/lib/plv8-3.2.4.so"
expect fail "link with a directory part fails" -- check 3.2.5

image 3.2.5 3.2.4
rm "$tmp/lib/plv8-3.2.5.so"
expect fail "link without its library fails" -- check 3.2.5

image 3.2.5 3.2.4
rm "$tmp/ext/plv8--3.2.4--3.2.5.sql"
expect fail "no upgrade script fails" -- check 3.2.5

stub 3.2.5 3.2.4
expect fail "make without a shipped upgrade script fails" -- bash "$script" make "$tmp/ext" 3.2.6 "$tmp/links"

# Next bump: the version it upgrades from gets a link, from the scripts alone.
image 3.2.6 3.2.4 3.2.5
expect pass "after a bump the previous version has a link" -- check 3.2.6
[ "$(readlink "$tmp/lib/plv8-3.2.5.so")" = plv8-3.2.6.so ] || { echo "FAIL bump link target"; failed=1; }

# make writes links only: the library, bitcode and share files stay as they are.
stub 3.2.5 3.2.4
bash "$script" make "$tmp/ext" 3.2.5 "$tmp/links"
[ "$(ls "$tmp/links")" = plv8-3.2.4.so ] || { echo "FAIL make wrote something besides the links"; failed=1; }

exit $failed
