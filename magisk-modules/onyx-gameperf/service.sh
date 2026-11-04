#!/system/bin/sh
# ===========================================================================
# POCO F7 (onyx) Game & Performance Tweaks  -  service.sh
# Runs in late_start service mode (after /data is decrypted).
# ===========================================================================

MODDIR=${0%/*}
LOG=/data/local/tmp/onyx_gameperf.log
: > "$LOG"
log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG"; }

# Wait until the system has fully booted before touching services.
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done
# A little extra settle time so package manager / game service are up.
sleep 25

log "boot completed, applying tweaks"

# ---------------------------------------------------------------------------
# 1) GameManager interventions  (the part that actually helps "blurry" games)
# ---------------------------------------------------------------------------
# Android's GameManager can silently DOWNSCALE a game's render buffer to save
# power -> that is a common cause of a soft/blurry image. We force:
#   * performance game mode
#   * downscaling DISABLED (render at full resolution)
# for a list of popular games. Unknown/not-installed packages are ignored.
#
# We try the modern 'cmd game set' syntax first, then the older numeric form.

apply_game() {
    pkg="$1"
    # Skip if the package is not installed.
    pm path "$pkg" >/dev/null 2>&1 || return 0

    # Modern syntax (Android 13+): mode + no downscale.
    if cmd game set --mode performance --downscale disable "$pkg" >/dev/null 2>&1; then
        log "game set (performance, no downscale): $pkg"
        return 0
    fi
    # Older syntax (Android 12): numeric mode (2 = performance).
    if cmd game mode 2 "$pkg" >/dev/null 2>&1; then
        log "game mode 2 (performance): $pkg"
        return 0
    fi
    log "game intervention unsupported for: $pkg"
}

for pkg in \
    com.epicgames.fortnite \
    com.tencent.ig \
    com.pubg.imobile \
    com.pubg.krmobile \
    com.rekoo.pubgm \
    com.activision.callofduty.shooter \
    com.garena.game.codm \
    com.dts.freefireth \
    com.dts.freefiremax \
    com.miHoYo.GenshinImpact \
    com.miHoYo.Yuanshen \
    com.HoYoverse.hkrpgoversea \
    com.miHoYo.hkrpg \
    com.riotgames.league.wildrift \
    com.mobile.legends \
    com.mojang.minecraftpe \
    com.roblox.client \
    com.gameloft.android.ANMP.GloftA9HM \
    com.ea.gp.apexlegendsmobilefps \
    com.proximabeta.mf.uamo ; do
    apply_game "$pkg"
done

# ---------------------------------------------------------------------------
# 2) Light I/O tuning on the UFS storage (lower latency, no risk)
# ---------------------------------------------------------------------------
for q in /sys/block/sd*/queue /sys/block/mmcblk0/queue; do
    [ -d "$q" ] || continue
    # Prefer a low-latency scheduler if available.
    if grep -q "none" "$q/scheduler" 2>/dev/null; then
        echo none > "$q/scheduler" 2>/dev/null
    elif grep -q "mq-deadline" "$q/scheduler" 2>/dev/null; then
        echo mq-deadline > "$q/scheduler" 2>/dev/null
    fi
    echo 256 > "$q/read_ahead_kb" 2>/dev/null
    echo 1   > "$q/iostats" 2>/dev/null
done
log "I/O tuning applied"

# ---------------------------------------------------------------------------
# 3) Light VM / memory tuning (helps multitasking + big game reloads)
# ---------------------------------------------------------------------------
# ZRAM is fast, so a higher swappiness keeps more free RAM for the foreground.
echo 100 > /proc/sys/vm/swappiness            2>/dev/null
echo 20  > /proc/sys/vm/dirty_ratio           2>/dev/null
echo 5   > /proc/sys/vm/dirty_background_ratio 2>/dev/null
echo 150 > /proc/sys/vm/vfs_cache_pressure    2>/dev/null
echo 0   > /proc/sys/vm/stat_interval         2>/dev/null
log "VM tuning applied"

# ---------------------------------------------------------------------------
# NOTE on CPU/GPU governors & thermal:
# We deliberately leave the schedutil/EAS governors and the thermal engine
# ALONE. On the Snapdragon 8s Gen 4 forcing a "performance" governor or
# disabling thermal throttling mostly adds heat and drains battery without a
# real, sustained FPS gain (and can be unsafe). The stock scheduler already
# ramps correctly for games, and GameManager "performance mode" above tells
# it when to be aggressive.
# ---------------------------------------------------------------------------

log "done"
