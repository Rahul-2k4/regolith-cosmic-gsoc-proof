# Combined input/display persistence proof - 2026-08-17

Status: Pop!_OS 24.04/QEMU; single virtual output; criterion 7 remains partial.

## Exact inputs

- `regolith-inputd` source: [`c658754e`](https://github.com/Rahul-2k4/regolith-inputd/commit/c658754ec10ac75422cba8e1c3517bba6075795f)
- `regolith-inputd` package SHA-256: `52dfaba9617f046100ae0b32392662254e5411cc8d3c7c1265c57358e1901d34`
- Installed binary SHA-256: `955bc3838fda47d69d14cd132cba64960b35a52323e88d201d986fbc75be6315`
- `cosmolith` package SHA-256: `3b40b171bb36f8e10d8279536e8f3647a6b5e0be3b82b0bd85af69d9a0ebfc40`

## Result

In one disposable overlay, the pre-reboot state was set to French/AZERTY,
repeat `540/31`, and `Virtual-1` at `1024x768`. After a second cold reboot and
greetd login, Sway reported French/AZERTY and `Virtual-1` at 1024x768. Repeat
delay/rate returned to `600/25`, so repeat persistence is not claimed.

The COSMIC target and inputd/displayd helpers were active, the GNOME target was
inactive, `dpkg --audit` was empty, and the user failed-unit listing was empty.

## Boundary

This is stronger single-output QEMU evidence for criterion 7, not full closure.
The remaining implementation gap is persistence of keyboard repeat delay/rate.
Hardware, multi-display/hotplug, mixed DPI, native `cosmic-comp`, Settings GUI,
Ubuntu Resolute graphical validation, and release acceptance remain open.
