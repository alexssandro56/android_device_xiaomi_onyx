#!/system/bin/sh
# ===========================================================================
# apply-tweaks.sh - applies all runtime tweaks. Safe to run multiple times.
# Called by service.sh at boot, and by the WebUI / action button on demand.
# ===========================================================================

DIR=${0%/*}
. "$DIR/common.sh"

ensure_games_file
log "apply-tweaks: start"

# ---------------------------------------------------------------------------
# 1) GameManager interventions: performance mode + NO downscale (full res).
# ---------------------------------------------------------------------------
applied=0
while IFS= read -r pkg; do
    pkg="$(echo "$pkg" | tr -d ' \t\r')"
    [ -z "$pkg" ] && continue
    case "$pkg" in \#*) continue ;; esac
    pkg_installed "$pkg" || continue
    if cmd game set --mode performance --downscale disable "$pkg" >/dev/null 2>&1; then
        applied=$((applied+1))
    elif cmd game mode 2 "$pkg" >/dev/null 2>&1; then
        applied=$((applied+1))
    fi
done < "$GAMES_FILE"
log "apply-tweaks: game interventions applied to $applied package(s)"

# ---------------------------------------------------------------------------
# 2) Best-effort Fortnite language = Portuguese (Brazil).
# ---------------------------------------------------------------------------
"$DIR/set-fortnite-lang.sh" pt-BR quiet

# ---------------------------------------------------------------------------
# 3) Light I/O tuning (UFS) - lower latency, no risk.
# ---------------------------------------------------------------------------
for q in /sys/block/sd*/queue /sys/block/mmcblk0/queue; do
    [ -d "$q" ] || continue
    if grep -q "none" "$q/scheduler" 2>/dev/null; then
        echo none > "$q/scheduler" 2>/dev/null
    elif grep -q "mq-deadline" "$q/scheduler" 2>/dev/null; then
        echo mq-deadline > "$q/scheduler" 2>/dev/null
    fi
    echo 256 > "$q/read_ahead_kb" 2>/dev/null
done

# ---------------------------------------------------------------------------
# 4) Light VM / memory tuning.
# ---------------------------------------------------------------------------
echo 100 > /proc/sys/vm/swappiness            2>/dev/null
echo 20  > /proc/sys/vm/dirty_ratio           2>/dev/null
echo 5   > /proc/sys/vm/dirty_background_ratio 2>/dev/null
echo 150 > /proc/sys/vm/vfs_cache_pressure    2>/dev/null

log "apply-tweaks: I/O + VM tuning applied"
log "apply-tweaks: done"
echo "OK: $applied jogo(s) ajustado(s). Idioma e tuning aplicados."
