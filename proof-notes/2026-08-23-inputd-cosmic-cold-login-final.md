# 2026-08-23 exact-package COSMIC cold-login proof

This is a fresh reboot proof for the exact local Resolute tuple in a disposable
QEMU overlay. The compositor uses `WLR_BACKENDS=headless` and pixman because
the VM has no supported native COSMIC GPU path. It is QEMU-only session/IPC
proof, not hardware or native graphical proof.

Installed tuple:

- `regolith-inputd` 0.4.1-2 from `e8fce66`, 55 GNOME+COSMIC tests, SHA-256
  `650bd6f38bf67a08e140fa566aff4e7c63b2a41fc2cc60b04aada670a420823b`
- `regolith-session-common` 1.2.0-1ubuntu1-2-1regolith-resolute
- `regolith-session-cosmic` 1.2.0-1ubuntu1-1regolith-resolute
- `regolith-session-gnome-targets` 1.2.0-1ubuntu1-1-1regolith-resolute
- `regolith-session-sway` 1.2.0-1ubuntu1-1-1regolith-resolute

After `sudo reboot`, uptime was zero minutes and greetd recreated the session.
Sway, `regolith-inputd`, and `regolith-displayd` remained alive. Both
`cosmic-session.target` and `regolith-cosmic.target` were active, the Sway IPC
socket was present, and `swaymsg -t get_outputs` returned active `HEADLESS-1`
at 1280x720. `systemctl --user --failed --no-legend` and `dpkg --audit`
returned no rows. The init units for inputd and displayd started successfully.

The guest needed a temporary no-op `regolith-init-powerd.service` because the
legacy unit was absent from the local pool; this was a disposable harness stub,
not a source change.

This revalidates criteria 1 and 2 for the exact package tuple. The strict
proposal ledger remains **5/12, QEMU-only**: no native-GPU, hardware,
multi-display, Settings GUI, lock/unlock, or publication claim is made.
