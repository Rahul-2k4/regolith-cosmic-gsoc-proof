# QEMU live login, exact inputd package, and bindsym proof

Date: 2026-08-11

## Scope

This is disposable Pop!_OS QEMU evidence. The VM was launched in snapshot
mode with an HMP monitor and was shut down cleanly. It is not hardware proof,
native `cosmic-comp` proof, reboot-persistence proof, or a full keyboard
matrix.

## Live login

- The greeter accepted the existing test account credential.
- Before/after screenshots show the greeter changing to a live desktop with
  the Regolith bar:
  - [greeter](assets/2026-08-11-qemu-greeter-before.png)
  - [desktop and launcher](assets/2026-08-11-qemu-launcher-after.png)
- The active user session was Wayland on `seat0`.
- `cosmic-session` and Sway were running; the Sway IPC socket existed.
- Sway reported version `1.9` and loaded `/etc/regolith/sway/config`.
- `regolith-cosmic.target` was active and `regolith-gnome.target` was
  inactive.
- `regolith-init-inputd.service` and `regolith-init-displayd.service` were
  active.

## Exact inputd package check

The exact package from the earlier Voulage proof was copied into the live
snapshot and installed. No persistent disk state was changed.

- Source: [`regolith-inputd` `66099f67`](https://github.com/Rahul-2k4/regolith-inputd/commit/66099f67a5498f3ad10fe65ef69eb6e8b57ac0c2)
- Voulage model: [`05dfd700`](https://github.com/Rahul-2k4/voulage/commit/05dfd7004c6941f6609a52fc4347ecdd5fa67a72)
- Package version: `0.4.1-2-1regolith-resolute`
- Package SHA-256: `7c264412bfc3f83c29ddecae35220189aef6e4244e56c6786b1e5c82089910e8`
- Installed `/usr/bin/regolith-inputd` SHA-256:
  `60ff114ced2c42c78be8909bab85fe95686393f89e01bdec67e3718c41f3e7fc`
- `dpkg -i` exit: `0`
- User-service restart exit: `0`
- `dpkg --audit`: empty

The exact inputd service remained active after installation and restart. This
proves package installation plus service presence in a live QEMU session; it
does not prove physical input devices or every handler's live behavior.

## One keyboard binding

The live Sway configuration resolved the launcher binding to `Mod4+Space`.
The baseline had no `ilia` process. One HMP `sendkey meta_l-spc` action then
produced an `ilia` process and the visible launcher menu in the after image.

This is direct interactive proof for one launcher binding. It is not enough to
mark the proposal's complete keyboard-first criterion as fully met because the
workspace, tiling, lock-state, and remaining launcher bindings were not all
exercised.

## Result

- Criterion 8: **Partial** evidence strengthened; ilia is now observable in a
  live QEMU Sway session.
- Criterion 12: **Partial** evidence strengthened; one resolved launcher
  `bindsym` was triggered and observed.
- Headline remains **4 of 12 fully met** and **62-68%** strict completion.
- The VM was powered down through HMP; no QEMU process or monitor socket
  remained.
