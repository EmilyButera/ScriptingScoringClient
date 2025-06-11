#!/bin/bash

import subprocess
import json
import time
from datetime import datetime

# Configuration
USERNAME_TO_MONITOR="bob"
STATUS_FILE = "/usr/local/bin/user_status.json"
CHECK_INTERVAL=5  # seconds

# Track previous state
user_existed=true

# Set up environment for GUI notifications
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

function alert_user_deleted {
    notify-send "User Deleted" "The user '$USERNAME_TO_MONITOR' has been removed from the system."

    # Play a sound
    if command -v paplay &> /dev/null; then
        paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
    elif command -v aplay &> /dev/null; then
        aplay /usr/share/sounds/alsa/Front_Center.wav
    else
        echo -e "\a"
    fi
}

# Get current timestamp in ISO format
LAST_CHECKED=$(date --iso-8601=seconds)

# Create JSON and write to file using jq


while true; do
    if id "$USERNAME_TO_MONITOR" &>/dev/null; then
        # User exists now
        if ! $user_existed; then
            echo "[INFO] User '$USERNAME_TO_MONITOR' recreated at $(date)"
        fi
        user_existed=true
    else
        # User does not exist now
        if $user_existed; then
            echo "[ALERT] User '$USERNAME_TO_MONITOR' deleted at $(date)"
            alert_user_deleted
            jq -n --arg status "$user_existed" --arg time "$LAST_CHECKED" \
              '{User status: $user_existed, last_checked: $time}' > "$STATUS_FILE"
        fi
        user_existed=false
    fi

    sleep "$CHECK_INTERVAL"
done
