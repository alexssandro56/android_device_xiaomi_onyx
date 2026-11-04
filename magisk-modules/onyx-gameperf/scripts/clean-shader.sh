#!/system/bin/sh
# ===========================================================================
# clean-shader.sh - clears app shader / GPU caches. Safe: apps just rebuild
# them. Useful after swapping the GPU driver, or when textures glitch.
# (Cache-clean logic credit: Adreno Laboratory uninstall.sh / Peter Noel Muller)
# ===========================================================================
DIR=${0%/*}
. "$DIR/common.sh" 2>/dev/null

n=0
clean() { find $1 2>/dev/null | while read -r x; do rm -rf "$x" 2>/dev/null; done; }

for pat in "*shader*" "*graphitecache*" "*gpucache*"; do
    find /data/user_de/*/*/*cache/* -iname "$pat" -exec rm -rf {} + 2>/dev/null
    find /data/data/* -iname "$pat" -exec rm -rf {} + 2>/dev/null
    find /data_mirror/data*/*/*/*/* -iname "$pat" -exec rm -rf {} + 2>/dev/null
done
rm -rf /data/system/graphicsstats/*/*/* 2>/dev/null
rm -rf /data/resource-cache/*           2>/dev/null

[ -n "$LOG" ] && log "shader/GPU cache cleaned"
echo "Cache de shader/GPU limpo. Reinicie ou reabra o jogo."
