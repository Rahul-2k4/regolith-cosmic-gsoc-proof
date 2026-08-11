# QEMU display observer and restore proof - 2026-08-12

## Scope

The existing display proof harness ran in a fresh copy-on-write Pop!_OS COSMIC
guest after graphical login. It changed the single virtual output through
`cosmic-randr`, observed a Sway output event, and restored the original mode.

## Observed transition

```text
before:  Virtual-1 1280x800 @ 74.994 Hz
test:    Virtual-1 1024x768 @ 60.004 Hz
restore: Virtual-1 1280x800 @ 74.994 Hz
event:   { "change": "unspecified" }
```

The packet also records the before/test/restore `swaymsg -t get_outputs` JSON,
`cosmic-randr list` output, Sway environment, and empty failed-unit files.
`regolith-init-kanshi.service` was inactive in this COSMIC target-owned path;
this run does not claim Kanshi applied the change.

## Boundary

This proves one-output QEMU mutation, Wayland/Sway event observation, and
restore behavior. It does not prove physical hotplug, mixed DPI, multiple real
displays, reboot persistence, or native `cosmic-comp` behavior.
