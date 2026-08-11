# Target-owned helper lifecycle QEMU runtime boundary

This run installed the reviewed target-owned inputd/displayd packages in a
disposable QEMU overlay, rebooted the guest, and started the COSMIC-backed
Regolith session through greetd.

## Proven

- `dpkg -i` completed with `INSTALL_RC=0`.
- `regolith-inputd 0.4.1-2-1regolith-resolute` and
  `regolith-displayd 0.3.4-1-1regolith-resolute` were installed.
- Reboot completed and greetd returned `START_REPLY success`.
- `cosmic-session` and Sway ran with
  `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`.
- `regolith-cosmic.target` was active and listed both helper services in its
  `Wants=` dependency graph.
- `dpkg --audit` was empty.
- After `swaymsg exit`, both Sway and its `cosmic-session` parent stopped.

## Not proven

Both target-owned helper services were `inactive (dead)` at capture time. The
journal shows each was started and then stopped almost immediately with
`ExecMainStatus=15` (SIGTERM). The target stayed active, so the remaining issue
is lifecycle stop ordering or cleanup, not missing `Wants=` metadata.

The strict proposal status remains **62-68%**, with **4 of 12** criteria fully
met. This run strengthens package and graphical-login evidence but does not
close the target-owned helper lifecycle gate.

See the [reviewer-facing work product](../WORK_PRODUCT.md) for the complete
criteria table.
