#!/system/bin/sh
# ===========================================================================
# thermal.sh [get|default|cool|game|set N]
# Named thermal profiles via the device's own sconfig node.
#
# IMPORTANT: Xiaomi's thermald continuously rewrites sconfig based on the
# current app/scene, so a single write can be reverted within ~1s. To make a
# profile "stick" a bit longer we write the value a few times in a row. This
# is a one-shot apply (no background daemon), per the user's choice.
#
# Profiles:
#   default (Equilíbrio) -> sconfig=0 (verified normal) + powersave off
#   cool    (Resfriar)   -> powersave_mode=1 (more conservative = cooler)
#   game    (Jogo)       -> applies the sconfig value you saved via 'set N'
#   set N                -> saves N as your game value AND applies it
# We never ship a throttle-disabling value; you discover your device's game
# scene number with the Monitor and save it here.
# ===========================================================================
DIR=${0%/*}
. "$DIR/common.sh" 2>/dev/null

NODE=/sys/class/thermal/thermal_message/sconfig
PSAVE=/sys/class/thermal/power_save/powersave_mode
GVAL="$CONFIG_DIR/thermal_game.val"

# write a value several times to beat thermald's immediate reset
wsc() {
    i=0
    while [ $i -lt 5 ]; do
        echo "$1" > "$NODE" 2>/dev/null
        i=$((i+1))
        sleep 0.3
    done
}

case "${1:-get}" in
    get)
        cat "$NODE" 2>/dev/null
        ;;
    default|balance)
        echo 0 > "$PSAVE" 2>/dev/null
        wsc 0
        log "thermal: balanced (sconfig=0)"
        echo "Perfil: Balanceado (sconfig=0)."
        ;;
    cool|battery)
        echo 1 > "$PSAVE" 2>/dev/null
        log "thermal: battery (powersave=1)"
        echo "Perfil: Bateria (térmico conservador, esquenta menos)."
        ;;
    game)
        v="$(cat "$GVAL" 2>/dev/null)"
        case "$v" in ''|*[!0-9]*) echo "Defina antes o valor de Performance (campo abaixo)."; exit 0 ;; esac
        echo 0 > "$PSAVE" 2>/dev/null
        wsc "$v"
        log "thermal: performance (sconfig=$v)"
        echo "Perfil: Performance (sconfig=$v). Pode voltar sozinho em segundos."
        ;;
    set)
        v="$2"
        case "$v" in ''|*[!0-9]*) echo "ERR: número inválido"; exit 1 ;; esac
        echo "$v" > "$GVAL"
        echo 0 > "$PSAVE" 2>/dev/null
        wsc "$v"
        log "thermal: set performance=$v"
        echo "Valor de Performance salvo ($v) e aplicado."
        ;;
    *)
        echo "uso: thermal.sh [get|default|cool|game|set N]"
        exit 1
        ;;
esac
