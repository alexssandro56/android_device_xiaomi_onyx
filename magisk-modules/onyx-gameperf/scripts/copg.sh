#!/system/bin/sh
# ===========================================================================
# copg.sh [status|apply]
# Manages the config of the SEPARATE COPG Zygisk module (per-game spoof).
# This module does NOT embed COPG's engine (that needs Zygisk native code);
# it only writes COPG's config when COPG is installed.
# ===========================================================================
DIR=${0%/*}
. "$DIR/common.sh" 2>/dev/null

COPG_DIR=/data/adb/modules/COPG
SRC="$MODDIR/copg/COPG.json"

case "${1:-status}" in
    status)
        [ -d "$COPG_DIR" ] && echo "INSTALLED" || echo "MISSING"
        ;;
    apply)
        if [ ! -d "$COPG_DIR" ]; then
            echo "COPG não está instalado. Instale o módulo COPG (+ Zygisk) primeiro."
            exit 0
        fi
        [ -f "$SRC" ] || { echo "ERR: config não encontrada no módulo."; exit 1; }
        [ -f "$COPG_DIR/COPG.json" ] && cp -f "$COPG_DIR/COPG.json" "$COPG_DIR/COPG.json.bak" 2>/dev/null
        if cp -f "$SRC" "$COPG_DIR/COPG.json" 2>/dev/null; then
            log "copg: config applied to $COPG_DIR"
            echo "Config aplicada no COPG (4 perfis). Reinicie o aparelho."
        else
            echo "ERR: não consegui escrever em $COPG_DIR."
        fi
        ;;
    *)
        echo "uso: copg.sh [status|apply]"
        exit 1
        ;;
esac
