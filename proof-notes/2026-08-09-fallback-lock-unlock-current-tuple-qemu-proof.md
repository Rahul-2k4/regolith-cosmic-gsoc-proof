# Current tuple fallback lock/unlock QEMU proof - 2026-08-09

## Scope

This note records one fallback lock/unlock cycle in the current-tuple,
Sway-backed Regolith Wayland COSMIC session running in QEMU. It is QEMU-only
proof; it is not hardware or native COSMIC idle proof.

## Observed result

- The target-owned `swayidle -w timeout 300 gtklock` path produced a visible
  lock screen after the five-minute timeout.
- Graphical unlock succeeded.
- The desktop returned after unlock.
- The graphical session reported `Type=wayland`,
  `Desktop=Regolith-Wayland`, `IdleHint=no`, and `LockedHint=no`.
- After unlock, only `swayidle` remained in the fallback process check.
- The failed user-unit audit was empty.

## Boundary

This was one cycle only. Repeated lock/unlock cycles, native
`cosmic-idle`/logind semantics, logout/shutdown behavior, hardware validation,
and signing/publication remain open. The earlier note recording an unlock
recovery failure is historical and is superseded for this single-cycle result;
it remains relevant to the unresolved repeated-lifecycle boundary.
