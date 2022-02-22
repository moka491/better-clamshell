#!/bin/bash

# Sleep after this amount of time in seconds
SLEEP_AFTER=120

# Check every n seconds to update sleep settings
CHECK_DURATION=10

function get_idle_time {
    echo "$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')"
}

function get_display_count {
    echo "$(system_profiler SPDisplaysDataType -xml | sed -n '/spdisplays_ndrvs/,/<\/array>/p' | grep "_name" | wc -l | xargs)"
}

# function is_lid_closed {
#     echo "$(ioreg -r -k AppleClamshellState -d 1 | grep AppleClamshellState  | head -1 | grep "Yes" | wc -l)"
# }

function disable_sleep {
    [[ sleep_disabled_state -ne 0 ]] && return

    log "preventing device sleep.."
    sudo pmset -a disablesleep 1
    sleep_disabled_state=1
}

function enable_sleep {
    [[ sleep_disabled_state -ne 1 ]] && return

    log "allowing device sleep.."
    sudo pmset -a disablesleep 0
    sleep_disabled_state=0
}

function sleep_now {
    log "going to sleep.."
    enable_sleep
    pmset sleepnow > /dev/null
}

trap on_exit EXIT
function on_exit {
    echo
    log "exiting.. reverting to defaults"
    enable_sleep
}

function log {
    echo "[clamshell] [$(date '+%H:%M:%S')] $1"
}


log "starting daemon.."
log "will check for changes every $CHECK_DURATION seconds and sleep after $SLEEP_AFTER seconds when external screens are connected"
while [ 1 ]
do
    display_count="$(get_display_count)"
    idle_time="$(get_idle_time)"

    log "performing check.. $display_count displays enabled, system idle time $idle_time seconds"

    if [[ display_count -le 1 ]]
    then
        enable_sleep
    else
        disable_sleep

        if [[ idle_time -gt SLEEP_AFTER ]]
        then
            sleep_now
        fi
    fi

    sleep $CHECK_DURATION
done
