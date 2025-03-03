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

while [ -z "$(resetprop sys.boot_completed)" ]; do
    sleep 5
done

exec 1>/dev/null 2>/dev/null

stop_services() { 
    for _ in 1 2; do 
        for prop in $(getprop | awk -F'[][]' '/logd|thermal/ && !/hal/ {print $2}'); do 
            status=$(getprop "$prop") 
            if [ "$status" = "running" ] || [ "$status" = "restarting" ]; then 
                setprop "ctl.stop" "${prop#init.svc.}" 
                stop "${prop#init.svc.}" 
                sleep 1 
            fi 
        done 
        sleep 5 
    done 
}

stop_services

for zone in /sys/class/thermal/thermal_zone*; do
    [ -w "$zone/mode" ] && echo "disabled" > "$zone/mode" 2>/dev/null
    [ -w "$zone/policy" ] && echo "step_wise" > "$zone/policy" 2>/dev/null
done

if command -v resetprop >/dev/null 2>&1; then
    for prop in $(resetprop | grep 'thermal.*running' | awk -F '[][]' '{print $2}'); do
        resetprop "$prop" freezed >/dev/null 2>&1
    done
fi

for prop in dalvik.vm.dexopt.thermal-cutoff sys.thermal.enable ro.thermal_warmreset; do
    case "$prop" in
        dalvik.vm.dexopt.thermal-cutoff) resetprop "$prop" 0 >/dev/null 2>&1 ;;
        sys.thermal.enable|ro.thermal_warmreset) resetprop "$prop" false >/dev/null 2>&1 ;;
    esac
done

find /sys/ -type f -name "*throttling*" | while IFS= read -r throttling; do
    [ -w "$throttling" ] && echo 0 > "$throttling" 2>/dev/null
done

find /sys/ -name enabled | grep 'msm_thermal' | while IFS= read -r msm_thermal_status; do
    if [ -r "$msm_thermal_status" ]; then
        msm_thermal_value=$(cat "$msm_thermal_status")
        case "$msm_thermal_value" in
            Y) echo 'N' > "$msm_thermal_status" 2>/dev/null ;;
            1) echo '0' > "$msm_thermal_status" 2>/dev/null ;;
        esac
    fi
done

if [ -f /proc/driver/thermal/tzcpu ]; then
	t_limit="125"
	no_cooler="0 0 no-cooler"
	
	for tz in tzcpu tzpmic tzbattery tzpa tzcharger tzwmt tzbts tzbtsnrpa tzbtspa; do
		[ -f "/proc/driver/thermal/$tz" ] && echo "1 ${t_limit}000 0 mtktscpu-sysrst $no_cooler 200" > "/proc/driver/thermal/$tz"
	done
fi

if [ -f /sys/devices/virtual/thermal/thermal_message/cpu_limits ]; then
	for i in 0 2 4 6 7; do
		maxfreq=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq 2>/dev/null)
		[ -n "$maxfreq" ] && [ "$maxfreq" -gt 0 ] && echo "cpu$i $maxfreq" > /sys/devices/virtual/thermal/thermal_message/cpu_limits
	done
fi

if [ -d /proc/ppm ]; then
	while read -r idx; do
		echo "$idx 0" > /proc/ppm/policy_status
	done < <(awk -F'[][]' '/PWR_THRO|THERMAL/ {print $2}' /proc/ppm/policy_status)
fi

if [ -f "/proc/gpufreq/gpufreq_power_limited" ]; then
	echo "ignore_batt_oc 1" > /proc/gpufreq/gpufreq_power_limited
	echo "ignore_batt_percent 1" >> /proc/gpufreq/gpufreq_power_limited
	echo "ignore_low_batt 1" >> /proc/gpufreq/gpufreq_power_limited
	echo "ignore_thermal_protect 1" >> /proc/gpufreq/gpufreq_power_limited
	echo "ignore_pbm_limited 1" >> /proc/gpufreq/gpufreq_power_limited
fi

for svc in logd thermal thermal-engine mi_thermald; do
    if getprop init.svc.$svc | grep -q "running"; then
        su -c "stop $svc"
    fi
done
