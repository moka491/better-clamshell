#!/bin/bash

# Sleep after this amount of time in seconds
SLEEP_AFTER=5

# Check every n seconds to update sleep settings
CHECK_DURATION=10


sleep_disabled=0

function get_idle_time {
    echo "$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')"
}

function get_display_count {
    echo "$(system_profiler SPDisplaysDataType -xml | sed -n '/spdisplays_ndrvs/,/<\/array>/p' | grep "_name" | wc -l)"
}

function disable_sleep {
    [[ sleep_disabled -ne 0 ]] && return

    pmset_sleep="$(pmset -g | awk '$1 ~ /^sleep/ {print $2}')"
    pmset_hibernatemode="$(pmset -g | awk '/hibernatemode/ {print $2}')"

    sudo pmset -a sleep 0 hibernatemode 0 disablesleep 1

    sleep_disabled=1
    echo "[clamshell] sleep disabled"
}

function enable_sleep {
    [[ sleep_disabled -ne 1 ]] && return

    sudo pmset -a sleep $pmset_sleep hibernatemode $pmset_hibernatemode disablesleep 0

    sleep_disabled=0
    echo "[clamshell] sleep enabled"
}

function on_exit {
    echo
    echo "Exiting and reverting to defaults.."
    enable_sleep
}
trap on_exit EXIT

while [ 1 ]
do
    idle_time="$(get_idle_time)"
    display_count="$(get_display_count)"

    if [[ display_count -ge 1 && idle_time -lt SLEEP_AFTER ]]
    then
        disable_sleep
    else
        enable_sleep
    fi

    sleep $CHECK_DURATION
done
