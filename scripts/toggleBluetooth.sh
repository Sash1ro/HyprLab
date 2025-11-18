#!/bin/bash

# Get current Bluetooth state (0 = unblocked, 1 = blocked)
state=$(rfkill list bluetooth | grep "Soft blocked" | awk '{print $3}')

if [[ "$1" == "status" ]]; then
    if [[ "$state" == "no" ]]; then
        echo "true"
    else
        echo "false"
    fi
    exit 0
fi

if [ "$state" = "no" ]; then
    rfkill block bluetooth   # turn off
else
    rfkill unblock bluetooth # turn on
fi
