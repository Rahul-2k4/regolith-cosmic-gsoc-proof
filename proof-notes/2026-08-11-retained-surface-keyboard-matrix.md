# Retained surface and keyboard representative matrix - 2026-08-11

## Scope

This is representative interactive evidence from a disposable,
snapshot-backed QEMU COSMIC/Sway session. It is not hardware evidence and does
not close the complete tiling, workspace, launcher, media-key, or physical
keyboard matrix.

## Observed actions

- Sway `1.9` was running with an IPC socket.
- `i3status-rs` was running with the Regolith configuration.
- The resolved `Mod4+Space` binding launched `ilia`; the launcher process and
  visible launcher state were observed in the same session.
- `Mod4+2` moved focus from workspace 1 to workspace 2.
- `Mod4+1` returned focus to workspace 1.

The launcher image is retained in
[`2026-08-11-qemu-launcher-after.png`](assets/2026-08-11-qemu-launcher-after.png).
The earlier live-login proof records the package hashes, target state, and
before/after screenshots:
[`2026-08-11-qemu-live-login-inputd-bindsym.md`](2026-08-11-qemu-live-login-inputd-bindsym.md).

## Result

These observations strengthen criteria 8 and 12 to **Partial**. They do not
make either criterion fully met: the complete binding matrix, multimedia keys,
physical keyboard behavior, and hardware session remain unverified.

The disposable QEMU instance was powered down cleanly after the check.
