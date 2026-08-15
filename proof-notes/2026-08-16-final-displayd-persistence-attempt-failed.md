# Final displayd persistence attempt: current package boundary

Date: 2026-08-16
Environment: disposable Pop/COSMIC QEMU overlay
Scope: one virtual output, Sway-backed COSMIC session

## Package under test

- `regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb`
- SHA-256: `ae5249b164cae2c65499b7b38b31bdea050bfe28f7ab753e0233e9a4dde1d3ad`

## Reproduction

The session started with `Virtual-1` at `1280x800@74.994Hz`. This command
was accepted by Sway:

```text
swaymsg -s /run/user/1000/sway-ipc.1000.1486.sock output Virtual-1 mode 1024x768@60.004Hz
```

The live output and human-readable profile changed to `1024x768@60.004Hz`.
After a QEMU `system_reset` and fresh graphical login, the output and profile
were back at `1280x800@74.994Hz`.

The COSMIC target, displayd, and inputd services were active after reboot;
Kanshi was inactive under the current COSMIC target contract.

## Boundary

This is a **failed current-package persistence attempt**, not a persistence
claim. Criterion 7 remains `Partial`. The earlier patched persistence proof
is scoped to its exact session+Kanshi package tuple and is not interchangeable
with this current displayd-only run.

The disposable overlay and monitor artifacts were removed, and the protected
base image was preserved.
