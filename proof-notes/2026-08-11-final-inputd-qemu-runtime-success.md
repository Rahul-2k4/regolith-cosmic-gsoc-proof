# Final inputd QEMU graphical-login proof

Date: 2026-08-11

A fresh copy-on-write overlay from the qualification image installed the staged
Resolute session tuple, rebooted, and created a real `rahul` session through
greetd IPC. `/usr/bin/regolith-session-cosmic-launch` started `cosmic-session`,
Sway, and `regolith-inputd`.

Observed:

- `XDG_SESSION_TYPE=wayland`
- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`
- live `WAYLAND_DISPLAY=wayland-1` and `SWAYSOCK`
- `regolith-cosmic.target`: active
- `regolith-init-inputd.service`: active
- `regolith-init-displayd.service`: active
- `regolith-gnome.target`: inactive
- `dpkg --audit`: empty

The installed versions were `regolith-inputd 0.4.1-2-1regolith-resolute`,
`regolith-displayd 0.3.4-1regolith-resolute`, the session packages at
`1.2.0-1regolith-resolute`, and `regolith-wm-config
4.11.11-1regolith-resolute`.

The overlay and all temporary QEMU artifacts were removed. This is QEMU-only
package/session proof; it does not prove hardware, native display persistence,
signing/publication, or an upstream merge. The displayd process name was not
independently matched because Linux `pgrep` limits names longer than 15
characters; its target-owned systemd unit was active.

