# Current tuple fallback lock/unlock QEMU proof - 2026-08-09

## Scope

This note records two real fallback lock/unlock cycles in the current-tuple,
Sway-backed Regolith Wayland COSMIC session running in QEMU. Each cycle used
the five-minute `swayidle -w timeout 300 gtklock` timeout path. This is
QEMU-only proof; it is not hardware or native COSMIC idle proof.

## Observed result

- The target-owned `swayidle -w timeout 300 gtklock` path produced a visible
  lock screen after the five-minute timeout in both cycles.
- Graphical unlock succeeded in both cycles.
- The graphical session returned after each unlock.
- The graphical session reported `Type=wayland`,
  `Desktop=Regolith-Wayland`, `IdleHint=no`, and `LockedHint=no`.
- After unlock, only `swayidle` remained in the fallback process check.
- The failed user-unit audit was empty.

## Boundary

Two fallback cycles passed, but native `cosmic-idle`/logind semantics,
logout/shutdown behavior, hardware validation, and signing/publication remain
open. The earlier note recording an unlock recovery failure is historical and
is superseded by this two-cycle result; native lifecycle behavior remains
unresolved.
