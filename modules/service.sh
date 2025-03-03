#!/system/bin/sh

ROOT_METHOD="Unknown"
ROOT_VERSION="Unknown"

if [ -d "/data/adb/ksu" ]; then
    ROOT_METHOD="KernelSU"
    if command -v su &>/dev/null; then
        ROOT_VERSION=$(su --version 2>/dev/null | cut -d ':' -f 1)
    fi
elif [ -d "/data/adb/magisk" ]; then
    ROOT_METHOD="Magisk"
    if command -v magisk &>/dev/null; then
        ROOT_VERSION=$(magisk -V)
    fi
elif [ -d "/data/adb/ap" ]; then
    ROOT_METHOD="APatch"
    if [ -f "/data/adb/ap/version" ]; then
        ROOT_VERSION=$(cat /data/adb/ap/version)
    fi
fi

MODDIR="/data/adb/modules/thermvx"
MODULE_PROP="${MODDIR}/module.prop"
BACKUP_PROP="${MODULE_PROP}.orig"

if [ -f "$MODULE_PROP" ] && [ ! -f "$BACKUP_PROP" ]; then
    cp "$MODULE_PROP" "$BACKUP_PROP"
fi

if [ -f "$MODULE_PROP" ]; then
    sed -i "s/^description=.*/description=[ 🔥 Thermal Is Dead | ✅ ${ROOT_METHOD} (${ROOT_VERSION}) ] Eliminates thermal limitations for unrestricted usage !/" "$MODULE_PROP"
fi
