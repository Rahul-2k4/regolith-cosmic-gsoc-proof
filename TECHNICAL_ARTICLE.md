# Building a COSMIC-Based Wayland Session for Regolith

This project adapts the existing Regolith Wayland session for COSMIC while
keeping the GNOME path available. The work follows the mentor's direction to
make existing components interoperable before introducing new daemons.

## Session boundary

The COSMIC launcher starts the supported Regolith session with Sway as the
Wayland compositor. The session exports
`XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`. Separate GNOME and COSMIC
systemd targets own their respective session paths, while inputd and displayd
are attached to the active target.

The final disposable QEMU run installed the staged Resolute package tuple,
rebooted, and created a real user session through greetd IPC. `cosmic-session`,
Sway, and `regolith-inputd` ran with a live Wayland display and Sway IPC. The
COSMIC target and both helper units were active, the GNOME target was inactive,
and `dpkg --audit` was empty.

## Input handling

Input handling remains in `regolith-inputd`. GNOME and COSMIC implementations
are selected through Cargo features, and runtime selection uses the desktop
environment. This keeps one maintained component instead of creating a
COSMIC-only replacement daemon.

Source tests cover keyboard, input-source, mouse, and touchpad mappings. QEMU
proof covers the installed service and representative keyboard/input-source
transitions. Physical touchpad behavior, full reverse synchronization, and
direct Settings-panel interaction remain unproven.

## Display configuration

COSMIC display changes use the Wayland output-management path. The Regolith
display component can observe and reconcile output state, and source tests
cover multi-output reconciliation. QEMU proof covers the supported
single-output path and virtual output events.

Native `cosmic-comp` persistence, physical hotplug, mixed DPI, and a complete
hardware display matrix remain outside the evidence because the available
testbed cannot prove them. A Settings-panel renderer failure is recorded as a
limitation rather than hidden behind a CLI-only claim.

## Packaging and lifecycle

The session packages use the Regolith quilt version form, including the
`-1-1regolith-resolute` revision pattern where applicable. Voulage builds and
offline vendored Rust dependencies were verified. Disposable Ubuntu and Debian
package checks passed for the corrected session transition metadata, and the
QEMU tuple installed and rebooted with an empty `dpkg --audit`.

The current amd64 tuple also installed in disposable Ubuntu 26.04 and Debian
Trixie containers with empty `dpkg --audit`. The Trixie run used the available
local COSMIC packages, which still carry the Resolute suffix, so this is staged
install evidence rather than a canonical Trixie publication.

See the [package install proof](proof-notes/2026-08-12-clean-container-amd64-package-install.md)
and the [package graph proof](proof-notes/2026-08-11-clean-container-amd64-package-simulation.md).

The COSMIC target owns inputd and displayd. The GNOME target remains separate.
Fallback lock/unlock and OSD paths have QEMU evidence; native logind/idle
semantics, complete parent-session teardown, signing, canonical publication,
and maintainer acceptance remain open.

## Current result

The strict evidence-backed result is **62-68%**, with **5 of 12** proposal
success criteria fully met in the current QEMU-only ledger. This is not a
claim of completed hardware validation or upstream release.

The complete criteria table and links to source, package, test, and runtime
proof are in [`WORK_PRODUCT.md`](WORK_PRODUCT.md). The final graphical-login
proof is in [`proof-notes/2026-08-11-final-inputd-qemu-runtime-success.md`](proof-notes/2026-08-11-final-inputd-qemu-runtime-success.md).
