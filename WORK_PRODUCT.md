# Build a COSMIC-based Wayland Session for Regolith

This is the stable reviewer-facing work-product page for the Regolith COSMIC
proof bundle. It records only evidence in this repository and the latest
sanitized wrapper proof.

## Current estimate

- Strict proposal completion: **70-75%**.
- Engineering/component progress: **80-85%**.

The strict estimate remains lower because the runtime matrix, lifecycle,
release, and review gates are not closed.

## Source of truth

The public source of truth is the
[`rahul/2026-08-08-final-tuple-proof` branch](https://github.com/Rahul-2k4/regolith-cosmic-gsoc-proof/tree/rahul/2026-08-08-final-tuple-proof).

This page is a proof bundle, not an upstream merge. No upstream PR or `main`
merge is claimed, and no hardware result is claimed.

## Proven areas

- **Sway-backed wrapper cold reboot:** the installed `regolith-session-cosmic`
  wrapper returned to the Regolith Wayland COSMIC session after a disposable
  QEMU reboot. The session exposed `Regolith-Wayland:COSMIC:sway`.
  [Wrapper cold-reboot proof](proof-notes/2026-08-09-regolith-wrapper-cold-reboot-qemu-proof.md)
- **Target ownership:** the COSMIC target owned healthy `regolith-inputd` and
  `regolith-displayd` helpers, while the GNOME target remained separate and
  inactive for that COSMIC login.
  [Current tuple acceptance](proof-notes/2026-08-09-current-tuple-acceptance.md)
- **Input keyboard path:** keyboard layout, variant, and repeat propagation
  into Sway, plus focused COSMIC layout/variant event tests.
  [COSMIC keyboard event tests](proof-notes/2026-08-09-cosmolith-input-tests.md)
- **Single-output persistence:** fresh-login display profile reapplication
  passed on the Sway-backed QEMU path.
  [Display profile reapplication proof](proof-notes/2026-08-09-display-profile-reapply-fix.md)
- **Virtual matrix:** a reversible virtual two-output position, scale, and
  disable-enable test is recorded in the current reviewer snapshot.
  [Dated reviewer snapshot](WORK_PRODUCT_2026-08-09.md)
- **Fallback lock:** the `swayidle + gtklock` timeout-to-lock/unlock fallback
  has QEMU evidence; native idle and logind semantics remain open.
  [Corrected tuple lifecycle](proof-notes/2026-08-09-corrected-tuple-lifecycle.md)
- **OSD:** a visible COSMIC volume overlay was produced in the Sway-backed
  COSMIC QEMU session.
  [COSMIC volume OSD proof](proof-notes/2026-08-09-cosmic-osd-volume.md)
- **Vendored/package installation:** clean Voulage builds with vendored
  dependencies and real disposable Trixie installation of the exact package
  tuple are recorded.
  [Clean Voulage rebuild](proof-notes/2026-08-09-clean-voulage-rebuild.md) ·
  [Real disposable Trixie install](proof-notes/2026-08-09-real-trixie-container-install.md)

## Open boundaries

- Settings panel display interaction, including its reproducible renderer
  crash.
- Physical or equivalent display matrix: multi-display, hotplug, and mixed
  DPI behavior remain unverified.
- Touchpad coverage, input reverse-sync runtime behavior, and a fresh visible
  GNOME desktop selection remain open.
- Full logout, reboot, shutdown, idle, and unlock lifecycle coverage remains
  open beyond the recorded fallback path.
- Signing, release readiness/publication, and final mentor review remain open.

[GNOME coexistence boundary](proof-notes/2026-08-09-gnome-regression-boundary.md) ·
[Inputd reverse-sync tests](proof-notes/2026-08-09-inputd-reverse-sync-tests.md) ·
[Live QEMU runtime boundary](proof-notes/2026-08-09-live-qemu-runtime-recheck.md) ·
[Lintian release audit](proof-notes/2026-08-09-lintian-release-audit.md)

## Claim boundary

The wrapper and target-ownership result is QEMU proof. Native `cosmic-comp`
runtime has a separate QEMU proof, but it is not Regolith-wrapper validation:
[native compositor proof](proof-notes/2026-08-09-native-cosmic-comp-qemu-proof.md).
No hardware claim, upstream PR, or `main` merge is included here.
