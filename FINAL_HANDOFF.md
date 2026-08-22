# Final GSoC Handoff

Project: **Build a COSMIC-based Wayland Session for Regolith**

Public proof bundle: [main branch](https://github.com/Rahul-2k4/regolith-cosmic-gsoc-proof/tree/main)

## Current source checkpoint — 2026-08-23

The displayd COSMIC apply path is now package/runtime exercised as well:
commit `48025e3` passes 66 offline library tests, and the exact unsigned
package hash is
`4d410cc022ecdcd497ce48d94e05ba4464dacddb75ea15dd57d033334ec4e601`.
The installed service stayed active in the disposable COSMIC QEMU tuple and
verify/apply `ApplyMonitorsConfig` calls returned code 0. This is headless
runtime proof only; native mode mutation, hardware, and multi-display remain
separate.

Displayd proof: [exact QEMU package/runtime check](proof-notes/2026-08-23-displayd-cosmic-wayland-apply-qemu.md).

The reconciled `regolith-inputd` branch currently contains vendored offline
build wiring in `e3fbd5c`, keyboard/input-source reverse synchronization in
`b07ea315`, and pointer reverse synchronization in `e8fce66`. The exact
unsigned package is
`regolith-inputd_0.4.1-2-1regolith-resolute_e8fce66_amd64.deb`, SHA-256
`650bd6f38bf67a08e140fa566aff4e7c63b2a41fc2cc60b04aada670a420823b`.

Verification from the project host:

```text
CARGO_NET_OFFLINE=true cargo test --all-features --offline   55 passed
cargo fmt --check                                          PASS
git diff --check                                            PASS
CARGO_NET_OFFLINE=true VENDOR=1 dpkg-buildpackage -us -uc -b PASS
```

The source-level pointer reverse-sync slice is now complete and preserves
unrelated COSMIC input fields. The strict proposal ledger remains **5/12 fully
met, QEMU-only**. A fresh reboot of the exact tuple now keeps Sway, COSMIC,
inputd, and displayd alive with active COSMIC targets, persistent Sway IPC, one
headless output, no failed user units, and clean `dpkg --audit`. This is
headless/pixman QEMU proof only, not native-GPU or hardware proof.

Source proof: [inputd pointer reverse-sync checkpoint](proof-notes/2026-08-23-inputd-pointer-reverse-sync-source.md).
QEMU package proof: [install checkpoint](proof-notes/2026-08-23-inputd-pointer-qemu-package-install.md).
Final cold-login proof: [exact-package QEMU session](proof-notes/2026-08-23-inputd-cosmic-cold-login-final.md).

## Latest update - 2026-08-21

The current public ledger is still **5 of 12**, QEMU-only.

The [combined three-fix verification boot](proof-notes/2026-08-21-combined-three-fix-verification-qemu.md)
is the current package-audit result. The tested COSMIC session path had no
GNOME session or bootstrap packages, zero failed user units, and clean
`dpkg --audit` on the same verification boot. For the tested QEMU scope, that
closes the package-audit criterion.

The [displayd real apply and persistence proof](proof-notes/2026-08-21-displayd-real-apply-and-persistence-qemu.md)
is the current display result. It proved real live display changes plus cold
reboot persistence for resolution and scale. It also found that refresh rate
persisted wrong, so the broad settings-persist criterion is `Partial`, not
`Met`.

The earlier 2026-08-17 section below is kept as a dated stage result.

## Latest update - 2026-08-17

The [fresh COSMolith input/display proof](proof-notes/2026-08-17-fresh-cosmolith-input-display-persistence-qemu.md)
adds a verified live and second-cold-reboot QEMU result: French/AZERTY,
repeat `540/31`, and `1024x768` survived with COSMIC target/inputd/displayd
active and the GNOME target inactive. That was the keyboard-side persistence
result at the time. Later Aug 21 display testing found the refresh-rate bug
noted above, so this section is historical rather than current-ledger status.

The [exact session-package QEMU proof](proof-notes/2026-08-17-exact-session-package-qemu-criterion-9.md)
adds a fresh overlay install, reboot, greetd COSMIC login, active COSMIC
target/helpers, inactive GNOME target, and clean `dpkg --audit`. It strengthens
Criterion 9 but does not replace the clean archive or complete survivor audit.

The [clean COSMIC-only survivor audit](proof-notes/2026-08-17-clean-cosmic-only-install-survivor-audit.md)
also installs only `regolith-session-cosmic` in a fresh Ubuntu 26.04
container. That dated run found four GNOME-related transitive packages. The
later August 21 combined verification supersedes its status wording and closes
Criterion 9 for the tested QEMU scope; the survivor note remains historical
evidence, not the current ledger.

The [managed logout harness boundary](proof-notes/2026-08-17-managed-logout-harness-boundary.md)
records the latest lifecycle attempt. The guest reached a clean COSMIC login
with the target and helpers active, but an SSH-created transient logind session
prevented the harness from selecting a stable local session for termination.
Managed logout, shutdown, and native idle semantics remain unproven.

## Start here

1. Read [`WORK_PRODUCT.md`](WORK_PRODUCT.md) for the 12 proposal criteria.
2. Read [`ARCHITECTURE.md`](ARCHITECTURE.md) for component boundaries, data
   flow, and design decisions.
3. Read [`docs/ARTICLE.md`](docs/ARTICLE.md) for the reconciled engineering
   narrative.
4. Read the [install guide](docs/INSTALL.md), [build-dependency matrix](docs/BUILD_DEP_MATRIX.md),
   and [known limitations](docs/KNOWN_LIMITATIONS.md).
5. Use the proof notes linked from those documents for command-level evidence.

The native Trixie work has separate [model CI](proof-notes/2026-08-12-native-trixie-model-ci-proof.md)
and [binary-build](proof-notes/2026-08-12-native-trixie-binary-build-proof.md)
proof notes. The binary run produced unsigned `.deb` evidence for both COSMIC
packages; it does not claim signing, apt publication, or release acceptance.

The latest [signed local-repository proof](proof-notes/2026-08-15-signed-repository-apt-install-proof.md)
shows the complete `regolith-session-cosmic` install resolving twice in a fresh
Ubuntu 26.04 container with `signed-by` and no trust warnings. This remains a
local demonstration repository, not Regolith archive publication. Canonical
signing, publication, and maintainer acceptance remain open.
The [reproduction-input audit](proof-notes/2026-08-16-signed-closure-reproduction-input-audit.md)
records that the current public packet does not contain the complete historical
pool or a full-closure replay script. A separate fresh local-pool result is now
recorded in the [2026-08-17 Ubuntu 26.04 closure proof](proof-notes/2026-08-17-ubuntu-resolute-local-pool-closure.md);
it is a verified result from the preserved project-laptop artifacts, not a
claim that the public repository alone can reproduce the entire pool.

The personal [Voulage displayd wrapper proof](proof-notes/2026-08-15-voulage-displayd-wrapper-build-proof.md)
also records a real unsigned `regolith-displayd_0.3.4-1-1regolith-resolute`
package produced through the wrapper after the Cargo.lock v4 fix. The exact
package was installed in the combined [QEMU proof](proof-notes/2026-08-15-combined-displayd-package-qemu-proof.md);
it is not a published archive artifact.

The final target-ownership and packaging result is recorded in the [final
displayd Voulage package proof](proof-notes/2026-08-16-voulage-displayd-final-package-proof.md).
It pins source `294b219` through Voulage commit `5b4ee085`, installs both
manpages, keeps Kanshi GNOME-only, and records the exact package hash. This
package proof is build evidence; the exact artifact was later installed in a
disposable QEMU overlay, as recorded in the final QEMU runtime proof below.
The earlier combined proof remains historical evidence for the pre-correction
runtime tuple.

The [cosmolith cold-reboot persistence proof](proof-notes/2026-08-15-cosmolith-cold-reboot-persistence.md)
records the current `cosmolith` and `regolith-inputd` package hashes, a
generated Sway configuration round trip, and a fresh graphical QEMU login
after reboot. The result covers one keyboard setting and remains QEMU-only.

The newer [exact COSMolith display-runtime proof](proof-notes/2026-08-16-cosmolith-exact-package-display-runtime.md)
uses the corrected COSMolith source commit `cd1cbb0` and the exact Voulage
package. A live `cosmic-randr` mode change was followed by a cold reset and
graphical login; the wrapper restarted COSMolith and Sway reported the saved
`Virtual-1` mode. This is single-output, QEMU, Sway-backed evidence. It does
not claim native `cosmic-comp`, hardware, or multi-display coverage.

The matching [inputd cold-login proof](proof-notes/2026-08-16-inputd-candidate-cold-login-proof.md)
uses source pin `c658754` and the reviewed Resolute package. It verifies the
COSMIC target, helper units, inputd process, COSMolith process, and Sway
keyboard/pointer inventory after a cold login. The QEMU guest exposes no
physical touchpad.

The COSMIC-specific cosmolith branch also has a [Sway helper test
proof](proof-notes/2026-08-12-cosmolith-sway-helper-tests.md). Its fresh Linux
clone passed all 10 library tests; the note keeps the existing formatting and
live-IPC limitations explicit.

The displayd branch also has a [Wayland multi-output reconciliation
proof](proof-notes/2026-08-12-displayd-wayland-multi-output-reconciliation.md).
The isolated source-test branch passed 51 library and 25 binary-target tests;
it does not claim physical hotplug or mixed-DPI runtime coverage.

The inputd branch also has a [feature-matrix verification
proof](proof-notes/2026-08-12-inputd-feature-matrix-linux.md). The Linux laptop
checkout at source `271bc2a` passed 50 all-feature tests, 47 COSMIC-only tests,
and 23 GNOME-only tests, with formatting and diff checks clean. This confirms
the backend feature split at source level; it does not replace the QEMU runtime
proof or close physical input coverage.

The [criterion 9 exact repin audit](proof-notes/2026-08-16-criterion-9-session-repin-audit.md)
rechecks source `831596f`, Voulage model `5b11b055`, six package hashes, and
GNOME/COSMIC target ownership. It keeps the exact-packet closure and matching
graphical-guest limitations explicit; it does not claim a Resolute graphical
login from the available Noble guest.

The fresh [QEMU inputd verifier proof](proof-notes/2026-08-12-qemu-inputd-feature-matrix-runtime.md)
returned zero failures for the installed binary, COSMIC environment, target
ownership, inputd/displayd health, and failed-unit state. It is installed-tuple
runtime evidence and does not claim hardware input or exact-commit package
rebuild provenance.

The [display observer proof](proof-notes/2026-08-12-qemu-display-observer-proof.md)
records a single-output `cosmic-randr` mode change, a Sway output event, and
successful restoration of the original mode. It does not claim physical
hotplug, mixed-DPI, multiple-display, reboot-persistence, or native compositor
coverage.

The [display harness discovery proof](proof-notes/2026-08-12-display-harness-session-discovery.md)
records the repaired runtime discovery path and a live rerun of the same
single-output observer. It keeps the same reboot-persistence and hardware
boundaries.

The [displayd mode-selection candidate](proof-notes/2026-08-12-displayd-mode-selection-fix.md)
records the focused regression, source fix, full Linux tests, unsigned package
build, and a bounded extracted-binary QEMU run that rewrote the saved display
profile. The candidate remains on the personal fork; system package
installation, cold-reboot persistence, and mentor review remain open.
Its isolated [Voulage candidate model](proof-notes/2026-08-12-voulage-displayd-candidate-model.md)
passes model checks and reaches the real build before the known interactive-
sudo boundary; it is not a release or QEMU package proof.

## Reproduce the latest verified QEMU result

The latest exact session-package result is recorded in the [Aug 17 QEMU
proof](proof-notes/2026-08-17-exact-session-package-qemu-criterion-9.md). It
used a copy-on-write overlay, installed the exact Resolute session tuple,
rebooted, and reached a COSMIC user session through greetd IPC. The earlier
Aug 11 proof remains a historical baseline for the same runtime contract.

The result verified:

- `cosmic-session`, Sway, and `regolith-inputd` running;
- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`;
- live Wayland and Sway IPC;
- active `regolith-cosmic.target`;
- active target-owned inputd and displayd units;
- inactive `regolith-gnome.target`;
- empty `dpkg --audit`.

The current package tuple also passes the fresh Ubuntu 26.04 local-pool
transaction with an empty `dpkg --audit`; see the [Aug 17 closure
proof](proof-notes/2026-08-17-ubuntu-resolute-local-pool-closure.md). The older
Debian Trixie run uses local COSMIC packages with a Resolute suffix, so it is
staged install evidence rather than canonical Trixie publication proof.

Representative keyboard evidence is in the [launcher binding
proof](proof-notes/2026-08-11-qemu-launcher-binding-proof.md): QEMU HMP
`meta_l-spc` launched `ilia`, while `meta_l-2` and `meta_l-1` switched
workspaces `1 -> 2 -> 1`.

The same final-tuple run also exercised controlled parent teardown. After
Sway exited, the wrapper reported `PARENT_EXIT_PASS` and found no surviving
`cosmic-session` or `dbus-run-session` parent. See the [parent-exit proof](proof-notes/2026-08-12-final-tuple-parent-exit-proof.md).
This does not replace full display-manager logout/shutdown or native logind
proof.

The current combined package tuple was also checked after a cold graphical
login. The exact displayd, inputd, and cosmolith packages were installed
together; both helper units were active, the three daemons were running, and
Sway IPC reported the QEMU output and input devices. See the [combined displayd
package proof](proof-notes/2026-08-15-combined-displayd-package-qemu-proof.md).

The wrapper-owned cosmolith startup path has an earlier real-greeter proof in
[the corrected Voulage model note](proof-notes/2026-08-10-corrected-voulage-model-real-greeter.md).
That run recorded `cosmolith` in the greeter-launched process tree. The
systemd target owns the Regolith helper units; cosmolith is started by the
session wrapper after the Sway IPC socket is ready. The newer persistence run
started cosmolith explicitly and is therefore not used as a second autostart
claim.

The patched display-persistence path has a separate [QEMU proof](proof-notes/2026-08-16-display-persistence-patched-qemu-proof.md).
It records the exact displayd/session source commits and package hashes. In a
disposable overlay, the then-current candidate applied the named QEMU profile
and Sway IPC reported `Virtual-1` at `1024x768` at `60.004 Hz`. That run used
the pre-correction Kanshi ownership, so it remains historical single-output
persistence evidence and is not proof of the newer target contract. The newer
Voulage package proof below keeps Kanshi GNOME-only and leaves COSMIC display
persistence with displayd. That historical proof recorded **4 of 12** criteria;
the current handoff status is recorded above as **5 of 12** after the fresh
session-context QEMU proof.

The [current-package persistence attempt](proof-notes/2026-08-16-final-displayd-persistence-attempt-failed.md)
tested the final displayd package alone. The live mode change succeeded, but a
cold reset returned the output and profile to `1280x800`. This is a failed
bounded attempt and is kept separate from the older exact session+Kanshi proof.

The follow-up [e606e0c candidate proof](proof-notes/2026-08-16-displayd-storage-pass-apply-fail.md)
fixes the profile overwrite: the saved `1024x768` profile survives reset, but
the current COSMIC output remains `1280x800` because no COSMIC profile-apply
helper is active. Full display persistence is therefore still open.

The [final displayd QEMU runtime proof](proof-notes/2026-08-16-final-displayd-qemu-runtime-proof.md)
installs that exact package in a disposable overlay and records a cold
Regolith COSMIC session with displayd, inputd, and the COSMIC idle helper
active. Kanshi is inactive under COSMIC, and Sway IPC responds. The proof is
QEMU-only and single-output.

The later displayd review found a target-contract mismatch: Kanshi was still
listed under the COSMIC target even though the COSMIC display path uses the
displayd Wayland observer. The personal-fork candidate
[`87c2b67`](https://github.com/Rahul-2k4/regolith-displayd/commit/87c2b677cdd8b580998c4210e1bb73a572c5785d)
keeps Kanshi GNOME-only and preserves displayd for both session targets.
Focused metadata checks pass. It is a review candidate, not an upstream PR or
the frozen runtime tuple.

## Reproduction helpers

- [`reproduce-voulage-branch-tuple.sh`](scripts/reproduce-voulage-branch-tuple.sh)
  reproduces the Voulage package-model path.
- [`reproduce-qemu-display-proof.sh`](scripts/reproduce-qemu-display-proof.sh)
  reproduces the display observer/profile proof when the documented QEMU
  environment is available.
- [`capture-runtime-state.sh`](scripts/capture-runtime-state.sh) captures
  installed package, unit, process, and failure-state information without
  changing the system.

The older [`install-current-tuple.sh`](scripts/install-current-tuple.sh) is a
historical seven-package installer. Do not treat it as the current final tuple
installer; use the dated proof notes for the current package names and hashes.

## Status

Strict evidence-backed status: **62-68%**, **5 of 12 criteria fully met**.

The result is QEMU-first. It does not claim native COSMIC hardware proof. The
project laptop was checked read-only and is Ubuntu GNOME without COSMIC
session binaries; see the [native-host boundary](proof-notes/2026-08-11-native-cosmic-host-boundary.md).

## Explicit remaining boundaries

- native `cosmic-comp` display persistence and Settings-panel behavior;
- physical touchpad, hotplug, mixed-DPI, and complete display validation;
- multimedia keys and the complete keyboard matrix;
- full native idle/logind and parent-session lifecycle semantics;
- signed package publication and maintainer/mentor acceptance.
- native Trixie COSMIC package-model entries and Trixie-labelled COSMIC
  artifacts through Voulage.

These are limitations, not silently converted into successes. No password,
private host detail, or private repository path is required by this public
bundle.
