# Build a COSMIC-based Wayland Session for Regolith

This is the stable reviewer-facing work-product page for the Regolith COSMIC
proof bundle. It records only evidence in this repository and the latest
sanitized wrapper proof.

## Latest source checkpoint — 2026-08-23

The current reconciled `regolith-inputd` source includes vendored offline build
wiring (`e3fbd5c`), keyboard/input-source reverse synchronization
(`b07ea315`), and pointer reverse synchronization (`e8fce66`). Its current
unsigned package is
`regolith-inputd_0.4.1-2-1regolith-resolute_e8fce66_amd64.deb`, SHA-256
`650bd6f38bf67a08e140fa566aff4e7c63b2a41fc2cc60b04aada670a420823b`.
The branch passes 55 tests with both GNOME and COSMIC features enabled. This
exact package was then installed in the combined tuple and survived a fresh
reboot with Sway, inputd, displayd, active COSMIC targets, persistent Sway IPC,
one headless output, no failed user units, and clean `dpkg --audit`. This is
headless/pixman QEMU proof only; the strict ledger below remains 5/12 fully met,
QEMU-only.

See the [final exact-package cold-login proof](proof-notes/2026-08-23-inputd-cosmic-cold-login-final.md).

## Proposal success criteria: 5 of 12 fully met

| # | Criterion | Status | Scope |
|---|---|---|---|
| 1 | Fresh login into COSMIC-backed session | Met | QEMU |
| 2 | `gnome-session-bin` absent, `cosmic-session` PID, correct desktop token | Met | QEMU |
| 3 | Multi-display hotplug / mixed DPI / persistence on hardware | Not met | hardware unavailable |
| 4 | Keyboard layout + variant via cosmic-settings reflected in Sway | Not met as written | Settings panel crashes; propagation proven via config mutation |
| 5 | Shipped lock/unlock validated end-to-end on Sway | Met | QEMU |
| 6 | OSDs render correctly | Partial | volume OSD only; media keys uninjectable in QEMU |
| 7 | Settings persist across reboot | Partial | QEMU-only: keyboard state, display resolution, and display scale persisted on the tested path, but a later real display proof found refresh-rate persistence was wrong (`60Hz` requested, `50Hz` restored), so the broad criterion cannot stay `Met` |
| 8 | Retained surface (workspaces, i3status-rs, ilia) works | Partial | live QEMU Sway session; i3status-rs, ilia, and representative workspace switching observed; full matrix open |
| 9 | Package audit: GNOME session/bootstrap removed, survivors justified | Met | the [combined three-fix verification boot](proof-notes/2026-08-21-combined-three-fix-verification-qemu.md) reached a clean QEMU COSMIC login with no `gdm3`, `gnome-shell`, `gnome-session-bin`, or `ubuntu-session`, zero failed user units, clean `dpkg --audit`, and only documented non-bootstrap GNOME-named survivors |
| 10 | Voulage metadata + validated builds, publication coordinated | Partial | Unsigned Resolute builds, vendoring, and the clean local-pool package transaction are proven; see the [Ubuntu 26.04 closure](proof-notes/2026-08-17-ubuntu-resolute-local-pool-closure.md) and [fresh QEMU COSMolith proof](proof-notes/2026-08-17-fresh-cosmolith-input-display-persistence-qemu.md); canonical publication and maintainer coordination remain open |
| 11 | Vendored tarballs for all Rust-heavy components, offline verified | Met | 35+ packages, `--frozen --offline` |
| 12 | Keyboard-first workflow preserved via Sway `bindsym` | Partial | fresh QEMU `Mod4+Space` launcher plus `Mod4+2`/`Mod4+1` workspace switches; full keyboard matrix open |

The [combined three-fix verification boot](proof-notes/2026-08-21-combined-three-fix-verification-qemu.md)
is the current package-audit result. It supersedes the earlier partial-stage
survivor notes for the QEMU scope: the tested boot had no GNOME session or
bootstrap packages in the active COSMIC path, zero failed user units, and
clean package state on the same boot. The remaining GNOME-named packages in
that run were documented dependency or theme survivors, not session bring-up
payload.

The [displayd real apply and persistence proof](proof-notes/2026-08-21-displayd-real-apply-and-persistence-qemu.md)
is the current display-persistence result. It proved real live mode and scale
changes plus cold-reboot persistence on a VNC-backed QEMU output, but it also
found a real bug: the requested refresh rate did not persist correctly. That
keeps Criterion 7 at `Partial`.

The August 22 inputd gate is a historical package checkpoint at the mentor-approved tuple
`0.4.1-2-1regolith-resolute`. Source `fc895d00b890ff010dae58be8f4265fa219cabbb`
passed 61 offline feature tests; the unsigned package SHA-256 is
`e1cf3eaca8a73b0aab6b1f117897baddb724c914c1797f9d3ecb126d89d2a221`, and it
was installed in the disposable guest. A fresh post-reboot greetd launch still
leaves only `cosmic-session`; the user Sway child exits before persistent IPC
remains, so this package result does not claim combined user-session closure.

The [target-edge rerun](proof-notes/2026-08-23-session-target-edge-rerun.md)
rebuilt the session package from `35a0833eb98acbdcb756b65655e08c3ece37e0ac`
as `1.2.0-1ubuntu1` (SHA-256
`5a74aba9ccb9f0ca9bb499237be7ebc1187c7e25af789f2ce57242f545b9c3b3`). The
premature parent-target edge is removed and the runtime starts
`regolith-cosmic.target` after compositor readiness. QEMU reached that target,
but the COSMIC-supervised Sway child still exited before persistent IPC in that
stage. Follow-up commits `a29cc13` and `6670d8b` now bridge the COSMIC `SetEnv`
handshake and tolerate absent legacy units; the rebuilt package keeps Sway,
cosmic-session, inputd, displayd, and the idle fallback active with persistent
Wayland/Sway IPC sockets in a fresh QEMU login.

The isolated [Voulage target-split repin](proof-notes/2026-08-16-voulage-session-target-split-repin.md)
now pins the proven `regolith-session` target split at `831596f`. This closes
the model-integrity gap for that isolated branch, but it is not a new build or
runtime result. At the time of that repin note, Criterion 9 was still `Partial`.
The current row above is based on the later Aug 21 combined verification boot.

The follow-up [target-split package build](proof-notes/2026-08-16-voulage-session-target-split-build.md)
built the exact pin successfully and verified package ownership. The complete
external dependency graph and fresh install were not rerun from this artifact.
It remains historical support for the later Aug 21 package-audit result.

The newer [criterion 9 exact repin audit](proof-notes/2026-08-16-criterion-9-session-repin-audit.md)
rechecks source `831596f`, Voulage model `5b11b055`, six package hashes, target
ownership, and direct metadata. It records the exact QEMU and clean-container
boundaries honestly: the available graphical guest is Noble while the packet
is Resolute, and the disposable closure run lacked the complete upstream
Regolith dependency pool. No exact-packet graphical-login claim is made.

The earlier read-only QEMU pass confirmed guest key-based SSH but found only
the greeter. A later snapshot-backed cold login reached a live COSMIC/Sway
session, activated both target-owned helpers, and opened the ilia launcher via
one resolved Sway binding. A later run also switched from workspace 1 to 2 and
back through representative bindings. This is still QEMU-only and does not
prove the full keyboard or retained-surface matrix. See the
[live-login proof](proof-notes/2026-08-11-qemu-live-login-inputd-bindsym.md)
and the earlier [greeter/SSH boundary](proof-notes/2026-08-11-qemu-greeter-ssh-boundary.md).
The fresh [workspace-binding proof](proof-notes/2026-08-11-qemu-keyboard-workspace-binding-proof.md)
records a `1 -> 2 -> 1` transition through HMP-injected Sway bindings.
The corrected [launcher-binding proof](proof-notes/2026-08-11-qemu-launcher-binding-proof.md)
also records `Mod4+Space` launching `ilia`.
The fresh [final-tuple parent-exit proof](proof-notes/2026-08-12-final-tuple-parent-exit-proof.md)
also records a clean controlled Sway exit with `PARENT_EXIT_PASS`.

The [cosmolith cold-reboot persistence proof](proof-notes/2026-08-15-cosmolith-cold-reboot-persistence.md)
adds exact current package hashes, a generated-config round trip, and a fresh
graphical QEMU login after reboot. It proves one input setting only; it does
not close the Settings GUI, native compositor, hardware, or full display
persistence boundaries.

The [combined displayd package QEMU proof](proof-notes/2026-08-15-combined-displayd-package-qemu-proof.md)
adds the exact current Voulage-built displayd package to the same disposable
QEMU integration boundary. The package tuple reaches a cold graphical login,
both target-owned helper units are active, and Sway IPC reports the virtual
output and input devices. It does not close physical hardware, publication,
or the full display/settings matrix.

The [patched display-persistence QEMU proof](proof-notes/2026-08-16-display-persistence-patched-qemu-proof.md)
adds the patched personal-fork commits and exact package hashes. After a cold
login in a disposable QEMU overlay, the then-current candidate applied the
named QEMU profile and Sway IPC reported `Virtual-1` at `1024x768@60.004Hz`.
That run used the pre-correction Kanshi ownership and is retained as
historical single-output persistence evidence only.

The [fresh COSMolith input/display proof](proof-notes/2026-08-17-fresh-cosmolith-input-display-persistence-qemu.md)
was the then-current persistence result. With the active Sway session context,
COSMolith applied French/AZERTY and repeat `540/31` live; the generated
directives and `1024x768` display state remained after a second login. This
closed the tested keyboard-side slice at the time. The later Aug 21 display
proof above found that refresh-rate persistence was still wrong, so the broader
Criterion 7 row no longer stays `Met`.

The later [current-package persistence attempt](proof-notes/2026-08-16-final-displayd-persistence-attempt-failed.md)
tested the final displayd package alone. The live mode change was accepted,
but after a cold reset the output and profile returned to `1280x800`. This is
recorded as a failed bounded attempt; it does not replace or broaden the
earlier exact-tuple proof.

The [e606e0c displayd candidate](proof-notes/2026-08-16-displayd-storage-pass-apply-fail.md)
prevents the initial Wayland snapshot from overwriting the saved profile. In
QEMU, the profile survived a cold reset, but the compositor remained at
`1280x800` because the current COSMIC path has no active profile-apply helper.
This is storage-pass/apply-fail evidence for that displayd-only tuple;
criterion 7 remains `Partial`.

The [cosmic-osd metadata and Lintian closure](proof-notes/2026-08-16-cosmic-osd-lintian-closure.md)
records reviewed source `63afc394` and an unsigned Ubuntu Resolute package
with version `0.1.0-1-1regolith-resolute`, SHA-256
`a5b827b387758731e010d076a7efd7e043289cc320d71601e533ea61ad228e2d`, and
Lintian exit `0`. This is package-quality evidence only; it does not prove
signing, official publication, or graphical runtime.

The [cosmic-settings-daemon metadata closure](proof-notes/2026-08-16-cosmic-settings-daemon-lintian-closure.md)
records source commit `59d674e1`, a successful vendored Ubuntu Resolute build,
package version `0.1.0-1-1regolith-resolute`, SHA-256
`e10c88b9a3f71b9327b4a165dca8c87f343cc3756a00d269e5cc90d6386aec3d`, and a
clean direct binary-package Lintian run. Remaining source and dbgsym warnings
are listed in the note; this is package-quality evidence, not release or
runtime proof.

The [final tuple graphical-login rerun](proof-notes/2026-08-16-final-tuple-graphical-login-rerun.md)
adds a fresh Pop!_OS QEMU reboot/login using the current session target-start,
inputd, displayd, and wm-config packages. The COSMIC target and helper units
were healthy, the GNOME target was inactive, `dpkg --audit` was empty, ilia
launched through `Mod4+Space`, and representative workspace switching passed.
This strengthens QEMU evidence without closing the Ubuntu Resolute or
hardware gates.

The [canonical inputd QEMU runtime note](proof-notes/2026-08-16-inputd-canonical-qemu-runtime.md)
repeats the packaged COSMIC backend/session contract with source commit
`c658754e`, inputd package SHA-256
`52dfaba9617f046100ae0b32392662254e5411cc8d3c7c1265c57358e1901d34`, and
installed binary SHA-256
`955bc3838fda47d69d14cd132cba64960b35a52323e88d201d986fbc75be6315`.
That verifier note does not claim live input-source mutation, physical touchpad
reverse-sync, Ubuntu Resolute graphical login, or hardware proof.

The [canonical inputd xkb live-watch proof](proof-notes/2026-08-17-inputd-canonical-xkb-live-watch-qemu.md)
adds a fresh Pop!_OS QEMU run against the same package. A COSMIC xkb config
mutation to French/AZERTY and repeat `540/31` was reflected by Sway, then the
US `600/25` state was restored. This is config-layer watcher evidence, not a
COSMIC Settings GUI, physical touchpad, or hardware claim.

The [updated displayd Kanshi-guard runtime note](proof-notes/2026-08-18-displayd-kanshi-guard-runtime.md)
records the corrected displayd source `91bdd26`, Voulage model `616d9f16`, and
a successful disposable-QEMU install, reboot, greetd authentication, and
COSMIC session start with the five-package tuple.
The tuple now uses the corrected published COSMIC inputd package from source
`3b3309a`, Voulage model `fff1c5c0`, SHA-256
`7fbd2078e423f73dcdd05276057eb6bf5dfcd71150fd473dc9ad63b785ccb811`; the
updated runner is on commit `9762101`.
Displayd profile storage is isolated in source commit `44660e8`, with 76 tests
passing. The Wayland observer still needs to retain output-management handles
before a real COSMIC `create_configuration` reapply can be implemented.

The [combined input/display persistence proof](proof-notes/2026-08-17-combined-input-display-persistence-qemu.md)
is a historical same-day tuple whose traced launcher lacked the active Sway
session context; its repeat value reverted to `600/25`. The [fresh
session-context proof](proof-notes/2026-08-17-fresh-cosmolith-input-display-persistence-qemu.md)
supersedes that diagnostic result: it records the corrected launcher identity,
live repeat application, and the second cold reboot/login result used for the
then-current keyboard-side persistence status. The later Aug 21 display proof
is what sets the current Criterion 7 row.

The public branch includes the reviewed
[inputd candidate QEMU verifier](scripts/verify-inputd-candidate-qemu-runtime.sh),
introduced in `cedcd52` and hardened in `f8a84a0`. It checks an already-installed session without
installing packages, restarting services, or changing persistent
configuration. It requires the expected package version and binary SHA-256,
checks COSMIC/GNOME target boundaries, helper dependency membership, zero
restarts, and allowlisted process-environment values. With `INPUTD_HELPER`,
live input settings are temporarily changed and restored; that mode is not
purely read-only.

## Source of truth

The public source of truth is the `main` branch of this repository. Per-claim
commit references appear inline in the code inventory below.

This page is a proof bundle, not an upstream merge. No common Regolith
upstream PR or `main` merge is claimed. COSMIC-specific cosmolith PRs #17,
#18, and #19 are open under mentor authorization and are not presented as
merged. No hardware result is claimed.

The latest criteria-affecting notes in this repository are the
[combined three-fix verification boot](proof-notes/2026-08-21-combined-three-fix-verification-qemu.md)
and the
[displayd real apply and persistence proof](proof-notes/2026-08-21-displayd-real-apply-and-persistence-qemu.md).

The latest target-owned helper runtime result is recorded in the [QEMU lifecycle v2 proof](proof-notes/2026-08-11-target-owned-helper-lifecycle-qemu-runtime-v2.md). The final target-split package tuple has now also passed disposable QEMU installation, cold reboot, greetd graphical login, target/helper health, launcher binding, workspace switching, and empty `dpkg --audit`; see the [direct package audit and final tuple proof](proof-notes/2026-08-11-direct-session-package-audit.md). Parent-session teardown is separately covered by the reviewed `cosmic-session` candidate proof; full display-manager logout and shutdown remain open.

**Acceptance-boundary note:** the submitted PDF used “legacy helper units
inactive” as its success wording. Mentor feedback later approved separate
GNOME/COSMIC systemd targets, with the COSMIC target owning the compatible
inputd and displayd helpers. The current proof therefore expects those helpers
to be active under `regolith-cosmic.target`, with successful results, zero
restarts, and no GNOME session bootstrap. This is the current implementation
boundary; it is not a claim that the original PDF wording was tested unchanged.

**Voulage provenance correction:** corrected model commit
[`f38278934be32e9d051390b19cc416c3f320e7e5`](https://github.com/Rahul-2k4/voulage/commit/f38278934be32e9d051390b19cc416c3f320e7e5) restores session source `3523047b`,
was rebuilt into the exact unsigned session package, installed in QEMU, and
exercised through the real greeter. See the [corrected-model proof](proof-notes/2026-08-10-corrected-voulage-model-real-greeter.md).

The separate Voulage branch
[`codex/voulage-cosmic-pin-regression-20260810`](https://github.com/Rahul-2k4/voulage/commit/abbf6562dd670637d9c7fa70284befc5dba01fd6)
adds a regression test for the exact immutable source pins of the frozen
session, inputd, and displayd package model. The test passes; this is model
integrity evidence, not a new package build or release claim.

## Proven areas

- **Final-tuple wrapper closure (QEMU):** two sequential cold boots of the
  installed final package tuple returned to the Sway-backed Regolith Wayland
  COSMIC session. The target/helper health checks passed on both logins.
  [Sequential cold-login proof](proof-notes/2026-08-09-final-tuple-sequential-cold-login-proof.md)
- **Corrected Voulage model runtime (QEMU):** the exact package built from model
  `f38278934be32e9d051390b19cc416c3f320e7e5` and session source `3523047b`
  launched through the real QEMU greeter. The package version, target-owned
  helper health, `dpkg --audit`, and rollback checksum are recorded in the
  [corrected-model proof](proof-notes/2026-08-10-corrected-voulage-model-real-greeter.md).
- **Target ownership (QEMU):** the COSMIC target owned healthy `regolith-inputd`
  and `regolith-displayd` helpers, while the GNOME target remained separate and
  inactive for that COSMIC login.
  [Current tuple acceptance](proof-notes/2026-08-09-current-tuple-acceptance.md)
- **Target-owned helper lifecycle v2 (QEMU):** after moving legacy target
  isolation before COSMIC target activation, a fresh cold login kept both
  daemon services `active (running)` with `ExecMainStatus=0`. The target graph,
  package transition, empty `dpkg --audit`, and overlay cleanup also passed.
  The patched `cosmic-session` candidate now exits cleanly after a controlled
  Sway exit in a disposable QEMU overlay; the post-exit check reported
  `PARENT_EXIT_PASS` and found no `cosmic-session` or `dbus-run-session` parent.
  Full display-manager logout and shutdown behavior remains open.
  [Lifecycle v2 proof](proof-notes/2026-08-11-target-owned-helper-lifecycle-qemu-runtime-v2.md)
  · [Canonical parent lifecycle diagnostic](proof-notes/2026-08-11-parent-lifecycle-diagnostic-qemu-proof.md)
  · [Current `a14abe3` package QEMU proof](proof-notes/2026-08-11-current-a14-cosmic-session-package-qemu-proof.md)
  · [Fresh final-tuple parent-exit proof](proof-notes/2026-08-12-final-tuple-parent-exit-proof.md)
- **Mentor-aligned source regression coverage:** the session package test now
  derives the COSMIC-only ownership set from its install manifest and rejects
  path overlap in other session packages. The inputd branch directly tests
  COSMIC touchpad reverse sync, and the displayd branch tests Wayland observer
  head/mode removal. These are Linux source/package checks, not hardware or
  graphical-session proof.
  [Source-test proof](proof-notes/2026-08-11-mentor-boundary-source-tests.md)
- **Cosmolith Sway helper coverage:** the COSMIC-specific branch now has
  focused tests for keyboard-option normalization, modifier/XKB binding
  formatting, and representative retained-workflow actions. A fresh Linux
  clone passed 10 library tests and 10 binary-target tests. This remains source evidence only; the
  branch's pre-existing formatting debt and live IPC/hardware boundaries are
  recorded rather than hidden.
  [Sway helper test proof](proof-notes/2026-08-12-cosmolith-sway-helper-tests.md)
- **Displayd Wayland reconciliation:** the isolated displayd branch adds
  deterministic tests for output-head removal, mode removal, and replacement
  of a multi-output manager snapshot. Its fresh Linux clone passed 51 library
  and 25 binary-target tests. This is source/test evidence only; physical
  hotplug and mixed-DPI runtime coverage remain open.
  [Wayland reconciliation proof](proof-notes/2026-08-12-displayd-wayland-multi-output-reconciliation.md)
- **Latest source verification:** the inputd branch adds direct COSMIC mouse
  reverse-sync and watcher-gate coverage, while the session branch bounds
  parent cleanup to the packaged COSMIC launcher and exact `cosmic-session`
  ancestry. Fresh laptop clones passed 7 focused inputd tests, 55 full COSMIC
  tests, and the session shell/teardown checks.
  [Mouse/session source proof](proof-notes/2026-08-11-mouse-session-source-verification.md)
- **Inputd feature-matrix verification:** the current laptop checkout at
  `271bc2a` passed 50 all-feature tests, 47 COSMIC-only tests, and 23 GNOME-only
  tests on Linux, with formatting and diff checks clean. The COSMIC-only build
  reports two Rust dead-code warnings. This confirms source-level feature
  isolation and handler coverage; it does not prove hardware input or a fresh
  QEMU run from this exact source commit.
  [Feature-matrix proof](proof-notes/2026-08-12-inputd-feature-matrix-linux.md)
- **Inputd branch reconciliation and keyboard routing:** canonical source
  `c658754` combines the touchpad/lintian head with keyboard routing source
  `271bc2a`. COSMIC and all-feature tests each passed 51/51, with formatting
  and diff checks clean. This is an internal routing proof only; active-layout
  persistence and live input remain open.
  [Canonical reconciliation proof](proof-notes/2026-08-11-inputd-canonical-reconciliation.md)
  [Keyboard routing proof](proof-notes/2026-08-11-inputd-keyboard-routing.md)
- **Input keyboard path:** keyboard layout, variant, and repeat propagation
  into Sway, plus focused COSMIC layout/variant event tests.
  [COSMIC keyboard event tests](proof-notes/2026-08-09-cosmolith-input-tests.md)
- **Keyboard reverse-sync API boundary:** the pinned `swayipc 3.0.1` input
  model does not expose keyboard repeat fields. The reviewed inputd branch
  records a typed no-op adapter and keeps keyboard/input-source handling
  separate instead of inventing an API. Linux verification passed 8 focused
  tests, 58 all-feature tests, formatting, and diff checks. This is source
  evidence only; live keyboard reverse-sync remains open.
  [Keyboard reverse-sync boundary](proof-notes/2026-08-11-inputd-keyboard-reverse-sync-boundary.md)
- **Current-hash inputd runtime (QEMU):** source `e32d049`, package
  `0.4.1-1-1regolith-resolute`, and a QEMU COSMIC cold login with the active
  inputd service and COSMIC backend environment. One keyboard/input-source
  transition was observed and then restored.
  [Current-hash inputd QEMU proof](proof-notes/2026-08-09-current-hash-inputd-qemu-proof.md)
- **Fresh inputd runtime verifier (QEMU):** a new copy-on-write guest run
  returned zero verifier failures for the installed inputd binary, COSMIC
  environment, target ownership, inputd/displayd health, and failed-unit
  state. This is installed-tuple runtime evidence; it does not claim hardware
  input or that the package was built from source commit `271bc2a`.
  [Fresh QEMU verifier proof](proof-notes/2026-08-12-qemu-inputd-feature-matrix-runtime.md)
- **Reviewed inputd candidate cold login (QEMU):** Voulage built the pinned
  `c658754` source as `regolith-inputd 0.4.1-2-1regolith-resolute`. The exact
  package was installed in a disposable overlay and survived a cold graphical
  login with the COSMIC target, inputd/displayd helpers, Sway keyboard/pointer
  inventory, and wrapper-owned COSMolith process present. The package and
  executable hashes are recorded. No physical touchpad is exposed by this
  guest, so touchpad reverse-sync remains open.
  [Reviewed inputd cold-login proof](proof-notes/2026-08-16-inputd-candidate-cold-login-proof.md)
- **Display observer and restore (QEMU):** the existing display harness changed
  `Virtual-1` from `1280x800 @ 74.994 Hz` to `1024x768 @ 60.004 Hz`, observed a
  Sway output event, and restored the original mode. This is single-output
  observer evidence only; physical hotplug, mixed DPI, and persistence for
  that observer-only path remain open. The newer exact COSMolith generated
  profile proof is recorded separately below.
  [Display observer proof](proof-notes/2026-08-12-qemu-display-observer-proof.md)
- **Displayd mode-selection candidate:** trace evidence identified stale
  Wayland mode selection. Candidate `8fa2832` passes its regression, Linux
  tests, and unsigned package build; its extracted binary rewrote the saved
  profile during a bounded QEMU run. System package installation and
  cold-reboot persistence remained open for that extracted candidate run; the
  later exact COSMolith package result is recorded separately.
  [Candidate proof](proof-notes/2026-08-12-displayd-mode-selection-fix.md)
  The isolated [Voulage model candidate](proof-notes/2026-08-12-voulage-displayd-candidate-model.md)
  pins the same source and reaches the real build before the interactive-sudo
  boundary; it is not release or QEMU package proof.
- **Inputd touchpad mapping coverage:** the frozen source already passes 43
  COSMIC-feature tests and 20 GNOME-feature tests, including deterministic
  touchpad command mappings and partial configurations. This is unit coverage;
  physical-device and live reverse-sync behavior remain open.
  [Touchpad coverage audit](proof-notes/2026-08-10-inputd-touchpad-coverage-audit.md)
- **Exact inputd package build/install:** the reviewed `66099f67` source built
  as `0.4.1-2-1regolith-resolute`, passed Lintian with exit `0`, and was
  installed and rolled back in the disposable QEMU guest with matching package
  and installed-binary hashes. The guest was at the greeter, so no daemon or
  graphical runtime claim follows.
  [Package install proof](proof-notes/2026-08-11-exact-inputd-package-install-rollback.md)
- **Live QEMU login and keyboard path:** a snapshot-backed cold login reached
  `cosmic-session` plus Sway with a live IPC socket. The exact reviewed inputd
  package was then installed and its user service restarted successfully; the
  package and installed-binary hashes matched the retained artifact. A single
  resolved `Mod4+Space` binding launched ilia and produced a visible launcher
  menu. This upgrades criteria 8 and 12 to partial evidence only; it does not
  prove the full retained-surface or keyboard matrix, hardware, native
  `cosmic-comp`, or reboot persistence.
  [Live-login/bindsym proof](proof-notes/2026-08-11-qemu-live-login-inputd-bindsym.md)
- **Retained closure packet QEMU check:** an older internally consistent
  six-package Resolute tuple installed with `dpkg -i` exit `0` and reached a
  fresh `cosmic-session`/Sway login. The relevant user COSMIC target and both
  helper services were active, GNOME was masked/inactive, and `dpkg --audit`
  was empty. This strengthens package/session closure evidence only; it does
  not stand in for the newer Aug 11 source tuple or close native display,
  hardware, signing, publication, or the remaining interaction matrices.
  [Retained-packet proof](proof-notes/2026-08-11-retained-closure-packet-qemu.md)
- **Clean-image audit boundary:** the retained images labelled as clean/fresh
  were independently checked before being used for proof. The retained
  clean/fresh/qualification images already contained Regolith and GNOME/Sway
  packages, so none supports a clean-base install claim. Their disposable
  overlays were shut down cleanly and the base images were not modified.
  [Clean-image audit](proof-notes/2026-08-11-clean-image-audit-boundary.md)
- **Package-audit regression gate:** session test commit
  [`a5db193`](https://github.com/Rahul-2k4/regolith-session/commit/a5db1934b3f603defc5706d3a8c0376b6d96352d)
  parses the Debian package stanzas, rejects direct GNOME bootstrap
  dependencies in `regolith-session-cosmic`, and preserves them in the legacy
  Sway/Flashback paths. The focused test, shell syntax check, and diff check
  passed. This is a source gate, not the complete transitive audit.
  [Package-audit test proof](proof-notes/2026-08-11-package-audit-regression-test.md)
- **Final target-split graphical integration:** the staged Resolute package
  tuple passed direct metadata audit and a disposable QEMU graphical login.
  The COSMIC target and both target-owned helpers were active, the GNOME target
  was inactive, `dpkg --audit` was empty, and the existing launcher/workspace
  bindings remained usable. A second fresh overlay reproduced the same result.
  This is an integration subgate; the full transitive APT closure is still not
  claimed complete.
  [Direct package audit and final tuple proof](proof-notes/2026-08-11-direct-session-package-audit.md)
  [Second cold-login proof](proof-notes/2026-08-11-final-target-split-second-cold-login.md)
- **Transitive GNOME dependency audit:** the exact staged package set was
  simulated with `--no-install-recommends` on Ubuntu 26.04 and Debian Trixie.
  Both resolved successfully and selected only `gnome-keyring`,
  `gnome-themes-extra`, and `gnome-themes-extra-data` as GNOME-related
  packages; no GNOME session manager, settings daemon, control center, Mutter,
  or Nautilus entered the graph. This was the pre-split audit; the candidate
  ownership split is recorded below. [Transitive audit](proof-notes/2026-08-11-transitive-gnome-audit.md)
- **Native Trixie model validation:** the personal Voulage branch adds the
  Trixie COSMIC package entries and a non-publishing CI check. The successful
  run parsed the model, validated both immutable refs, and resolved both refs
  from their source repositories. This is model/source-integrity evidence;
  it is not a package build or publication result.
  [Trixie model CI proof](proof-notes/2026-08-12-native-trixie-model-ci-proof.md)
- **Native Trixie binary build:** Voulage run `31533503633` completed source
  and binary package builds for `cosmic-session` and
  `cosmic-settings-daemon`, using the source-declared Rust 1.93.0 and 1.90.0
  toolchains. The exact unsigned evidence artifact IDs and digests are in the
  [binary-build proof](proof-notes/2026-08-12-native-trixie-binary-build-proof.md).
  This advances criterion 10, but signing, apt publication, and release
  acceptance remain open.
- **GNOME target ownership split:** candidate session source `641f796` (parent
  target split `cbd810f`) moves
  the inactive GNOME target files into `regolith-session-gnome-targets`, keeps
  the package out of the COSMIC dependency path, and preserves legacy Sway/
  Flashback dependencies and removes the direct Flashback `xorg` metapackage
  dependency. Source tests, manual Ubuntu binary packaging, fresh graph
  simulations, and old-common transition checks passed. The Voulage wrapper
  stopped at `sudo apt build-dep`/archive setup, while the manual package
  family build passed Lintian with warnings only. The three transitive GNOME
  resource packages remain documented, so criterion 9 stays Partial pending
  mentor/release and revised-runtime review.
  [Target split proof](proof-notes/2026-08-11-gnome-target-package-split.md)
- **Revised target split QEMU transition:** the Ubuntu Resolute candidate
  package set installed with `dpkg -i` exit `0` in a disposable overlay,
  survived a cold reboot, and returned with empty `dpkg --audit`. Both GNOME
  target files remained owned by `regolith-session-gnome-targets`, and common
  had no GNOME payload. The post-reboot check was outside a graphical user
  session, so this does not add a login or target-runtime claim.
  [QEMU transition proof](proof-notes/2026-08-11-gnome-target-split-qemu-transition.md)
- **Final target ownership transition:** session source
  [`831596f`](https://github.com/Rahul-2k4/regolith-session/commit/831596f8f054a6904b0846b6a899912c6c13d465)
  keeps unversioned `Replaces` for both predecessor owners. The Voulage-built
  Resolute package installed over the old Sway-owned file, configured the full
  session package family, survived cold reboot, and returned with empty
  `dpkg --audit`; target ownership and the inputd binary hash were unchanged.
  This closes package-transition integrity only. The post-reboot guest was
  outside a graphical session, and no hardware, signing, or publication claim
  follows.
  [Final QEMU transition proof](proof-notes/2026-08-11-gnome-target-transition-final-qemu.md)
- **Final graphical session proof:** the same final session source and
  current inputd routing source `271bc2a` plus the Resolute package family
  were installed in a disposable QEMU overlay and
  started through greetd IPC. `cosmic-session`, Sway, and inputd were running
  with `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`; the COSMIC target
  and both target-owned helpers were active, GNOME was inactive, and
  `dpkg --audit` was empty after the run. This is QEMU-only evidence; it does
  not claim hardware, native display mutation, signing, publication, or
  mentor acceptance.
  [Graphical-login proof](proof-notes/2026-08-11-final-session-graphical-login-qemu.md)
- **Current inputd package/reboot proof:** the earlier `e641b43` package/reboot
  proof remains valid for that source head. The newer routing source `271bc2a`
  builds through Voulage, passes its source tests, and is installed in the
  combined final graphical-login tuple. There is no isolated inputd-only
  runtime matrix for that head; do not merge those evidence scopes.
  [Earlier package proof](proof-notes/2026-08-11-current-inputd-package-qemu-proof.md)
  · [Routing proof](proof-notes/2026-08-11-inputd-keyboard-routing.md)
- **Clean target-distro resolution attempt:** disposable `debian:trixie` and
  `ubuntu:26.04` containers both completed `apt-get update` with exit `0`, but
  simulated installation of the staged package set returned exit `100` because
  the required Regolith/COSMIC runtime closure was unavailable. This is useful
  failure evidence, not clean-install proof; the exact unresolved package
  lists are recorded in the [container resolution note](proof-notes/2026-08-11-clean-container-package-resolution.md).
- **Clean target-distro closure and install:** after adding the signed Regolith
  archive and correcting the real `regolith-resource-loader` metadata defect,
  disposable Ubuntu 26.04 and Debian Trixie containers both resolved and
  installed the staged package set with exit `0`; `dpkg --audit` was empty in
  both. The combined session source also carries the required
  `Replaces: regolith-session-sway` transition metadata. This is clean package
  closure evidence, not a clean graphical-login claim. See the [positive
  closure proof](proof-notes/2026-08-11-clean-target-package-closure-install.md).
- **Current amd64 solver rerun:** the current staged tuple was independently
  simulated under `--platform linux/amd64` in Ubuntu 26.04 and Debian Trixie.
  Both APT updates and simulations returned `0`; only the documented
  `gnome-keyring` and GNOME theme packages survived the GNOME allowlist, with
  no GNOME session manager, settings daemon, control center, Mutter, or
  Nautilus. This is solver evidence only, not a new installation or release
  claim. [amd64 package simulation](proof-notes/2026-08-11-clean-container-amd64-package-simulation.md)
- **Current amd64 filesystem install:** the same tuple installed in disposable
  Ubuntu 26.04 and Debian Trixie containers with `APT_INSTALL_RC=0` and empty
  `dpkg --audit`. The Trixie run used local COSMIC packages retaining the
  `regolith-resolute` suffix, so this is staged install evidence rather than a
  canonical Trixie publication claim. [amd64 package install](proof-notes/2026-08-12-clean-container-amd64-package-install.md)
- **Lintian sequence for the target split:** the first candidate at
  [`cbd810f`](https://github.com/Rahul-2k4/regolith-session/commit/cbd810f68f2713be91f1a61cdd326cd128a857c5)
  failed standalone Lintian because it retained the direct `xorg` dependency;
  [`641f796`](https://github.com/Rahul-2k4/regolith-session/commit/641f796)
  removed that dependency, and the final [`831596f`](https://github.com/Rahul-2k4/regolith-session/commit/831596f8f054a6904b0846b6a899912c6c13d465)
  package passed Lintian with warnings only. The warnings and the exact
  sequence are retained in the linked package proof; this is not a claim of
  zero warnings.
- **Voulage session rebuild and cold reset (QEMU):** the reviewed
  `regolith-session` source at `7fb72a8d` built successfully through the local
  Voulage path with the Resolute package suffix. After a staged compatibility
  check, the rebuilt session packages installed cleanly as an upgrade and
  survived a cold reset into the COSMIC-backed Sway session. The COSMIC target,
  inputd/displayd helpers, failed-unit check, and `dpkg --audit` were healthy.
  This is not native `cosmic-comp` or release-publication proof; the package
  collision and Lintian findings are recorded in the note.
  [Voulage cold-reset proof](proof-notes/2026-08-11-voulage-session-7fb-cold-reset.md)
- **Voulage source-of-truth repin:** the dedicated contributor branch pins
  `regolith-session` to `831596f` and `regolith-inputd` to the reconciled
  `c658754`. The canonical branch hit the documented host sudo build-dep
  boundary; the reviewed local-build skip gate then produced the exact six
  session packages with retained hashes and Lintian warnings only.
  [Repin and package proof](proof-notes/2026-08-11-voulage-session-repin.md)
- **Session package ownership transition:** source commit
  [`b74dfe3`](https://github.com/Rahul-2k4/regolith-session/commit/b74dfe3d9a4b2dd848176d181f2d1f853115c5c8)
  adds the required `Replaces` relationship to the common package and passes
  its regression test. Voulage rebuilt the package with the approved Resolute
  suffix; a disposable transition install returned `0`, left `dpkg --audit`
  empty, and activated the user COSMIC target. The base already contained the
  older tuple, so this is transition proof rather than clean-from-empty-base
  installation proof. Lintian and publication remain open.
  [Package transition proof](proof-notes/2026-08-11-session-package-transition-proof.md)
- **Representative retained-surface matrix (QEMU):** the live session kept
  `i3status-rs`, launched `ilia` through `Mod4+Space`, and switched from
  workspace 1 to 2 and back through injected Sway bindings. This strengthens
  criteria 8 and 12 but leaves the complete binding matrix, multimedia keys,
  and hardware behavior open.
  [Retained-surface matrix](proof-notes/2026-08-11-retained-surface-keyboard-matrix.md)
- **Inputd robustness and packaging candidate:** source `cd1c2cd` guards empty
  Sway keyboard-layout metadata and passes 46 all-feature tests. Packaging
  commit `b380c9a` adds `regolith-inputd(8)` and DWARF data. Voulage model
  commit `4dc7de8` builds an unsigned Ubuntu Resolute amd64 package with
  SHA-256 `759f87dc908182359a17d3930bf67b0f4c3a188fe02e75bdc71f7bd9238ff193`.
  Direct Debian Lintian is clean; Voulage retains one same-day changelog-date
  warning. The candidate remains separate from the frozen installed tuple.
  The separate candidate verifier proof below covers target-owned service
  health after an isolated QEMU install. It does not turn this source/test
  note into runtime proof for `cd1c2cd`, and the candidate is still separate
  from the frozen `e32d049` source tuple pending mentor/release direction.
  [Empty-layout guard proof](proof-notes/2026-08-10-inputd-empty-layout-guard.md)
- **Candidate verifier runtime (QEMU):** the hardened verifier passed in
  qualification QEMU after a visible greeter login with the exact candidate
  package version and installed-binary hash. It proved COSMIC target selection,
  GNOME target exclusion, helper health, zero restarts, target dependency
  membership, and allowlisted process environment values. The guest proof
  intentionally excludes unrelated failed units and does not claim hardware or
  native compositor coverage.
  [Verifier QEMU proof](proof-notes/2026-08-10-inputd-candidate-verifier-qemu-runtime.md)
- **Inputd package artifact:** the exact unsigned package and its metadata are
  recorded in the [Voulage package proof](proof-notes/2026-08-10-inputd-voulage-package-proof.md).
- **Cosmolith source closure:** the personal fork now has structured watcher
  errors and deterministic COSMIC session detection. A clean local `cargo test`
  run passed with 14 tests and no failures. This is a source-level result on
  the build machine, not a hardware session result.
  [Cosmolith source closure](proof-notes/2026-08-09-cosmolith-source-closure.md)
- **Single-output persistence (QEMU):** fresh-login display profile
  reapplication passed on the Sway-backed QEMU path.
  [Display profile reapplication proof](proof-notes/2026-08-09-display-profile-reapply-fix.md)
- **Wayland display observer:** the frozen displayd source
  `rahul/displayd-kanshi-target-safe-20260809` at `817becd9` already contains
  and wires the `zwlr_output_manager_v1` observer for COSMIC, while retaining
  Sway IPC for compatibility and fallback. Single-output fresh-login
  persistence is proven (QEMU) in the frozen Sway-backed wrapper. The older
  `e8cc8e07` package note remains useful as direct observer evidence, but no
  repin is needed. The frozen source audit passes 73 locked tests and found no
  safe patch to transplant from the newer candidate. Native `cosmic-comp`,
  hotplug, mixed-DPI, and Settings-panel proof are still open.
  [Wayland observer proof](proof-notes/2026-08-04-cosmic-wayland-observer-qemu-proof.md)
  [Frozen source audit](proof-notes/2026-08-10-displayd-frozen-source-audit.md)
  · [Multi-output reconciliation test](proof-notes/2026-08-11-displayd-multi-output-reconciliation-test.md)
  · [Canonical inputd QEMU boundary](proof-notes/2026-08-11-canonical-inputd-qemu-session-boundary.md)
  The test-only branch is [`rahul/displayd-wayland-multi-output-test-20260812`](https://github.com/Rahul-2k4/regolith-displayd/tree/rahul/displayd-wayland-multi-output-test-20260812) at `3db213c`; it is not silently substituted for the frozen runtime tuple.
- **Displayd clean build:** Voulage clean-clone build `9c88f6fe` produced 12
  passing tests with 142 vendored crates. Lintian: non-clean, warnings remain.
  This artifact was **not** installed for the runtime checks below.
- **Displayd runtime (QEMU):** runtime claims are tied to the installed artifact
  `766a2a19`. A live `1024x768` recording restored to `1280x800` after one cold
  reboot in the QEMU guest.
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
- **Voulage changelog identity (QEMU):** isolated commit `db0ff7b` adds a tested
  maintainer-identity fallback so local Voulage builds do not inherit the
  builder hostname. The corrected branch rebuilt the Resolute COSMIC session
  package and the exact unsigned artifact passed an isolated QEMU install,
  visible login, target/helper checks, and rollback. A follow-up source
  candidate `bdb2b00` adds the COSMIC launcher manpage; its exact Voulage-built
  `regolith-session-cosmic` binary has the manpage payload and standalone
  Lintian-clean output. Sibling session packages still have unrelated legacy
  findings; signing and canonical publication are open.
  [Changelog identity proof](proof-notes/2026-08-10-voulage-changelog-identity-proof.md)
  [Rebuild and QEMU proof](proof-notes/2026-08-10-corrected-voulage-session-rebuild-qemu-proof.md)
  [COSMIC manpage proof](proof-notes/2026-08-10-session-manpage-voulage-proof.md)
- **Voulage builder parser (QEMU):** isolated commit `a8b0e0d` makes the
  documented `--arch` option work and produced the canonical Resolute amd64
  COSMIC session artifact. The exact package hash and Lintian scope are
  recorded in the
  [parser and build proof](proof-notes/2026-08-10-voulage-arch-parser-session-build.md).
  It also passed a QEMU cold-login and matched-baseline rollback check. Native
  display, hardware, signing, and publication remain outside this proof.
- **Idle ownership (QEMU):** the canonical WM-config ownership test passed, and
  the QEMU session confirmed the supported `swayidle` fallback, inactive
  `cosmic-idle`/GNOME target, and empty failed-unit list.
  [Idle ownership proof](proof-notes/2026-08-10-idle-ownership-cold-login.md)
- **Fallback lock (QEMU):** two real five-minute `swayidle -w timeout 300 gtklock`
  timeout-lock/unlock cycles passed on the Sway-backed QEMU path. The
  graphical session returned after each unlock; it reported `Type=wayland`,
  `Desktop=Regolith-Wayland`, `IdleHint=no`, and `LockedHint=no`. After each
  unlock, only `swayidle` remained and the failed user-unit audit was empty.
  Native cosmic-idle/logind semantics, logout/shutdown, hardware, and
  signing/publication remain open.
  [Current tuple fallback lock/unlock proof](proof-notes/2026-08-09-fallback-lock-unlock-current-tuple-qemu-proof.md)
- **OSD (QEMU):** a visible COSMIC volume overlay was produced in the
  Sway-backed COSMIC QEMU session.
  [COSMIC volume OSD proof](proof-notes/2026-08-09-cosmic-osd-volume.md)
- **Vendored/package installation:** clean Voulage builds with vendored
  dependencies and real disposable Trixie installation of the exact package
  tuple are recorded.
  [Clean Voulage rebuild](proof-notes/2026-08-09-clean-voulage-rebuild.md) ·
  [Real disposable Trixie install](proof-notes/2026-08-09-real-trixie-container-install.md)
- **Cosmolith package boundary (QEMU):** the exact `cosmolith` source was built
  through vendoring, offline compilation, Debian source-package generation, and
  binary package creation. The resulting `.deb` was installed in QEMU with
  matching SHA-256 values and an empty `dpkg --audit`. A fresh graphical QEMU
  login then observed the installed `/usr/bin/cosmolith` process with the
  expected COSMIC desktop selector and Wayland/Sway sockets; the target and
  helper health checks were clean.
  [Cosmolith fresh-session QEMU proof](proof-notes/2026-08-09-cosmolith-fresh-session-qemu-proof.md)
- **Runtime-owned helper teardown (QEMU):** the reviewed Sway-backed wrapper
  stops the Regolith-owned compositor, `cosmolith`, helper process groups, and
  COSMIC targets during the tested Sway-exit path. The exact
  `cosmic-session` parent and display-manager-owned logout semantics remain
  separate open boundaries. The latest managed-logout attempt could not select
  a stable local logind session, as recorded in the [managed logout harness
  boundary](proof-notes/2026-08-17-managed-logout-harness-boundary.md).
  Earlier Sway-exit captures remain historical context; see the [parent
  lifecycle diagnostic](proof-notes/2026-08-11-parent-lifecycle-diagnostic-qemu-proof.md).
- **Physical hardware boundary:** a read-only host audit found a physical
  touchpad but no active Regolith/COSMIC session and only the internal display
  connected. No host state was changed; physical touchpad, hotplug, and
  multi-display behavior remain unverified.
  [Hardware capability boundary](proof-notes/2026-08-10-physical-hardware-capability-boundary.md)

- **Full apt-install DoD closure (Ubuntu 26.04):** `apt-get install -y
  regolith-session-cosmic` was run against a clean `ubuntu:26.04` Docker
  container using a local pool of every needed `.deb` plus Regolith's own
  upstream apt repo as a real source, with no manual overrides and no
  `--force`. Result: `EXIT_CODE=0`, confirmed by a full log grep for `E:`
  errors and independently re-verified twice in fresh containers. This
  closed 23 COSMIC/Regolith components built and verified through Voulage
  for the first time (`cosmic-session`, `cosmic-comp`,
  `cosmic-settings-daemon`, `cosmic-osd`, `cosmic-idle`, `cosmic-randr`,
  `cosmic-app-library`, `cosmic-applets`, `cosmic-icons`, `cosmic-launcher`,
  `cosmic-panel`, `cosmic-screenshot`, `cosmic-files`, `cosmic-greeter`,
  `cosmic-notifications`, `pop-fonts`, `regolith-look-default`,
  `xdg-desktop-portal-cosmic`, `pop-launcher`, `pop-icon-theme`, and
  `sway-regolith`), plus two real bugs found and fixed: `cosmic-comp` built
  against a stale build-host `libdisplay-info1` instead of the target's real
  SONAME, fixed inside a disposable container rather than touching host
  packages; and `cosmic-settings-daemon`'s hard `Depends` on
  `adw-gtk3`/`pop-sound-theme` (neither package exists anywhere), moved to
  `Recommends`. Debian trixie has one remaining real gap: `sway-regolith`
  needs `libwlroots-0.19-dev`, which trixie's own archives only carry at
  `0.18` — a distro-version difference, not required here since the
  proposal's DoD names either Trixie or Ubuntu 26.04. This is a Phase 1
  packaging result, not one of the 12 runtime/UX criteria; it strengthens
  criterion 10's evidence but that criterion remains **Partial** since the
  repository used a local demonstration signing key and was not published to
  Regolith's distribution channel.
  [Full apt-install DoD closure proof](proof-notes/2026-08-14-full-apt-install-dod-closure.md)
- **Signed local-repository install (Ubuntu 26.04):** the full
  `regolith-session-cosmic` dependency closure was installed twice in a fresh
  `ubuntu:26.04` container from a local GPG-signed repository using
  `signed-by`, with zero trust warnings and independent `dpkg -l` confirmation.
  This is stronger packaging evidence, but it is not publication to Regolith's
  archive and does not close criterion 10.
  [Signed repository proof](proof-notes/2026-08-15-signed-repository-apt-install-proof.md)
  The current public packet does not include the complete historical pool or a
  full-closure replay script; see the [reproduction-input audit](proof-notes/2026-08-16-signed-closure-reproduction-input-audit.md).
- **Voulage wrapper build closure for displayd:** the personal wrapper branch
  now passes nightly Cargo through `debuild --prepend-path` for the lockfile-v4
  source and produces a real unsigned
  `regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb`. The exact source,
  wrapper commit, package hash, and vendored hashes are recorded in the
  [wrapper build proof](proof-notes/2026-08-15-voulage-displayd-wrapper-build-proof.md).
  This is not archive publication or QEMU installation proof.
- **Cosmolith generated-config.d persistence (source/unit):** the
  proposal-committed `generated-config.d` persistence path, previously
  unimplemented, was added TDD-first with 4 new tests (red, then green) and
  a clean `cargo fmt --check`. Keyboard layout/variant persistence, which
  feeds criterion 4, was traced and confirmed to already flow through the
  same mechanism, verified with 2 further tests rather than claimed as a
  separate fix. This is source/unit-test evidence only: a live QEMU proof
  was attempted and confirmed the known-good disk boots under current
  tooling, but could not complete login because the guest password is not
  stored anywhere in this repo and was not bypassed. Criterion 4 stays `Not
  met as written` and criterion 7 stays `Partial`.
  [Cosmolith persistence proof](proof-notes/2026-08-14-cosmolith-generated-config-persistence.md)
- **Exact COSMolith package display runtime (QEMU):** the Voulage-built
  `cosmolith 0.1.0-1-1regolith-resolute` package was installed in the
  disposable session. A live `cosmic-randr` change updated the generated
  `Virtual-1` profile, and after a cold reset the wrapper-owned COSMolith
  process relaunched after compositor readiness; Sway still reported
  `1024x768@60.004Hz`. The package and executable hashes are recorded, along
  with the required Wayland environment and startup wait. This remains
  single-output QEMU evidence and does not close native compositor, hardware,
  multi-display, or publication boundaries.
  [Exact COSMolith display runtime proof](proof-notes/2026-08-16-cosmolith-exact-package-display-runtime.md)
- The older displayd-only storage/apply boundary remains separately recorded;
  it does not contradict the COSMolith generated-Sway-config result above.
- **`cosmic-session` parent-lifecycle reverification:** the previously
  reported `swaymsg exit` parent-lifecycle fix was found already applied
  from a prior session and was independently reverified this session
  (`cargo fmt --check`, tests, push) rather than re-claimed as new work.

## Open boundaries

- **Final technical article:** the reconciled integration article is available
  at [`docs/ARTICLE.md`](docs/ARTICLE.md). It uses the corrected `62-68%`
  strict estimate and keeps QEMU, native-compositor, hardware, signing, and
  mentor-review boundaries explicit.

- Signing, canonical publication, and final release disposition remain open.

- Settings panel display interaction, including its reproducible renderer
  crash.
- Physical or equivalent display matrix: multi-display, hotplug, and mixed
  DPI behavior remain unverified.
- **Inputd touchpad reverse-sync (open):** implemented and unit-tested
  (`46` COSMIC-feature / `49` all-feature tests), packaged, and install-verified
  in a QEMU guest. The code path has never executed: the guest exposes no
  `type:touchpad` device. Physical reverse-sync remains unproven.
  [Touchpad reverse-sync note](proof-notes/2026-08-10-inputd-touchpad-reverse-sync.md)
- Touchpad coverage, input reverse-sync runtime behavior, and a fresh visible
  GNOME desktop selection remain open.
- The inputd candidate runtime note is QEMU-only; it does not claim hardware,
  signing/release, or an upstream merge.
- Full logout and shutdown lifecycle coverage remains open. Reboot ordering and
  two fallback idle timeout-lock/unlock cycles are proven in QEMU; native
  cosmic-idle/logind semantics and hardware remain open. The patched
  `cosmic-session` candidate now closes the direct Sway-exit parent process in
  the disposable proof; the display-manager-owned logout path remains
  unproven.
- **Managed logout:** the latest disposable attempt reached a clean COSMIC
  login and healthy target/helpers, but an SSH-created transient logind session
  prevented the harness from issuing a valid termination request. Managed
  logout and shutdown remain unproven; see the [harness boundary](proof-notes/2026-08-17-managed-logout-harness-boundary.md).
- Signing, release readiness/publication, and final mentor review remain open.
- Signing, the full display matrix, native Settings validation, and hardware
  validation remain open for the newer displayd artifact.

[GNOME coexistence boundary](proof-notes/2026-08-09-gnome-regression-boundary.md) ·
[Inputd reverse-sync tests](proof-notes/2026-08-09-inputd-reverse-sync-tests.md) ·
[Live QEMU runtime boundary](proof-notes/2026-08-09-live-qemu-runtime-recheck.md) ·
[Lintian release audit](proof-notes/2026-08-09-lintian-release-audit.md) ·
[Sequential cold-login proof](proof-notes/2026-08-09-final-tuple-sequential-cold-login-proof.md) ·
[Fallback lock/unlock proof](proof-notes/2026-08-09-fallback-lock-unlock-current-tuple-qemu-proof.md) ·
[Displayd runtime artifact proof](proof-notes/2026-08-09-displayd-runtime-artifact-proof.md)

## Upstream contribution status

| PR / Issue | Repo | State |
|---|---|---|
| [PR #15](https://github.com/sandptel/cosmolith/pull/15) — bootstrap startup xkb events | `sandptel/cosmolith` | **Merged and approved** 2026-04-21 (`7d47b8b6`) |
| [PR #13](https://github.com/sandptel/cosmolith/pull/13) — earlier over-scoped version | `sandptel/cosmolith` | Closed, superseded by #15 |
| [PR #17](https://github.com/sandptel/cosmolith/pull/17) — startup XKB event tests | `sandptel/cosmolith` | **Open**, mergeable. 1 file, +55/-0. Restores the test coverage dropped by #15's squash merge |
| [PR #18](https://github.com/sandptel/cosmolith/pull/18) — deterministic session detection (`Fixes #1`) | `sandptel/cosmolith` | **Open**, mergeable. 1 file, +117/-8 |
| [PR #19](https://github.com/sandptel/cosmolith/pull/19) — structured watcher errors (`Fixes #2`) | `sandptel/cosmolith` | **Open**, mergeable. 5 files, +288/-48. Stacked on #18 |
| Issue #1 — session detection | `sandptel/cosmolith` | Open upstream; addressed by PR #18 |
| Issue #2 — central error enum | `sandptel/cosmolith` | Open upstream; addressed by PR #19 |

**Mentor decision, 2026-08-11.** The 2026-06-19 hold on upstream PRs was lifted
for cosmolith specifically: cosmolith PRs are fine because it is a COSMIC-specific
component, while COSMIC code should not enter common session packages until it is
ready. Recorded in `07_Decisions/2026-08-11-mentor-cosmolith-prs-ok.md`. The three
PRs above were opened under that direction.

**Suggested merge order:** #17 (independent) → #18 → #19. PR #19 is stacked on
#18, so its diff against `main` includes #18's commits until #18 merges. This is
disclosed in #19's description.

**Verification, 2026-08-11 (no upstream CI exists on this repo).** Each PR head
was checked out from `sandptel/cosmolith` and built independently:

| PR | `cargo test` |
|---|---|
| #17 | `2 passed; 0 failed` |
| #18 | `3 passed; 0 failed` |
| #19 | `5 passed; 0 failed` |

Counts are cumulative because #18 and #19 are stacked. `cargo fmt --check` is red
on all three, but it is **already red on upstream `main` with 73 diffs** — the
crate is `edition = "2024"` with no `rustfmt.toml` or `rust-toolchain.toml`, and
these branches follow the surrounding files' existing import convention rather
than reformatting unrelated code.

No PR has been opened against `regolith-linux/*`. All session, inputd, displayd,
and Voulage work remains on personal fork branches, consistent with the mentor's
boundary that COSMIC code should not land in common session packages yet. The open
mentor question is narrower: whether moving **GNOME** unit ownership into
`regolith-session-common` (see the flashback packaging fix) is acceptable under
that rule, since those are GNOME units rather than COSMIC code.

## Code inventory

One canonical personal-fork head per component. Every commit link was checked
HTTP 200 on 2026-08-10. Heads prefer the Track C reconciled tips where they
supersede earlier frozen tuple pins.

| Repo | Branch | Commit | What it does | Tests | Upstream status |
|---|---|---|---|---|---|
| `regolith-inputd` | [`rahul/inputd-cosmic-canonical-20260812`](https://github.com/Rahul-2k4/regolith-inputd/tree/rahul/inputd-cosmic-canonical-20260812) | [`c658754`](https://github.com/Rahul-2k4/regolith-inputd/commit/c658754ec10ac75422cba8e1c3517bba6075795f) | Reconciled canonical head: COSMIC touchpad reverse-sync fix plus keyboard-to-input-source event routing on one lineage, superseding the earlier `271bc2a`/`b380c9a` fork split | `cargo fmt --check` clean; COSMIC-feature 48 tests; all-feature 51 tests; this is the exact ref Voulage's package model pins | Personal fork branch; no `regolith-linux` PR |
| `regolith-session` | [`rahul/gnome-target-transition-replaces-20260811`](https://github.com/Rahul-2k4/regolith-session/tree/rahul/gnome-target-transition-replaces-20260811) | [`831596f`](https://github.com/Rahul-2k4/regolith-session/commit/831596f8f054a6904b0846b6a899912c6c13d465) | Corrects the archive-provided loader dependency, moves GNOME target payload into a GNOME-only package, removes the Flashback `xorg` metapackage dependency, and adds the final unversioned ownership handoff | 9 package/systemd tests, syntax, diff checks, manual Ubuntu binary build, Voulage Resolute build, Lintian exit `0` with warnings only, package transition, cold reboot, and graphical QEMU login proof | Fork only; no `regolith-linux` PR |
| `regolith-displayd` | [`rahul/displayd-wayland-multi-output-reconcile-20260812`](https://github.com/Rahul-2k4/regolith-displayd/tree/rahul/displayd-wayland-multi-output-reconcile-20260812) | [`e4b2168`](https://github.com/Rahul-2k4/regolith-displayd/commit/e4b2168) | Frozen target-safe displayd plus reviewed Wayland output-head/mode removal reconciliation tests | `cargo fmt --check`, `git diff --check`, 51 library tests, and 25 binary-target tests passed; existing `num_derive` warning remains | Personal fork branch; test-only extension, not the frozen package tuple |
| `cosmolith` | [`fix/startup-xkb-events-atomic`](https://github.com/Rahul-2k4/cosmolith/tree/fix/startup-xkb-events-atomic) | [`8bf1960`](https://github.com/Rahul-2k4/cosmolith/commit/8bf1960) | Startup XKB events, deterministic session/error work, and reviewed Sway helper tests | Linux `cargo test --lib`: 10 passed; `git diff --check` clean; existing branch-wide `cargo fmt --check` differences remain documented | Personal fork branch; PRs #17, #18, and #19 remain mentor-authorized and open; no merge claimed |
| `voulage` | [`main`](https://github.com/Rahul-2k4/voulage/tree/main) | [`02d5d49`](https://github.com/Rahul-2k4/voulage/commit/02d5d49f) | Canonical package model on the default branch: pins `regolith-session` to `831596f` and `regolith-inputd` to `c658754`; includes the opt-in no-APT local-build gate (`49f26e1`) used to build the corrected session transition, with default apt setup unchanged | Source-pin, opt-in/default apt-gate, syntax, JSON, diff checks, and Ubuntu/Trixie binary builds passed | Personal fork only; no upstream merge |
| `voulage` (branch, not yet on `main`) | `repin-settings-daemon-theme-fix-20260814` | `5006cd1b` (repin, on top of `reconcile-all-cosmic-pins-20260812` at `6e3f1117`) | Pins the full 23-component `cosmic-*`/`pop-*`/`sway-regolith` model used for tonight's apt-install closure, plus the `cosmic-settings-daemon` Depends-to-Recommends repin | 23 components independently sha256-verified; `git ls-remote` confirms both branches pushed | Personal fork branch; not reconciled into `main` yet |
| `cosmolith` | [`fix/startup-xkb-events-atomic`](https://github.com/Rahul-2k4/cosmolith/tree/fix/startup-xkb-events-atomic) | [`8bf1960`](https://github.com/Rahul-2k4/cosmolith/commit/8bf1960) | Startup XKB events, deterministic session/error work, and reviewed Sway helper tests | Linux `cargo test --lib`: 10 passed; `git diff --check` clean; existing branch-wide `cargo fmt --check` differences remain documented | Personal fork branch; PRs #17, #18, and #19 remain mentor-authorized and open; no merge claimed |
| `cosmolith` (separate branch, packaging lineage) | `rahul/generated-config-persistence-20260814` | `4134034c` (base `pkg/cosmolith-voulage-20260809` at `70bb1bd`) | Adds `generated-config.d` write-through persistence for Sway input directives; keyboard layout/variant confirmed to reuse the same path | 4 new tests red-then-green, plus 2 targeted keyboard-path tests; `cargo fmt --check` clean; `git ls-remote` confirms push | Personal fork branch; separate lineage from the PR #17/18/19 branch above, not yet reconciled with it |
| `regolith-wm-config` | `rahul/cosmic-kanshi-owner-wm-config-resource-fallbacks-20260808` | [`10225c05`](https://github.com/Rahul-2k4/regolith-wm-config/commit/10225c056ee3ae15ab5745aba5a86ba611801ed5) | Historical COSMIC Kanshi ownership candidate plus safe Sway resource fallbacks; superseded for display persistence by displayd's Wayland observer and the GNOME-only Kanshi correction | Source ownership test and earlier QEMU result are historical; they are not current COSMIC Kanshi ownership proof | Fork only; not the current display-persistence tuple |

The latest displayd target-contract correction is on the personal fork branch
[`rahul/displayd-wayland-description-persistence-20260815`](https://github.com/Rahul-2k4/regolith-displayd/tree/rahul/displayd-wayland-description-persistence-20260815)
at [`87c2b67`](https://github.com/Rahul-2k4/regolith-displayd/commit/87c2b677cdd8b580998c4210e1bb73a572c5785d). It keeps Kanshi GNOME-only and
leaves the COSMIC Wayland observer in `regolith-displayd`; focused metadata
tests pass. This is a review candidate, not yet the frozen runtime package
tuple and not an upstream PR.

The final corrected source is pinned in the isolated Voulage branch
[`chore/repin-displayd-manpages-manifest-294b219`](https://github.com/Rahul-2k4/voulage/tree/chore/repin-displayd-manpages-manifest-294b219)
at [`5b4ee085`](https://github.com/Rahul-2k4/voulage/commit/5b4ee085).
The Ubuntu Resolute build produced
`regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb` with SHA-256
`ae5249b164cae2c65499b7b38b31bdea050bfe28f7ab753e0233e9a4dde1d3ad`.
See the [final Voulage package proof](proof-notes/2026-08-16-voulage-displayd-final-package-proof.md).
This is an unsigned package artifact; it does not claim a fresh QEMU install
or canonical Regolith publication.

The [final displayd QEMU runtime proof](proof-notes/2026-08-16-final-displayd-qemu-runtime-proof.md)
then installed this exact package in a disposable overlay and reached a cold
Regolith COSMIC login. The target, displayd, inputd, and COSMIC idle helper
were active with zero exit status; Kanshi was inactive under COSMIC, and Sway
IPC reported `Virtual-1`. This remains QEMU-only and single-output evidence.

## Next steps

### Immediately actionable by a maintainer

- Review and merge cosmolith PRs #17, #18, and #19 in order: #17, then #18,
  then the stacked #19. They are open and mergeable; no merge is claimed here.
- Land the Voulage COSMIC package-model entries on upstream
  `regolith-linux/voulage` (personal fork `main` already carries them).
- Sign and publish the unsigned Resolute amd64 package tuple once a first
  publication target is agreed.

### Needs hardware

- Multi-display / hotplug / mixed-DPI matrix (one physical panel available
  today; QEMU is single-output for these claims).
- Physical touchpad reverse-sync execution (QEMU exposes no `type:touchpad`).
- Media-key OSD delivery (QEMU cannot inject multimedia keys).

### Needs upstream

- `cosmic-settings` Resolution-selector renderer crash under both Vulkan and
  GL.
- Native `cosmic-randr` mutation that currently returns success without effect
  on the Sway-backed path.
- Native `cosmic-comp` session and native cosmic-idle/logind semantics as
  Regolith-wrapper validation (separate from the existing native-comp QEMU
  exploration note).

### Post-GSoC maintenance

Per the accepted proposal: about five hours per week for six months after the
program — triage mentor/reviewer follow-ups, keep fork branches rebaseable,
and finish the maintainer-actionable items above as direction arrives.

## Claim boundary

The wrapper and target-ownership result is QEMU proof. Native `cosmic-comp`
runtime has a separate QEMU proof, but it is not Regolith-wrapper validation:
[native compositor proof](proof-notes/2026-08-09-native-cosmic-comp-qemu-proof.md).
No hardware claim is included here. Upstream status is limited to the table
above; no `regolith-linux/*` PR or Regolith `main` merge is claimed.
