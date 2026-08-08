# Current tuple acceptance - 2026-08-09

The frozen Regolith package tuple was installed in disposable QEMU and checked
after the session was running:

- `regolith-displayd 0.3.4-1-1regolith-resolute`
- `regolith-inputd 0.4.1-1-1regolith-resolute`
- `regolith-session-cosmic 1.2.0-1ubuntu1-1regolith-resolute`
- `regolith-wm-config 4.11.11-1regolith-resolute`

The guest reported an empty `dpkg --audit`, an active COSMIC target, both
project helpers with `Result=success` and `NRestarts=0`, and no failed user
units. The running `regolith-inputd` process carried the live Sway socket,
Wayland display, and `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`.

The capture contains Sway output/input/workspace state, package state, process
state, and a SHA-256 manifest. It is a QEMU health snapshot, not a hardware,
native-compositor, Settings-panel, signing, or release-readiness claim.
