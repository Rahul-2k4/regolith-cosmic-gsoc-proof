# Known limitations

Consolidated from `README.md`, `WORK_PRODUCT.md`,
`WORK_PRODUCT_2026-08-09.md`, and every file under the project vault
`08_Blockers/` directory (34 notes as of 2026-08-10). Grouped by cause, not
by component.

Each entry: what fails or is unproven, why, what would close it.

## Contents

- [Hardware-blocked](#hardware-blocked)
- [Upstream-blocked](#upstream-blocked)
- [Protocol-limited](#protocol-limited)
- [Session lifecycle](#session-lifecycle)
- [Distribution](#distribution)
- [Scope not attempted (stretch / rejected paths)](#scope-not-attempted-stretch--rejected-paths)
- [Additional vault blockers mapped here](#additional-vault-blockers-mapped-here)
- [Explicit closure-plan exclusions](#explicit-closure-plan-exclusions)

## Hardware-blocked

### Mixed DPI / multi-display / hotplug

- **What:** Proposal criterion for multi-display hotplug, mixed DPI, and
  hardware display persistence is not met.
- **Why:** Qualification proof uses one QEMU virtual panel. A read-only host
  audit found only the internal laptop panel connected; no multi-head matrix
  was exercised.
- **Need:** Additional physical outputs (or an equivalent multi-head harness)
  plus a documented rollback path before full-laptop display claims.
- **Vault:** `2026-08-10` hardware boundary (via work product);
  historical display-matrix gaps also appear under vanilla-display and
  display-profile notes below.

### Physical touchpad reverse-sync

- **What:** `regolith-inputd` COSMIC touchpad reverse-sync is implemented and
  unit-tested, packaged, and install-checked in QEMU, but the live code path
  has never executed against a real touchpad.
- **Why:** The QEMU guest exposes no `type:touchpad` device.
- **Need:** Physical (or QEMU touchpad-emulating) seat that surfaces a
  touchpad to Sway/`libinput`, then re-run the reverse-sync verifier.
- **Vault:** `2026-07-10-inputd-touchpad-qemu-device-limit.md`

### Media-key delivery / full OSD surface

- **What:** Volume OSD path has QEMU evidence; media-key injection and full
  OSD coverage do not.
- **Why:** QEMU cannot inject multimedia keys in the proven harness.
- **Need:** Hardware keyboard with media keys, or a guest that accepts
  synthetic multimedia key events end-to-end.

### Full laptop boot / physical session

- **What:** No hardware/full-laptop Regolith COSMIC session proof.
- **Why:** Policy gate: QEMU cold-login must be clean, a fallback session
  must exist, and a rollback checklist must be written before full boot.
  Host connectivity and DNS alias boundaries also interrupted earlier
  laptop attempts.
- **Need:** Rollback checklist + clean QEMU gate, then a deliberate
  hardware boot with fallback session.
- **Vault (connectivity / access history):**
  `2026-07-12-remote-host-connectivity.md`,
  `2026-07-17-laptop-connectivity-current.md`,
  `2026-07-18-laptop-connectivity-current.md`,
  `2026-07-21-laptop-connectivity-current.md`,
  `2026-07-26-laptop-connectivity-after-target-build.md`,
  `2026-07-27-laptop-remote-access-resolution.md`,
  `2026-08-09-laptop-ssh-alias-dns-boundary.md`,
  `2026-08-10-inputd-worker-remote-connectivity.md`

## Upstream-blocked

### `cosmic-settings` Resolution selector renderer crash

- **What:** Opening the display Resolution popup in `cosmic-settings`
  reproducibly crashes the renderer under both Vulkan and GL paths in the
  proven guest.
- **Why:** Failure is inside upstream Settings/renderer behavior, not in
  Regolith wrapper code. Keyboard layout/variant via the Settings UI
  therefore remains “not met as written”; config-mutation propagation is
  proven separately.
- **Need:** Upstream ownership and fix (or a documented Regolith workaround
  that mentors accept as meeting the criterion).
- **Vault:** `2026-08-08-cosmic-settings-popup-renderer.md`

### Native `cosmic-comp` session as the Regolith path

- **What:** Native compositor has a separate QEMU seat proof, but it is not
  the Regolith-wrapper acceptance path.
- **Why:** Regolith ships a Sway-backed COSMIC session by design for this
  GSoC; native `cosmic-comp` persistence and greeter install paths hit
  privilege/greeter boundaries.
- **Need:** Explicit mentor decision to expand scope, plus greeter/install
  privilege handling.
- **Vault:** `2026-08-01-native-cosmic-install-privilege.md`; related
  `2026-08-02-qemu-visible-console-required.md` (SSH resolved; native
  runtime still pending at last note)

## Protocol-limited

### Native `cosmic-randr` mutation without Sway effect

- **What:** Native `cosmic-randr` / output-management mutation can report
  success without producing the Regolith-observed Sway IPC effect that the
  wrapper path uses for proof.
- **Why:** Protocol/compositor ownership differs between native COSMIC and
  the Sway-backed Regolith session. Proof for Regolith display changes goes
  through Sway IPC observation.
- **Need:** Either a native-comp Regolith path with its own acceptance
  tests, or continued documentation that Sway IPC is the authoritative
  observer for the shipped wrapper.

### Vanilla COSMIC display persistence clean rerun

- **What:** Vanilla `cosmic.desktop` / `cosmic-comp` display persistence is
  not a clean accepted proof for this project’s shipped path.
- **Why:** Earlier evidence required a clean rerun; scope stayed on the
  Regolith wrapper tuple.
- **Need:** Dedicated vanilla seat proof if that criterion is reinstated.
- **Vault:** `2026-07-10-vanilla-display-proof-requires-clean-rerun.md`

## Session lifecycle

### Direct `swaymsg exit` leaves parent alive

- **What:** Direct Sway exit stops the Regolith wrapper, compositor, COSMIC
  target, and helpers, but leaves parent `cosmic-session` /
  `dbus-run-session` alive.
- **Why:** Parent ownership sits with the display-manager / session
  launcher, not the compositor process tree alone.
- **Need:** Prefer display-manager-owned logout (`loginctl terminate-session`
  path already proven to return to greeter). Closing the parent-alive gap
  needs an explicit teardown contract change, not another Sway-exit test.
- **Evidence:** teardown / sway-exit proof notes cited from work product.

### Native cosmic-idle / logind semantics

- **What:** Two five-minute fallback timeout lock/unlock cycles have QEMU
  evidence; native cosmic-idle/logind semantics remain open.
- **Why:** Fallback path ≠ full native idle ownership proof.
- **Need:** Native idle ownership tests on the shipped session.

### GNOME path coexistence on the same QEMU seat

- **What:** Fresh visible GNOME desktop selection / dual-path coexistence
  on the qualification guest remains an open boundary in places.
- **Why:** COSMIC path consumed the proven greeter flow; GNOME regression
  is separately bounded.
- **Vault:** `2026-08-03-qemu-target-coexistence.md`,
  `2026-08-09-visible-greeter-selection-boundary.md`,
  `2026-07-17-installed-package-greeter-selection.md`
  (Noble manual-GDM path resolved; target-distro closure still open)

## Distribution

### Unsigned packages / no canonical publication

- **What:** All proven `.deb` artifacts are unsigned and unpublished to a
  canonical Regolith archive.
- **Why:** Mentor-coordinated publication and signing were never completed;
  Voulage fork Actions were also unavailable for automated publish.
- **Need:** Signing keys + agreed first Voulage publication target.
- **Vault:** `2026-07-21-voulage-fork-actions-unavailable.md`; signing
  called out across README / work product open boundaries.

### No Trixie / Ubuntu 26.04 graphical boot

- **What:** Runtime proof is on a Pop!_OS / Ubuntu Resolute QEMU seat, not
  a Debian Trixie or Ubuntu 26.04 graphical session.
- **Why:** No target-distro VM disk/ISO was stood up for graphical proof.
  Apt availability on those distros is separately recorded in
  [`BUILD_DEP_MATRIX.md`](BUILD_DEP_MATRIX.md) and does **not** equal a
  session boot.
- **Need:** Target-distro images plus the same cold-login suite.

### Packaging / pin / artifact durability gaps

- **What:** Several packaging proofs were historically blocked or later
  retracted when artifacts lived in disposable worktrees.
- **Why:** Clean-clone ref mismatches, pin sync lag, exact-package build
  boundaries, and disk-cleanup removing a recorded `.deb`.
- **Need:** Retained artifact paths; push-before-record; pin reconciled
  sources before citing hashes.
- **Vault:**
  `2026-07-20-voulage-inputd-pin-sync-pending.md`,
  `2026-07-27-inputd-exact-package-build-blocker.md`,
  `2026-07-27-inputd-package-runtime-install-boundary.md`,
  `2026-08-08-qemu-install-authorization.md`,
  `2026-08-09-voulage-clean-clone-ref-blocker.md`,
  `2026-08-10-unreachable-proof-artifacts.md`,
  `2026-07-20-cosmic-session-rust-toolchain-blocker.md`
  (toolchain resolved; package closure notes still relevant historically),
  `2026-07-21-macos-voulage-resolver-shell.md`
  (macOS shell blocker resolved for resolver-only checks)

### Historical cosmolith artifact retraction

- **What:** An older `cosmolith*.deb` hash from a removed disposable worktree
  is retracted and must not be used as current evidence.
- **Current state:** A newer exact package hash is retained in the
  [cold-reboot persistence proof](../proof-notes/2026-08-15-cosmolith-cold-reboot-persistence.md)
  and tied to the current source branch. The package is still unsigned and
  unpublished.
- **Need:** Canonical Voulage packaging, signing, publication, and maintainer
  acceptance.

## Scope not attempted (stretch / rejected paths)

### Proposal stretch goals

- Trawl bridge and keybinding translation were never in the closure critical
  path and were not attempted in the final window.

### Rejected inputd feature-gating candidate

- An earlier feature-gating approach was rejected; the accepted direction is
  Cargo features (`gnome` / `cosmic`) plus `XDG_CURRENT_DESKTOP` runtime
  selection.
- **Vault:** `2026-07-10-inputd-feature-gating-candidate-rejected.md`

### Early active-blocker snapshot (historical)

- `2026-05-28-active-blockers.md` predates the current tuple; surviving
  themes are covered above (build env, ordering, package closure, input).

## Additional vault blockers mapped here

These notes are operational or partially resolved; they still appear so the
blocker directory has no silent omissions:

| Vault note | Disposition in this doc |
|---|---|
| `2026-07-17-clean-target-access-blocker.md` | Superseded historically; access theme under Hardware / Distribution |
| `2026-07-17-current-head-inputd-runtime-proof.md` | Historical QEMU access block; superseded by later inputd QEMU proofs |
| `2026-07-26-displayd-eq-hash-review.md` | Source-review boundary; displayd equality/hash work progressed on fork branches |
| `2026-08-01-qemu-guest-ssh-readiness.md` | Guest SSH readiness; operational for QEMU harness |
| `2026-08-09-display-profile-reapply.md` | Display profile reapply; resolution note dated 2026-08-09 |
| `2026-08-09-inputd-cosmic-environment.md` | COSMIC inputd environment; later candidate verifier QEMU proof advanced this |

## Explicit closure-plan exclusions

From the 2026-08-10 final-closure plan, these remain declared out of scope
rather than attempted:

- Mixed-DPI and hotplug display validation
- Physical touchpad reverse-sync execution
- Media-key delivery
- `cosmic-settings` Resolution-selector renderer crash (upstream)
- Native `cosmic-comp` session / native `cosmic-randr` mutation as Regolith proof
- Trixie / Ubuntu 26.04 graphical session boot
- Package signing and canonical publication
- Stretch goals (trawl bridge, keybinding translation)
