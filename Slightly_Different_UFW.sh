#!/bin/bash

CHECK_INTERVAL=60  # in seconds
STATUS_FILE="/var/www/html/ufw_status.json"
NOTIFY() {
    notify-send "UFW Firewall Monitor" "$1"
    if command -v paplay &>/dev/null; then
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
    elif command -v aplay &>/dev/null; then
        aplay /usr/share/sounds/alsa/Front_Center.wav
    else
        echo -e "\a"
    fi
}

# Setup environment for desktop notifications
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Track previous state
was_installed=false
was_enabled=false

function write_status {
    echo "{\"installed\": $1, \"enabled\": $2, \"timestamp\": \"$(date -Iseconds)\"}" > "$STATUS_FILE"
    chmod 644 "$STATUS_FILE"
}

while true; do
    is_installed=false
    is_enabled=false

    if command -v ufw &>/dev/null; then
        is_installed=true
        if ufw status | grep -q "Status: active"; then
            is_enabled=true
        fi
    fi

    # Compare to previous state and notify if there's a change
    if ! $is_installed && $was_installed; then
        NOTIFY "UFW has been removed!"
    elif $is_installed && ! $was_installed; then
        NOTIFY "UFW has been installed!"
    fi

    if $is_installed; then
        if ! $is_enabled && $was_enabled; then
            NOTIFY "UFW has been disabled!"
        elif $is_enabled && ! $was_enabled; then
            NOTIFY "UFW has been enabled!"
        fi
    fi

    write_status "$is_installed" "$is_enabled"

    was_installed=$is_installed
    was_enabled=$is_enabled

    sleep "$CHECK_INTERVAL"
done
