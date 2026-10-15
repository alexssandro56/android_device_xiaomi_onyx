[vendor/modem_firmware/image/*]
mode: 0771
user: AID_SYSTEM
group: AID_SYSTEM
caps: 0

[vendor/bin/hw/android.hardware.security.keymint3-service.strongbox.nxp]
mode: 0755
user: AID_VENDOR_NXP_STRONGBOX
group: AID_SYSTEM
caps: SYS_ADMIN SYS_NICE WAKE_ALARM

[vendor/bin/hw/android.hardware.authsecret-service.nxp]
mode: 0755
user: AID_VENDOR_NXP_AUTHSECRET
group: AID_SYSTEM
caps: SYS_ADMIN SYS_NICE WAKE_ALARM