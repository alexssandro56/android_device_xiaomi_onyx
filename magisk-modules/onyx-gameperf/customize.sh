#!/system/bin/sh
# customize.sh - install-time, on Magisk / KernelSU / APatch.
# Merged module: perf/game/language tweaks + bundled Adreno V842.52 GPU driver.

ui_print " "
ui_print "  POCO F7 (onyx) — Game/Perf + Adreno V842.52 GPU Driver"
ui_print "  (merge auditável; driver instalado via overlay padrao)"
ui_print " "

# --------------------------------------------------------------------------
# 1) Compatibility GATE for the GPU driver (transparent, abort if unsafe).
#    The driver libs are Adreno-only. Installing them on a non-Adreno GPU
#    would cause a black screen, so we hard-abort there.
# --------------------------------------------------------------------------
EGL="$(getprop ro.hardware.egl)"
DEV="$(getprop ro.product.device)$(getprop ro.product.vendor.device)"
PLAT="$(getprop ro.board.platform)"

ui_print "- GPU/EGL detectado: ${EGL:-desconhecido}  | SoC: ${PLAT:-?}"

if [ "$EGL" != "adreno" ]; then
    ui_print "!!"
    ui_print "!! GPU nao-Adreno detectada (ro.hardware.egl='${EGL}')."
    ui_print "!! O driver Adreno V842.52 causaria TELA PRETA aqui."
    ui_print "!! Instalacao ABORTADA por seguranca."
    abort     "!! -> Use outra ROM/driver compativel."
fi

case "$DEV" in
    *onyx*) ui_print "- Device OK: onyx (POCO F7)" ;;
    *)
        ui_print "!! AVISO: aparelho nao e 'onyx' (detectado: ${DEV:-?})."
        ui_print "!! O driver e para Adreno 8xx (POCO F7). Em outra GPU Adreno"
        ui_print "!! pode nao funcionar. Se a tela ficar preta, reinicie em"
        ui_print "!! Safe Mode (Vol-) ou remova o modulo pelo recovery."
        ;;
esac

# --------------------------------------------------------------------------
# 2) Install files. Magisk auto-copies the system/ overlay (the GPU libs
#    and vulkan permission XMLs). We just set permissions.
# --------------------------------------------------------------------------
ui_print "- Instalando driver V842.52 (libs vendor) + tweaks"
set_perm_recursive "$MODPATH"              0 0 0755 0644
set_perm_recursive "$MODPATH/scripts"      0 0 0755 0755
set_perm_recursive "$MODPATH/system"       0 0 0755 0644
# EGL/Vulkan .so files need 0644; already set by recursive above.
set_perm "$MODPATH/service.sh"      0 0 0755
set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
set_perm "$MODPATH/action.sh"       0 0 0755

# --------------------------------------------------------------------------
# 3) Clear shader / GPU caches so the new driver rebuilds them cleanly.
# --------------------------------------------------------------------------
ui_print "- Limpando cache de shader/GPU (evita glitches com driver novo)"
sh "$MODPATH/scripts/clean-shader.sh" >/dev/null 2>&1

ui_print " "
ui_print "  Pronto. REINICIE para aplicar."
ui_print " "
ui_print "  * Interface: KernelSU/APatch/MMRL -> 'Open WebUI'."
ui_print "    No Magisk use o botao 'Action'."
ui_print "  * Fortnite nitido: no jogo troque Anti-Aliasing de"
ui_print "    'Qualcomm GSR' para 'TAA'/'High' e 3D Resolution 100%."
ui_print "  * Se a tela ficar preta no boot: segure Vol- para Safe Mode"
ui_print "    (desativa modulos) e remova este modulo."
ui_print " "
