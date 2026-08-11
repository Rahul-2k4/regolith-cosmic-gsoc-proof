# QEMU launcher and workspace binding proof

Date: 2026-08-12

A fresh disposable QEMU COSMIC-backed Sway session accepted these HMP key
bindings:

```text
sendkey meta_l-spc -> ilia PID 2442
sendkey meta_l-2  -> active workspace 2
sendkey meta_l-1  -> active workspace 1
```

The COSMIC target and both target-owned helper units were active, the GNOME
target was inactive, Wayland/Sway IPC were live, and `dpkg --audit` was empty.
The displayd unit reported `MainPID=1852`, `ActiveState=active`, and
`SubState=running`.

This is representative QEMU evidence, not a complete keyboard/media-key or
hardware matrix.

