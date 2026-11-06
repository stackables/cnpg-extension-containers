#!/usr/bin/env bash
# Keep the library names of older plv8 versions loadable.
#
# A database created with an older plv8 has probin = '$libdir/plv8-<old>' on its
# language functions, and the first statement of plv8--<old>--<new>.sql needs
# that file to load. The image ships only plv8-<new>.so, so each version that
# has an upgrade script to <new> gets a relative symlink plv8-<old>.so ->
# plv8-<new>.so next to it. The versions come from the upgrade scripts the
# image ships, so a bump of PLV8_VERSION needs no edit here.
#
#   compat-links.sh make  <extension dir> <version> <out lib dir>
#   compat-links.sh check <lib dir> <extension dir> <version>
set -euo pipefail

# The <old> of every plv8--<old>--<version>.sql in the extension dir.
old_versions() {
  local extdir=$1 version=$2 script old
  for script in "$extdir"/plv8--*--"$version".sql; do
    [ -e "$script" ] || continue
    old=${script##*/plv8--}
    old=${old%--"$version".sql}
    [ "$old" != "$version" ] && echo "$old"
  done
  return 0
}

die() {
  echo "compat-links: $*" >&2
  exit 1
}

make_links() {
  local extdir=$1 version=$2 out=$3 old found=0
  mkdir -p "$out"
  for old in $(old_versions "$extdir" "$version"); do
    ln -s "plv8-$version.so" "$out/plv8-$old.so"
    found=1
  done
  [ "$found" = 1 ] || die "no plv8--*--$version.sql upgrade script in $extdir"
}

check_links() {
  local lib=$1 extdir=$2 version=$3 old link target found=0
  [ -f "$lib/plv8-$version.so" ] || die "$lib/plv8-$version.so is missing"
  for old in $(old_versions "$extdir" "$version"); do
    found=1
    link=$lib/plv8-$old.so
    [ -L "$link" ] || die "$link is missing or not a symlink"
    target=$(readlink "$link")
    [ "$target" = "plv8-$version.so" ] ||
      die "$link points to '$target', want the relative 'plv8-$version.so'"
  done
  [ "$found" = 1 ] || die "no plv8--*--$version.sql upgrade script in $extdir"
}

case ${1:-} in
  make) [ $# -eq 4 ] || die "usage: make <extension dir> <version> <out lib dir>"
        make_links "$2" "$3" "$4" ;;
  check) [ $# -eq 4 ] || die "usage: check <lib dir> <extension dir> <version>"
        check_links "$2" "$3" "$4" ;;
  *) die "usage: compat-links.sh make|check ..." ;;
esac
