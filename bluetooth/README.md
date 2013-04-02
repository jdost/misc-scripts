# Bluetooth scripts

Included are various scripts I use to connect and setup bluetooth devices

## `bt_headset.sh`

This turns on PulseAudio support for a bluetooth headset and turns on the bluetooth
module for the kernel (out of date, should use `systemctl` now).

## `bt_mouse.sh`

This is a helper function to connect a bluetooth mouse, mostly makes the flag based
calls to turn on/off more manageable and a better alias.
