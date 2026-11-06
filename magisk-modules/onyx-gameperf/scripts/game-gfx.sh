#!/system/bin/sh
# ===========================================================================
# game-gfx.sh set <pkg> <downscale> <fps>   |   reset <pkg>
# Real per-game graphics control via Android's GameManager (cmd game).
#   downscale: disable (full res) | 0.9 | 0.75 | 0.5 ...
#   fps:       disable (uncapped) | 60 | 90 | 120 ...
#
# Works for games that honor GameManager interventions. Fortnite ignores
# system downscaling (its Qualcomm GSR is internal), so it won't change there.
# ===========================================================================
DIR=${0%/*}
. "$DIR/common.sh" 2>/dev/null

act="$1"; pkg="$2"
[ -n "$pkg" ] || { echo "ERR: sem pacote"; exit 1; }
pm path "$pkg" >/dev/null 2>&1 || { echo "App não instalado: $pkg"; exit 0; }

case "$act" in
    set)
        ds="${3:-disable}"; fps="${4:-disable}"
        if cmd game set --mode performance --downscale "$ds" --fps "$fps" "$pkg" >/dev/null 2>&1; then
            log "game-gfx: $pkg downscale=$ds fps=$fps"
            echo "Aplicado em $pkg — resolução=$ds, fps=$fps. Reabra o jogo."
        else
            log "game-gfx: $pkg intervention refused"
            echo "Este Android/jogo não aceitou (alguns jogos ignoram o GameManager)."
        fi
        ;;
    reset)
        if cmd game reset "$pkg" >/dev/null 2>&1; then
            log "game-gfx: reset $pkg"
            echo "Resetado — $pkg volta ao padrão do próprio jogo."
        else
            echo "Não foi possível resetar (ou não havia intervenção)."
        fi
        ;;
    *)
        echo "uso: game-gfx.sh [set <pkg> <downscale> <fps> | reset <pkg>]"
        exit 1
        ;;
esac
