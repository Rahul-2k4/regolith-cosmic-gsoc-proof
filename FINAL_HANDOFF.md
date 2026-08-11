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

The COSMIC-specific cosmolith branch also has a [Sway helper test
proof](proof-notes/2026-08-12-cosmolith-sway-helper-tests.md). Its fresh Linux
clone passed all 10 library tests; the note keeps the existing formatting and
live-IPC limitations explicit.

The displayd branch also has a [Wayland multi-output reconciliation
proof](proof-notes/2026-08-12-displayd-wayland-multi-output-reconciliation.md).
The isolated source-test branch passed 51 library and 25 binary-target tests;
it does not claim physical hotplug or mixed-DPI runtime coverage.

## Reproduce the verified QEMU result

The exact final runtime result is recorded in [final QEMU graphical-login
proof](proof-notes/2026-08-12-final-inputd-qemu-runtime-success.md). It used a
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
proof](proof-notes/2026-08-12-qemu-launcher-binding-proof.md): QEMU HMP
`meta_l-spc` launched `ilia`, while `meta_l-2` and `meta_l-1` switched
workspaces `1 -> 2 -> 1`.

The same final-tuple run also exercised controlled parent teardown. After
Sway exited, the wrapper reported `PARENT_EXIT_PASS` and found no surviving
`cosmic-session` or `dbus-run-session` parent. See the [parent-exit proof](proof-notes/2026-08-12-final-tuple-parent-exit-proof.md).
This does not replace full display-manager logout/shutdown or native logind
proof.

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
session binaries; see the [native-host boundary](proof-notes/2026-08-12-native-cosmic-host-boundary.md).

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
