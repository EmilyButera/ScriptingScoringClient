#!/bin/bash

# Configuration
USERNAME_TO_MONITOR="targetuser"
CHECK_INTERVAL=60  # seconds

# Function to send popup notification and sound alert
function alert_user_deleted {
    DISPLAY=:0
    export DISPLAY
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"

    notify-send "User Deleted" "The user '$USERNAME_TO_MONITOR' has been removed from the system."
    
    # Try to play a sound (if available)
    if command -v paplay &> /dev/null; then
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
    elif command -v aplay &> /dev/null; then
        aplay /usr/share/sounds/alsa/Front_Center.wav
    else
        echo -e "\a"  # fallback: system beep
    fi
}

# Monitoring loop
while true; do
    if ! id "$USERNAME_TO_MONITOR" &>/dev/null; then
        alert_user_deleted
        break
    fi
    sleep "$CHECK_INTERVAL"
done
