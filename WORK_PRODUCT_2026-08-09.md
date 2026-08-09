# Regolith COSMIC work-product snapshot - 2026-08-09

This is the public, sanitized review surface for the Regolith COSMIC GSoC
work. It is not an upstream merge and it does not claim release readiness.

## Current status

- Engineering/component progress: approximately 80-85%.
- Strict proposal completion: approximately 70-75%.
- Current runtime proof: Sway-backed COSMIC session in QEMU.
- Native `cosmic-comp`, physical hardware, signing, and final lintian/release
  disposition remain open.

The lower strict estimate is deliberate. The proposal still has acceptance
gates for native or equivalent runtime boundaries, full display/input/idle
coverage, release disposition, and final mentor review.

## Proven work

- COSMIC session target ownership with healthy `regolith-inputd` and
  `regolith-displayd` helpers.
- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway` reaching the running
  helper processes.
- Keyboard layout, variant, and repeat propagation into Sway.
- Inputd reverse-sync guard tests, including `apply_all_sync` enabled and
  disabled paths. The isolated test branch is
  [available on the personal fork](https://github.com/Rahul-2k4/regolith-inputd/tree/rahul/inputd-empty-source-fallback-20260808).
- Single-output display profile reapplication and a reversible virtual
  two-output position/scale/disable-enable test.
- Fallback `swayidle + gtklock` timeout-to-lock/unlock proof and visible
  volume OSD proof.
- Clean Voulage builds, vendored dependency evidence, a Trixie-native
  `cosmic-comp` rebuild using `libdisplay-info2`, and real disposable Trixie
  installation of the exact five-package tuple.

## Exact boundaries

- The QEMU greeter does not reliably expose a native COSMIC selector, so no
  SSH-side compositor launch is treated as native graphical proof.
- The current QEMU testbed does not prove physical hotplug, mixed DPI, or
  hardware behavior.
- The Settings display selector has a reproducible QEMU renderer crash.
- Native `cosmic-idle`, logind lock-state semantics, media-key delivery, and
  full logout/reboot/shutdown lifecycle remain open.
- The current live QEMU health recheck passed target/helper health, zero
  restarts, zero failed user units, and empty `dpkg --audit`, but did not claim
  a second idle cycle because the guest was not in a clean baseline.
- The GNOME launch assets remain installed and the Regolith surface remains
  live in COSMIC QEMU, but a fresh visible GNOME login is still unproven
  because the greeter auto-starts COSMIC.
- The lintian audit found a real wm-config dependency contradiction and a
  builder-host changelog identity issue. Packaging-only fixes are isolated, but
  post-fix artifacts are not yet rebuilt.

## Public evidence

- [Current tuple acceptance](proof-notes/2026-08-09-current-tuple-acceptance.md)
- [Real disposable Trixie install](proof-notes/2026-08-09-real-trixie-container-install.md)
- [Live QEMU runtime boundary](proof-notes/2026-08-09-live-qemu-runtime-recheck.md)
- [Inputd reverse-sync tests](proof-notes/2026-08-09-inputd-reverse-sync-tests.md)
- [GNOME coexistence boundary](proof-notes/2026-08-09-gnome-regression-boundary.md)
- [Lintian release audit](proof-notes/2026-08-09-lintian-release-audit.md)
- [Display persistence fix](proof-notes/2026-08-09-display-profile-reapply-fix.md)
- [Headless display matrix](proof-notes/2026-08-09-headless-display-matrix.md)
- [Fallback idle timeout](proof-notes/2026-08-09-idle-timeout-fallback.md)
- [Clean Voulage rebuild](proof-notes/2026-08-09-clean-voulage-rebuild.md)

No passwords, private host details, private paths, or signing material are
included in this branch.
