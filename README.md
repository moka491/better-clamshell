## About

BetterClamshell tries to improve the (very limited) feature set and adjustability of Mac OS' clamshell mode,
without the need for a big program hogging your resources. It's meant to "just do it's job" without any other fuzz.

## How it works

Essentially, the script will check the following condititions in a (configurable) time interval, and react accordingly:

- If your device has no external screens attached
  - Do nothing, keep the default sleep settings of your device
- If your device has an external screen attached
  - Prevent the device from immediately sleeping when the lid is closed (clamshell mode)
  - Send your device to sleep after a configurable time of no user input

This allows you to close your Macbook while working with external screens, while still retaining favorable sleep settings.  
Unlike the builtin clamshell mode however, this also works on battery power!

## Setup

A LaunchDaemon plist file is provided. This allows the script to automatically start in the background.
To install it, open a terminal and issue the following commands:

Open the `com.moka491.BetterClamshell.plist` file and adjust the following line
to point to the script in the folder you cloned the repository to:

> \<string>/Users/moka/Workspace/better-clamshell/better-clamshell.sh\</string>

Copy it to the system's launch daemons folder:

> sudo cp com.moka491.BetterClamshell.plist /Library/LaunchDaemons/com.moka491.BetterClamshell.plist

Then either reboot or load it using:

> cd /Library/LaunchDaemons && sudo launchctl load -w com.moka491.BetterClamshell.plist

A logfile is automatically generated and can be read using

> tail -f /var/log/better-clamshell.log
