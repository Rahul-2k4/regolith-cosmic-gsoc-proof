# Final GSoC Handoff

Project: **Build a COSMIC-based Wayland Session for Regolith**

Public proof bundle: [main branch](https://github.com/Rahul-2k4/regolith-cosmic-gsoc-proof/tree/main)

## Start here

1. Read [`WORK_PRODUCT.md`](WORK_PRODUCT.md) for the 12 proposal criteria.
2. Read [`ARCHITECTURE.md`](ARCHITECTURE.md) for component boundaries, data
   flow, and design decisions.
3. Read [`TECHNICAL_ARTICLE.md`](TECHNICAL_ARTICLE.md) for the engineering
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

The personal [Voulage displayd wrapper proof](proof-notes/2026-08-15-voulage-displayd-wrapper-build-proof.md)
also records a real unsigned `regolith-displayd_0.3.4-1-1regolith-resolute`
package produced through the wrapper after the Cargo.lock v4 fix. The exact
package was installed in the combined [QEMU proof](proof-notes/2026-08-15-combined-displayd-package-qemu-proof.md);
it is not a published archive artifact.

The [cosmolith cold-reboot persistence proof](proof-notes/2026-08-15-cosmolith-cold-reboot-persistence.md)
records the current `cosmolith` and `regolith-inputd` package hashes, a
generated Sway configuration round trip, and a fresh graphical QEMU login
after reboot. The result covers one keyboard setting and remains QEMU-only.

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

## Reproduce the verified QEMU result

The exact final runtime result is recorded in [final QEMU graphical-login
proof](proof-notes/2026-08-11-final-inputd-qemu-runtime-success.md). It used a
copy-on-write overlay, installed the staged Resolute tuple, rebooted, and
created a real user session through greetd IPC.

The result verified:

- `cosmic-session`, Sway, and `regolith-inputd` running;
- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`;
- live Wayland and Sway IPC;
- active `regolith-cosmic.target`;
- active target-owned inputd and displayd units;
- inactive `regolith-gnome.target`;
- empty `dpkg --audit`.

The current package tuple also passes disposable amd64 filesystem installation
on Ubuntu 26.04 and Debian Trixie with empty `dpkg --audit`. The Trixie run
uses the available local COSMIC packages with a Resolute suffix, so it is staged
install evidence rather than canonical Trixie publication proof. See the
[package install proof](proof-notes/2026-08-12-clean-container-amd64-package-install.md).

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

Strict evidence-backed status: **62-68%**, **4 of 12 criteria fully met**.

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
