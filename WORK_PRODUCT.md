# Build a COSMIC-based Wayland Session for Regolith

This is the stable reviewer-facing work-product page for the Regolith COSMIC
proof bundle. It records only evidence in this repository and the latest
sanitized wrapper proof.

## Current estimate

- Strict proposal completion: **74-78%**.
- Engineering/component progress: **82-86%**.

The strict estimate remains lower because the runtime matrix, lifecycle,
release, and review gates are not closed.

## Source of truth

The public source of truth is the
[`rahul/2026-08-08-final-tuple-proof` branch](https://github.com/Rahul-2k4/regolith-cosmic-gsoc-proof/tree/rahul/2026-08-08-final-tuple-proof).

This page is a proof bundle, not an upstream merge. No upstream PR or `main`
merge is claimed, and no hardware result is claimed.

**Voulage provenance correction:** the existing clean artifacts remain tied to
the audited build evidence that produced them. Corrected model commit
[`f38278934be32e9d051390b19cc416c3f320e7e5`](https://github.com/Rahul-2k4/voulage/commit/f38278934be32e9d051390b19cc416c3f320e7e5) restores session source `3523047b`,
but it requires a rebuild before it can be called the current package model.

## Proven areas

- **Final-tuple wrapper closure:** two sequential cold boots of the installed
  final package tuple returned to the Sway-backed Regolith Wayland COSMIC
  session. The target/helper health checks passed on both logins.
  [Sequential cold-login proof](proof-notes/2026-08-09-final-tuple-sequential-cold-login-proof.md)
- **Target ownership:** the COSMIC target owned healthy `regolith-inputd` and
  `regolith-displayd` helpers, while the GNOME target remained separate and
  inactive for that COSMIC login.
  [Current tuple acceptance](proof-notes/2026-08-09-current-tuple-acceptance.md)
- **Input keyboard path:** keyboard layout, variant, and repeat propagation
  into Sway, plus focused COSMIC layout/variant event tests.
  [COSMIC keyboard event tests](proof-notes/2026-08-09-cosmolith-input-tests.md)
- **Cosmolith source closure:** the personal fork now has structured watcher
  errors and deterministic COSMIC session detection. A clean laptop check
  passed with 14 tests and no failures.
  [Cosmolith source closure](proof-notes/2026-08-09-cosmolith-source-closure.md)
- **Single-output persistence:** fresh-login display profile reapplication
  passed on the Sway-backed QEMU path.
  [Display profile reapplication proof](proof-notes/2026-08-09-display-profile-reapply-fix.md)
- **Newer displayd artifact:** an isolated unsigned `regolith-displayd`
  artifact from source commit `21e4553618cb8f0d21e46bac13a37451cb489059`
  produced package `0.3.4-1-1regolith-resolute` with SHA-256
  `766a2a19a5b0e478f02384ff8b0b2c35ae278789e0c7922d09eb8d6b26d161ed`.
  Twelve tests passed with 142 vendored crates. A live `1024x768` recording
  restored to `1280x800` after one cold reboot; the service had zero restarts
  and the package audit was clean.
  [Displayd runtime artifact proof](proof-notes/2026-08-09-displayd-runtime-artifact-proof.md)
- **Displayd packaging cleanup:** personal-fork source commit `39c3746c`
  adds the two manual pages, corrects Debian metadata, and adds a packaging
  regression test. Follow-up branch `c99495e` fixes the historical changelog
  entry and automatic dbgsym generation. Its isolated Voulage artifact has
  clean binary and `.changes` Lintian results, package SHA-256
  `f733551be828ea4ff73043f71ebbd4a955b3d6a06ae3071190e761623a6df512`, and
  the earlier package had a matching disposable-QEMU install with empty
  `dpkg --audit`.
  [Displayd packaging proof](proof-notes/2026-08-09-displayd-packaging-proof.md)
- **Virtual matrix:** a reversible virtual two-output position, scale, and
  disable-enable test is recorded in the current reviewer snapshot.
  [Dated reviewer snapshot](WORK_PRODUCT_2026-08-09.md)
- **Fallback lock:** the configured five-minute `swayidle + gtklock` path now
  has a visible QEMU timeout-lock capture. The exact unlock attempt did not
  clear that run, so native idle, logind semantics, and a complete repeated
  lifecycle remain open.
  [Corrected tuple lifecycle](proof-notes/2026-08-09-corrected-tuple-lifecycle.md)
- **OSD:** a visible COSMIC volume overlay was produced in the Sway-backed
  COSMIC QEMU session.
  [COSMIC volume OSD proof](proof-notes/2026-08-09-cosmic-osd-volume.md)
- **Vendored/package installation:** clean Voulage builds with vendored
  dependencies and real disposable Trixie installation of the exact package
  tuple are recorded.
  [Clean Voulage rebuild](proof-notes/2026-08-09-clean-voulage-rebuild.md) ·
  [Real disposable Trixie install](proof-notes/2026-08-09-real-trixie-container-install.md)
- **Cosmolith package boundary:** the exact `cosmolith` source was built through
  vendoring, offline compilation, Debian source-package generation, and binary
  package creation. The resulting `.deb` was installed in QEMU with matching
  SHA-256 values and an empty `dpkg --audit`. A fresh-session launch of the
  packaged executable is not claimed.
  [Cosmolith package/install boundary](proof-notes/2026-08-09-cosmolith-package-install-boundary.md)

## Open boundaries

- A fresh-session runtime check for the packaged cosmolith executable remains
  open. Signing, canonical publication, and final release disposition are also
  open.

- Settings panel display interaction, including its reproducible renderer
  crash.
- Physical or equivalent display matrix: multi-display, hotplug, and mixed
  DPI behavior remain unverified.
- Touchpad coverage, input reverse-sync runtime behavior, and a fresh visible
  GNOME desktop selection remain open.
- Full logout, shutdown, idle, and unlock lifecycle coverage remains open
  beyond the recorded fallback path; reboot ordering is covered by the wrapper
  proof.
- Signing, release readiness/publication, and final mentor review remain open.
- Signing, the full display matrix, native Settings validation, and hardware
  validation remain open for the newer displayd artifact.

[GNOME coexistence boundary](proof-notes/2026-08-09-gnome-regression-boundary.md) ·
[Inputd reverse-sync tests](proof-notes/2026-08-09-inputd-reverse-sync-tests.md) ·
[Live QEMU runtime boundary](proof-notes/2026-08-09-live-qemu-runtime-recheck.md) ·
[Lintian release audit](proof-notes/2026-08-09-lintian-release-audit.md) ·
[Sequential cold-login proof](proof-notes/2026-08-09-final-tuple-sequential-cold-login-proof.md) ·
[Displayd runtime artifact proof](proof-notes/2026-08-09-displayd-runtime-artifact-proof.md)

## Claim boundary

The wrapper and target-ownership result is QEMU proof. Native `cosmic-comp`
runtime has a separate QEMU proof, but it is not Regolith-wrapper validation:
[native compositor proof](proof-notes/2026-08-09-native-cosmic-comp-qemu-proof.md).
No hardware claim, upstream PR, or `main` merge is included here.
