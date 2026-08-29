# Build a COSMIC-based Wayland session for Regolith

This repository is the public evidence bundle for the GSoC 2026 project
**Build a COSMIC-based Wayland Session for Regolith**.

The work adapts Regolith's existing session components for COSMIC while
keeping the GNOME path available. The preferred design is shared interfaces
and separate backends, not a second set of replacement daemons.

## Current result

**Strict status: 5 of 12 proposal criteria fully met. Estimated overall
progress: 62-68%. Proof is QEMU-only.**

The current evidence shows:

- a COSMIC session can launch through the Regolith wrapper in the tested QEMU
  environment;
- COSMIC and GNOME session targets are kept separate;
- `regolith-inputd` and `regolith-displayd` can be supervised by the COSMIC
  target;
- the COSMIC inputd backend has feature-gated source coverage and reverse-sync
  tests;
- display configuration can be applied through the Wayland observer path;
- the exact unsigned Resolute package tuple can be built and installed in the
  disposable QEMU test environment;
- the guarded real-system installer checks the unstable source and stale user
  unit before installation.

The latest displayd refresh-rate fix has passed source tests and an offline
Voulage build. Its QEMU persistence rerun is still pending, so the strict
criterion count has not changed.

## Architecture

```text
Greeter
  -> regolith-session-cosmic
  -> cosmic-session
  -> compositor/session helpers
  -> regolith-cosmic.target
       -> regolith-init-inputd.service
       -> regolith-init-displayd.service
```

The GNOME session remains a separate path. `regolith-inputd` uses feature
gates for GNOME and COSMIC implementations, then selects the runtime backend
from `XDG_CURRENT_DESKTOP`. Display handling follows the existing
`regolith-displayd` boundary and Wayland output-management observer rather
than introducing an unrelated persistence daemon.

## What is working

- QEMU cold-login and session-target supervision for the tested package tuple.
- COSMIC inputd source, feature, reverse-sync, and package-contract tests.
- COSMIC displayd apply-path source tests and unsigned offline package builds.
- GNOME/COSMIC target ownership and the mentor-directed GDM cleanup order in
  the tested QEMU scope.
- Lock/unlock and volume OSD proof in the supported QEMU paths.
- Reproduction scripts and dated proof notes for each accepted boundary.

## What is not yet proven

- Physical-hardware installation and cold login.
- Multi-monitor, hotplug, mixed-DPI, and physical-touchpad behaviour.
- Media-key OSD delivery through the current QEMU setup.
- Full display refresh-rate persistence after the latest source fix.
- Final Voulage publication, signing, and maintainer acceptance.
- A completely current fork-PR set for every source candidate.

These are proof boundaries, not claims that the missing behaviour is already
implemented.

## Reproduce the verified work

Start with the [final handoff](FINAL_HANDOFF.md), then use the current
[work product](WORK_PRODUCT.md) for the evidence map. The exact installer
order and safety checks are in [docs/INSTALL.md](docs/INSTALL.md).

Useful entry points:

- [Repository and branch status](docs/REPOSITORY_STATUS.md)
- [Gist update draft](docs/GIST_UPDATE_DRAFT.md)
- [Architecture reference](ARCHITECTURE.md)
- [QEMU display proof script](scripts/reproduce-qemu-display-proof.sh)
- [Inputd session verifier](scripts/verify-qemu-inputd-session-contract.sh)
- [Voulage reproduction script](scripts/reproduce-voulage-branch-tuple.sh)

The scripts are evidence helpers. They do not replace a real hardware test.
Read each script's prerequisites before running it.

## Demo

The bundle currently contains screenshot evidence. A video attachment still
needs to be added to both this repository and the submitted gist before the
mentor-facing submission is considered complete.

## Source branches

The code remains on personal fork branches while the mentor reviews the work.
No new upstream PR or merge is claimed here. The current branch and PR
inventory, including local-only candidates, is maintained in
[docs/REPOSITORY_STATUS.md](docs/REPOSITORY_STATUS.md).

## Submission

The final work product is the submitted
[GSoC write-up](https://gist.github.com/Rahul-2k4/ace071f9dc818ae31d72ff1f0fa27f49).
This repository supplies the code references, scripts, package identities,
logs, screenshots, and limitations behind that write-up.
