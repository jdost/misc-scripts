# Scripts for my MBA (Laurie)

Requirements:
- dzen2 (can be disabled, just comment out the `draw_dzen` function call)

## `mon_brightness`

A script used to change the monitor brightness (I have it tied to the
function keys via my WM), usage: `./mon_brightness` takes an argument, options are:

- `on` will turn the monitor to 50% brightness
- `off` will turn monitor off
- `down` will turn the brightness down by 1/$NUM_STEPS (as set in script)
- `up` will turn the brightness up by 1/$NUM_STEPS (as set in script)
- [number] will push the passed in value to the brightness (within range set in 
   script)

Also included is a function that will create a dzen instance to display the update
to the brightness

## `kbd_brightness`

A near copy of the above `mon_brightness` script, just some change variables for
the actions to target the keyboard backlight.
