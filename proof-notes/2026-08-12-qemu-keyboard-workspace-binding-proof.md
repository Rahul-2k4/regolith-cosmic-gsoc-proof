# QEMU keyboard workspace binding proof

Date: 2026-08-12

During a fresh disposable QEMU graphical-login run, HMP key injection reached
the live COSMIC-backed Sway session through its active Sway IPC socket.

```text
initial workspace: 1
sendkey meta_l-2 -> active workspace: 2
sendkey meta_l-1 -> active workspace: 1
```

The active displayd systemd unit also reported `MainPID=1860`,
`ActiveState=active`, and `SubState=running`.

This is QEMU proof for two representative workspace bindings only. It does
not prove the full keyboard matrix, multimedia keys, physical keyboard
behavior, or launcher behavior. A separate `meta_l-space` attempt was
rejected by QEMU's key parser and is not claimed as successful input.

