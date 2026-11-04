#!/system/bin/sh
# ===========================================================================
# games.sh - read / write the editable games list for the WebUI.
#   games.sh list              -> prints the current games.list (creates default)
#   games.sh set <base64>      -> overwrites games.list with decoded content
#
# File format: one package per line. A line starting with '#' is DISABLED
# (apply-tweaks.sh skips it). Enabled games are bare package names.
# ===========================================================================

DIR=${0%/*}
. "$DIR/common.sh"
ensure_games_file

case "${1:-list}" in
    list)
        cat "$GAMES_FILE"
        ;;
    set)
        [ -n "$2" ] || { echo "ERR: sem conteudo"; exit 1; }
        tmp="$CONFIG_DIR/.games.tmp"
        if echo "$2" | base64 -d > "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
            # Basic sanity: keep only lines that look like a package (or #package).
            grep -E '^[#]?[A-Za-z][A-Za-z0-9._]+$' "$tmp" > "$GAMES_FILE" 2>/dev/null
            rm -f "$tmp"
            n="$(grep -cvE '^\s*(#|$)' "$GAMES_FILE" 2>/dev/null || echo 0)"
            log "games.sh: list saved ($n enabled)"
            echo "OK: lista salva ($n jogo(s) ligado(s))"
        else
            rm -f "$tmp"
            echo "ERR: conteudo invalido"
            exit 1
        fi
        ;;
    *)
        echo "uso: games.sh [list|set <base64>]"
        exit 1
        ;;
esac
