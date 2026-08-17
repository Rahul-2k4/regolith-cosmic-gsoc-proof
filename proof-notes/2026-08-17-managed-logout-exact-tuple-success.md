# Managed logout exact-tuple QEMU proof

Date: 2026-08-17

A fresh copy-on-write Pop!_OS COSMIC QEMU overlay reached the Regolith/COSMIC
session through the greeter. The graphical logind session was confirmed as
`Remote=no`, `Type=wayland`, `Desktop=Regolith-Wayland`, and `Seat=seat0`.

The run then executed `sudo loginctl terminate-session` against that graphical
session. The command returned `0`, the COSMIC greeter returned, and the settled
post-logout checks showed:

- `regolith-cosmic.target`, inputd, and displayd inactive/dead with successful
  results and zero restarts;
- no `cosmic-session`, Sway, inputd, or displayd process remaining;
- no failed units;
- clean `dpkg --audit`.

The tested package tuple was `cosmic-session 1.0.0-1-1regolith-resolute`,
`regolith-session-cosmic 1.2.0-1ubuntu1-1regolith-resolute`,
`regolith-inputd 0.4.1-1-1regolith-resolute`,
`regolith-displayd 0.3.4-1-1regolith-resolute`, and
`regolith-wm-config 4.11.11-1regolith-resolute`.

- [Complete lifecycle log](../artifacts/managed-logout-exact-tuple-20260817.log)
- [Post-logout greeter screenshot](../artifacts/managed-logout-exact-tuple-20260817.png)

This proves managed logout for the tested QEMU tuple. It does not prove full
host shutdown, native `cosmic-idle` semantics, hardware input, or
multi-display/hotplug behavior.
