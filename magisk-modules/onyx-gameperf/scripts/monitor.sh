#!/system/bin/sh
# ===========================================================================
# monitor.sh - prints a live, read-only system snapshot as JSON for the WebUI.
# Safe: reads sysfs only, writes nothing.
# ===========================================================================
DIR=${0%/*}
. "$DIR/common.sh" 2>/dev/null

jesc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
rd() { cat "$1" 2>/dev/null; }

model="$(getprop ro.product.marketname)"; [ -z "$model" ] && model="$(getprop ro.product.model)"
kernel="$(uname -r)"

batt="$(rd /sys/class/power_supply/battery/capacity)"
bt="$(rd /sys/class/power_supply/battery/temp)"      # deci-Celsius
if [ -n "$bt" ]; then batttemp="$(awk "BEGIN{printf \"%.1f\", $bt/10}")"; else batttemp=""; fi

# hottest thermal zone (values are milli-Celsius)
soc="$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | \
       awk 'BEGIN{m=-1}{if($1+0>m)m=$1+0}END{if(m>0)printf "%.1f", m/1000}')"

gov="$(rd /sys/devices/system/cpu/cpufreq/policy0/scaling_governor)"
cpu=""
for p in /sys/devices/system/cpu/cpufreq/policy*; do
    f="$(rd "$p/scaling_cur_freq")"
    [ -n "$f" ] && cpu="$cpu $((f/1000))"
done
cpu="$(echo $cpu | sed 's/ / \/ /g')"   # e.g. "480 / 940 / 1420"

gpu="$(rd /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq)"
[ -n "$gpu" ] && gpu="$(awk "BEGIN{printf \"%d\", $gpu/1000000}")"   # Hz -> MHz
gpugov="$(rd /sys/class/kgsl/kgsl-3d0/devfreq/governor)"

ramtot="$(awk '/MemTotal/{printf "%.1f",$2/1048576}' /proc/meminfo 2>/dev/null)"
ramav="$(awk '/MemAvailable/{printf "%.1f",$2/1048576}' /proc/meminfo 2>/dev/null)"

sconfig="$(rd /sys/class/thermal/thermal_message/sconfig)"
psave="$(rd /sys/class/thermal/power_save/powersave_mode)"
minhz="$(settings get system min_refresh_rate 2>/dev/null)"
peakhz="$(settings get system peak_refresh_rate 2>/dev/null)"

printf '{"model":"%s","kernel":"%s","batt":"%s","batttemp":"%s","soctemp":"%s","gov":"%s","cpu":"%s","gpu":"%s","gpugov":"%s","ramav":"%s","ramtot":"%s","sconfig":"%s","psave":"%s","minhz":"%s","peakhz":"%s"}\n' \
    "$(jesc "$model")" "$(jesc "$kernel")" "$batt" "$batttemp" "$soc" \
    "$(jesc "$gov")" "$(jesc "$cpu")" "$gpu" "$(jesc "$gpugov")" \
    "$ramav" "$ramtot" "$(jesc "$sconfig")" "$psave" "$minhz" "$peakhz"
