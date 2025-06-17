#!/bin/bash

CHECK_INTERVAL=3  # seconds
ufw_installed=true
ufw_enabled=true

# Set up environment for GUI notifications
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

function alert_issue {
    local message="$1"

    notify-send "UFW Firewall Alert" "$message"

    if command -v paplay &> /dev/null; then
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
    elif command -v aplay &> /dev/null; then
        aplay /usr/share/sounds/alsa/Front_Center.wav
    else
        echo -e "\a"
    fi
}

while true; do
    if ! command -v ufw &>/dev/null; then
        if $ufw_installed; then
            alert_issue "UFW is NOT installed!"
            ufw_installed=false
        fi
    else
        if ! $ufw_installed; then
            echo "[INFO] UFW was installed again at $(date)"
        fi
        ufw_installed=true

        if ! ufw status | grep -q "Status: active"; then
            if $ufw_enabled; then
                alert_issue "UFW is installed but NOT enabled!"
                ufw_enabled=false
            fi
        else
            if ! $ufw_enabled; then
                echo "[INFO] UFW was re-enabled at $(date)"
            fi
            ufw_enabled=true
        fi
    fi

    sleep "$CHECK_INTERVAL"
done
