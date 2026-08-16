# r31 package closure and QEMU runtime proof

Date: 2026-08-16

## What was verified

The local provider versions were pinned during an unsigned apt transaction in
a disposable Ubuntu 26.04 build environment. The transaction completed with
`INSTALL_EXIT=0`, and `dpkg-query` showed the target package set installed,
including the COSMIC session, Regolith session packages, displayd, inputd,
settings daemon, and the trawl providers.

The seven-package Regolith bundle also passed its recorded SHA-256 checks in
dry-run mode. It was then installed into a disposable Pop!_OS 24.04 QEMU
overlay. Two graphical logins were completed, with a cold reboot between
them. Both logins reported an active Wayland session with the COSMIC and
Regolith targets active, and the runtime verifier passed.

## Limits

The package closure and runtime checks are separate results. The runtime guest
was Pop!_OS 24.04, not Ubuntu Resolute, so this does not close the exact
Resolute cold-login gate. It is also QEMU-only and does not prove physical
hardware, multi-display/hotplug behavior, signing, publication, or upstream
acceptance.

The metadata review found two items that still need release decisions:

- the current Resolute pool contains a `cosmic-osd` artifact with a second
  distro suffix even though the source package version is already suffixed;
- a bare `regolith-inputd` `0.4.1` package is stale direct-build output rather
  than current Voulage output.

The `cosmic-osd` issue is being traced in Voulage's version-composition path.
No source pin or upstream package metadata was changed based on this audit.

## Current work-product status

The strict status remains **62-68% overall**, with **4 of 12 proposal
criteria fully met**. This note adds package-closure and Pop!_OS QEMU evidence;
it does not claim the remaining target-distro or hardware gates.
