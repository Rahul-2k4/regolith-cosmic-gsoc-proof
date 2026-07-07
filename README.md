# Regolith COSMIC midterm proof bundle

Date: 2026-07-07

This bundle contains the proof notes and one reproduction script for the current midterm state of the Regolith COSMIC session work.

## Contents

Proof notes:

- `proof-notes/Midterm_Report_2026-07-06.md`
- `proof-notes/2026-07-04-regolith-session-kanshi-mask-qemu-proof.md`
- `proof-notes/2026-07-04-regolith-inputd-cosmic-mouse-live-watch-proof.md`
- `proof-notes/2026-07-04-cosmic-randr-sway-output-monitor-proof.md`
- `proof-notes/2026-07-04-cosmic-osd-source-package-proof.md`
- `proof-notes/2026-07-04-regolith-displayd-display-persistence-monitoring.md`

Script:

- `scripts/reproduce-qemu-display-proof.sh`

## What can be reproduced directly

The script reproduces the QEMU display-monitoring proof:

- captures Regolith/Sway session state
- applies a reversible `cosmic-randr` mode change
- watches Sway IPC output events
- restores the original mode
- checks user failed units afterward

Run:

```bash
bash scripts/reproduce-qemu-display-proof.sh
```

Assumptions:

- SSH alias `regolith-test-host` works
- QEMU guest is running
- guest SSH is reachable from laptop at `rahul@127.0.0.1:2222`
- guest is logged into Regolith/Sway COSMIC test session

## Claim boundaries

QEMU-proven:

- COSMIC session helper cleanup
- `regolith-inputd` mouse natural-scroll live watch
- `cosmic-randr` changes visible through Sway IPC output events

Source-package proven:

- `cosmic-osd` source package generation

Source-researched:

- COSMIC display apply path through `cosmic-randr` / Wayland output-management
- likely `regolith-displayd` extension point for observed display persistence

Not done yet:

- vanilla `cosmic.desktop` / `cosmic-comp` persistence proof
- final `regolith-displayd` persistence implementation
- binary `.deb` proof for `cosmic-osd`
- hardware/full laptop boot proof
