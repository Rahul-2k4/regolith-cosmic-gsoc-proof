# Historical target-owned helper lifecycle QEMU runtime boundary

> Superseded by [lifecycle v2](2026-08-11-target-owned-helper-lifecycle-qemu-runtime-v2.md).
> The v2 run is authoritative for the parent-session result.

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
- After `swaymsg exit`, Sway stopped, but the `cosmic-session` parent remained.

## Not proven

Both target-owned helper services were `inactive (dead)` at capture time. The
journal shows each was started and then stopped almost immediately with
`ExecMainStatus=15` (SIGTERM). The target stayed active. This historical run
does not establish healthy helper startup or clean parent teardown; use the v2
proof for the current target-owned helper result.

The strict proposal status remains **62-68%**, with **4 of 12** criteria fully
met. This run strengthens package and graphical-login evidence but does not
close the target-owned helper lifecycle gate.

See the [reviewer-facing work product](../WORK_PRODUCT.md) for the complete
criteria table.
