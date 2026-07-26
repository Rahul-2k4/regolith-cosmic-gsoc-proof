# Regolith COSMIC proof bundle

Midterm snapshot: 2026-07-07. Latest proof note: 2026-07-26.

This bundle contains the proof notes and one reproduction script for the current midterm state of the Regolith COSMIC session work.

## Contents

Proof notes:

- `proof-notes/Midterm_Report_2026-07-06.md`
- `proof-notes/2026-07-04-regolith-session-kanshi-mask-qemu-proof.md`
- `proof-notes/2026-07-04-regolith-inputd-cosmic-mouse-live-watch-proof.md`
- `proof-notes/2026-07-04-cosmic-randr-sway-output-monitor-proof.md`
- `proof-notes/2026-07-04-cosmic-osd-source-package-proof.md`
- `proof-notes/2026-07-04-regolith-displayd-display-persistence-monitoring.md`
- `proof-notes/2026-07-26-qemu-display-monitoring-rerun.md`

Script:

- `scripts/reproduce-qemu-display-proof.sh`

## What can be reproduced directly

The script reproduces the QEMU display-monitoring proof:

- captures Regolith/Sway session state
- applies a reversible `cosmic-randr` mode change
- watches Sway IPC output events
- restores the configured restore mode tuple
- checks user failed units afterward

Prerequisites:

- a host reachable over SSH
- a running QEMU guest reachable from that host
- the guest logged into the Regolith/Sway COSMIC test session
- `sway`, `swaymsg`, `cosmic-randr`, `systemctl`, `timeout`, and SSH available in the expected places
- an output named `Virtual-1`, unless `OUTPUT_NAME` is overridden

Default run:

```bash
bash scripts/reproduce-qemu-display-proof.sh
```

Override the defaults if your host, guest user, port, output name, or proof directory differ:

```bash
HOST=my-qemu-host \
GUEST='ssh -p 2222 user@127.0.0.1' \
OUTPUT_NAME=Virtual-1 \
REMOTE_PROOF_DIR=/tmp/regolith-cosmic-display-proof \
bash scripts/reproduce-qemu-display-proof.sh
```

Defaults:

- SSH host `regolith-test-host.example` is a placeholder; set `HOST` for your machine
- QEMU guest is running
- guest SSH is reachable from the host; set `GUEST` for your user, host, and port
- guest is logged into Regolith/Sway COSMIC test session

Mode defaults:

- test mode: `1024x768 @ 60.004 Hz`
- restore mode: `1280x800 @ 74.994 Hz`

These match the captured QEMU proof. Override `TEST_WIDTH`, `TEST_HEIGHT`, `TEST_REFRESH`, `RESTORE_WIDTH`, `RESTORE_HEIGHT`, and `RESTORE_REFRESH` for a different guest/output.

Expected output:

- the script prints the guest proof directory
- `05-sway-output-events.jsonl` contains a Sway output event
- `07-after-mode-sway.json` and `08-after-mode-randr.txt` show the temporary mode
- `10-after-restore-sway.json` and `11-after-restore-randr.txt` show the configured restore mode tuple
- `12-user-failed-after.txt` is empty or contains no new failure caused by the proof

The script has a cleanup trap that tries to apply the configured restore mode tuple if it fails after applying the temporary mode. It does not auto-detect the original live mode.

This public repo is a lightweight proof-note bundle. Large raw assets from the private working vault are not copied here; the script above regenerates the display-monitoring proof artifacts.

## Claim boundaries

QEMU-proven:

- COSMIC session helper cleanup
- `regolith-inputd` mouse natural-scroll live watch
- `cosmic-randr` changes visible through Sway IPC output events
- the 2026-07-26 fresh single-output rerun and restore check

Source-package proven:

- `cosmic-osd` source package generation

Source-researched:

- COSMIC display apply path through `cosmic-randr` / Wayland output-management
- likely `regolith-displayd` extension point for observed display persistence

Not done yet:

- vanilla `cosmic.desktop` / `cosmic-comp` persistence proof
- multi-display, hotplug, and mixed-DPI runtime proof
- final installed package-set runtime matrix
- hardware/full laptop boot proof
