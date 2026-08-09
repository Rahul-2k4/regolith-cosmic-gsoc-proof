# Managed Regolith/COSMIC logout QEMU proof

The baseline QEMU session was terminated through the display-manager boundary
with `sudo loginctl terminate-session`. The guest returned to the active
`cosmic-greeter.service`; `regolith-cosmic.target`, inputd, and displayd were
inactive, and exact process checks found no `cosmic-session`, `sway`, inputd,
or displayd process. The session list contained the greeter seat and the SSH
inspection session only.

[Post-logout greeter screenshot](../artifacts/managed-logout-qemu-20260810.png)

This proves managed display-manager logout in QEMU. It does not claim that
`swaymsg exit` terminates the `cosmic-session`/`dbus-run-session` parent
boundary; that remains documented separately.
