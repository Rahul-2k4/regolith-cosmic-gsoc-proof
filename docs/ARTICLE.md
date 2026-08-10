# Building a COSMIC-backed Wayland Session for Regolith

The first useful result was a failure. A COSMIC session reached
`regolith-inputd`, but the daemon expected the GNOME input-source schema. That
failure exposed the real problem: a session is not only a compositor launch.
The session boundary, user targets, input and display helpers, packaging, and
settings persistence must agree on which desktop is active.

This article records the engineering path and the limits of the resulting
work. The runtime evidence described here comes from a Pop!_OS QEMU guest.
It is not a claim of physical-laptop or native `cosmic-comp` completion.

## Keep the session boundary explicit

The supported Regolith path starts a COSMIC session around Sway. The launcher
exports `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`, then the COSMIC
user target owns the Regolith input and display helpers. The GNOME target stays
available as a separate path.

That separation matters. A COSMIC experiment should not silently replace the
GNOME session, and shared components should not grow COSMIC-specific behaviour
before the interface is ready. The final proof bundle records the target
ownership and helper-service checks in a fresh QEMU login, with zero helper
restarts and no project-owned failed user units.

See the [final closure verification](../proof-notes/2026-08-11-final-closure-verification.md)
and the [installation guide](INSTALL.md).

## Reuse the input bridge, split the backend

The project keeps input handling in `regolith-inputd`. It does not introduce a
second COSMIC-only input daemon. The existing handler interfaces are split by
Cargo feature, while runtime selection uses the active desktop environment.
GNOME support remains buildable and testable alongside the COSMIC backend.

The reconciled inputd source is `e641b43`. It combines the packaging cleanup
with the COSMIC touchpad reverse-sync implementation. The reverse-sync path
updates only the supported `accel_speed` and `natural_scroll` fields and
guards against a Sway-to-COSMIC-to-Sway feedback loop.

The source gates are concrete:

- default/GNOME tests: 22 passed;
- COSMIC-feature tests: 46 passed;
- all-feature tests: 49 passed;
- formatting and whitespace checks: passed.

Those numbers prove source and unit-test behaviour. They do not prove a real
touchpad, because the qualification VM exposes virtual pointer devices rather
than a `type:touchpad` device. The [inputd reconciliation note](../proof-notes/2026-08-11-inputd-reconciliation.md)
keeps that boundary explicit.

## Observe display changes before trying to own them

The mentor-directed display design is: COSMIC applies a configuration, and
Regolith observes the output state and persists a profile. `regolith-displayd`
uses the Wayland output-management observer for the COSMIC path and retains
Sway IPC for compatibility and fallback.

The Sway-backed QEMU session proves single-output profile reapplication after a
fresh login. It does not prove that native `cosmic-comp` accepts every
`cosmic-randr` mutation. In a separate native COSMIC QEMU seat, a mode command
returned success without changing the active mode or the saved profile. That
is a useful negative result, not a persistence pass.

See the [Wayland observer proof](../proof-notes/2026-08-04-cosmic-wayland-observer-qemu-proof.md)
and the [native display boundary](../proof-notes/2026-08-10-native-cosmic-display-mutation-boundary.md).

The Settings panel also exposed a practical testbed limitation: the resolution
selector reproduced a renderer crash. The CLI and compositor state were used
for the supported observer proof instead of treating the panel as validated.

## Packaging is part of the integration work

The first staged compositor artifact showed why packaging cannot be treated as
the last step. It linked the wrong `libdisplay-info` ABI for the target
userspace. Rebuilding from the corrected source reference produced the matching
runtime dependency and allowed the exact tuple to install in a disposable
Debian Trixie container with an empty `dpkg --audit`.

The Voulage path also exposed smaller release issues: quilt version formatting,
source identity, manual-page metadata, debug information, and the difference
between an unsigned local artifact and a published repository package. The
current proof bundle records hashes and build inputs, but the packages remain
unsigned and are not published to a canonical Regolith archive.

The [build dependency matrix](BUILD_DEP_MATRIX.md) and [install guide](INSTALL.md)
describe what a reviewer can reproduce. They separate build-dependency proof
from graphical runtime proof.

## Idle, OSD, and what the VM cannot answer

The supported fallback path has one `swayidle` plus `gtklock` owner. QEMU
proved timeout, lock, unlock, and a visible volume OSD. Native `cosmic-idle`,
full logind lock-state semantics, media-key delivery, and the complete parent
logout/shutdown lifecycle remain open.

The same distinction applies to hardware. Mixed DPI, hotplug, physical
multi-display behaviour, and physical touchpad reverse-sync were not claimed
because the available test surfaces cannot exercise them. The full list is in
the [known limitations](KNOWN_LIMITATIONS.md).

## COSMIC-specific follow-up belongs in COSMIC-specific code

The mentor approved upstream cosmolith pull requests because cosmolith is a
COSMIC-specific component, while asking that COSMIC code stay out of common
sessions until it is ready:

- [cosmolith #17: startup XKB tests](https://github.com/sandptel/cosmolith/pull/17)
- [cosmolith #18: deterministic session detection](https://github.com/sandptel/cosmolith/pull/18)
- [cosmolith #19: structured watcher errors](https://github.com/sandptel/cosmolith/pull/19)

These PRs are open and independently tested. They are not presented as
merged upstream work.

## Result

At the Aug 12 freeze, four of the proposal's twelve success criteria are fully
met. All four are QEMU-only. The honest strict proposal estimate is **62-68%**.
The remaining work is not hidden: native display mutation, the hardware
matrix, complete idle and parent-session lifecycle semantics, signing and
canonical publication, and final maintainer review remain open.

That is the main transferable lesson. For a tiling WM considering COSMIC,
start with the session boundary and existing interfaces. Then test the
settings bridge against the real compositor protocol. Finally, treat package
ABI, target ownership, rollback, and evidence as part of the feature rather
than paperwork after it.

The complete claim-to-proof index is the [work product](../WORK_PRODUCT.md).
