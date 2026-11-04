#!/system/bin/sh
# set-fortnite-lang.sh [locale] [quiet]
# Thin wrapper: sets Fortnite's per-app language (default pt-BR) via set-lang.sh.
DIR=${0%/*}
. "$DIR/common.sh"
exec sh "$DIR/set-lang.sh" "$FORTNITE_PKG" "${1:-pt-BR}" "$2"
