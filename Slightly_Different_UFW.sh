#!/bin/bash

CHECK_INTERVAL=60
STATUS_FILE="/var/www/html/ufw_status.json"
ufw_installed=true
ufw_enabled=true

function write_status {
    echo "{\"installed\": $1, \"enabled\": $2, \"timestamp\": \"$(date -Iseconds)\"}" > "$STATUS_FILE"
    chmod 644 "$STATUS_FILE"
}

while true; do
    INSTALLED=false
    ENABLED=false

    if command -v ufw &>/dev/null; then
        INSTALLED=true
        if ufw status | grep -q "Status: active"; then
            ENABLED=true
        fi
    fi

    write_status "$INSTALLED" "$ENABLED"
    sleep "$CHECK_INTERVAL"
done
