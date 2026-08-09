# Regolith COSMIC proof bundle

This bundle contains the original midterm snapshot plus the reviewed QEMU
proof notes. Native `cosmic-comp` compositor runtime is now proven on the
QEMU seat; native Regolith-wrapper behavior, hardware/display coverage, full
idle lifecycle, signing, and final release review remain open.

For the current status and the latest sanitized evidence, start with the
[2026-08-09 work-product snapshot](WORK_PRODUCT_2026-08-09.md).

This bundle contains the proof notes and one reproduction script for the current midterm state of the Regolith COSMIC session work.

## Current closure slice - 2026-08-08

The corrected 2026-08-09 lifecycle result supersedes the older native-idle
tuple for current claims:

- [Corrected tuple lifecycle and rollback](proof-notes/2026-08-09-corrected-tuple-lifecycle.md)

Current closure displayd model: `c8fba468`, session source `3523047b`, displayd
source `817becd9`. The current session-build model is `bf0145e3`. The earlier model
`9794c188` and session `9c35074` remain historical proof only.

- [Current Voulage tuple build](proof-notes/2026-08-08-voulage-current-tuple-build.md)
- [QEMU Sway resource fallback rerun](proof-notes/2026-08-08-qemu-sway-resource-fallback-rerun.md)
- [QEMU live manager/socket repair](proof-notes/2026-08-08-qemu-live-manager-socket-repair.md)
- [Current tuple QEMU runtime rerun](proof-notes/2026-08-08-current-tuple-qemu-runtime-rerun.md)
- [Current tuple display persistence](proof-notes/2026-08-08-current-tuple-display-persistence.md)
- [Voulage reproduction script](scripts/reproduce-voulage-branch-tuple.sh)
- [Clean Voulage rebuild and exact package hashes](proof-notes/2026-08-09-clean-voulage-rebuild.md)
- [Display profile reapplication fix and fresh-login proof](proof-notes/2026-08-09-display-profile-reapply-fix.md)
- [COSMIC keyboard layout and variant event tests](proof-notes/2026-08-09-cosmolith-input-tests.md)
- [Current tuple acceptance](proof-notes/2026-08-09-current-tuple-acceptance.md)
- [Regolith wrapper cold-reboot QEMU proof](proof-notes/2026-08-09-regolith-wrapper-cold-reboot-qemu-proof.md)
- [Real disposable Trixie install](proof-notes/2026-08-09-real-trixie-container-install.md)
- [Live QEMU runtime recheck](proof-notes/2026-08-09-live-qemu-runtime-recheck.md)
- [Inputd reverse-sync tests](proof-notes/2026-08-09-inputd-reverse-sync-tests.md)
- [GNOME coexistence boundary](proof-notes/2026-08-09-gnome-regression-boundary.md)
- [Lintian release audit](proof-notes/2026-08-09-lintian-release-audit.md)
- [Native compositor launch boundary](proof-notes/2026-08-09-native-compositor-launch-boundary.md)
- [Native compositor QEMU seat proof](proof-notes/2026-08-09-native-cosmic-comp-qemu-proof.md)
- [Fallback idle timeout](proof-notes/2026-08-09-idle-timeout-fallback.md)
- [COSMIC volume OSD](proof-notes/2026-08-09-cosmic-osd-volume.md)
- [Media-key test boundary](proof-notes/2026-08-09-media-key-boundary.md)
- [Historical seven-package installer](scripts/install-current-tuple.sh)

### Historical installer

The existing installer targets the earlier seven-package snapshot. Do not use
it for the current model until its manifest is refreshed from the current
tuple proof note.

With the historical seven hash-verified `.deb` files in one directory, run:

```bash
bash scripts/install-current-tuple.sh /path/to/package-directory
```

The script rejects missing or unexpected package files, verifies the recorded
historical SHA-256 values, installs the tuple in deterministic order, and runs
`sudo dpkg --audit`.

The older slice below records the superseded model and package hashes. Builds
used Voulage model commit `9794c18826d87981e783cdeabe392233b9218890` with
session `9c35074`, WM-config `10225c5`, inputd `e32d049`, and displayd `e8cc8e`.
Displayd used the nightly Cargo toolchain required by Cargo.lock v4; no source
or lock files were edited. The QEMU notes prove the Sway-backed runtime repair
and resource-fallback fix, but do not claim current-hash cold-login, native
`cosmic-comp`, release signing, rollback, or hardware completion.

Known lintian findings remain. The current QEMU acceptance snapshot is recorded
in the linked proof note. Packages remain unsigned and are not presented as
release-ready.

## Contents

Proof notes:

- `proof-notes/Midterm_Report_2026-07-06.md`
- `proof-notes/2026-07-04-regolith-session-kanshi-mask-qemu-proof.md`
- `proof-notes/2026-07-04-regolith-inputd-cosmic-mouse-live-watch-proof.md`
- `proof-notes/2026-07-04-cosmic-randr-sway-output-monitor-proof.md`
- `proof-notes/2026-07-04-cosmic-osd-source-package-proof.md`
- `proof-notes/2026-07-04-regolith-displayd-display-persistence-monitoring.md`
- `proof-notes/2026-07-26-qemu-display-monitoring-rerun.md`
- `proof-notes/2026-07-27-installed-inputd-live-handler-rerun.md`
- `proof-notes/2026-07-27-installed-display-observation-rerun.md`
- `proof-notes/2026-07-27-lock-rerun-boundary.md`

Script:

- `scripts/reproduce-qemu-display-proof.sh`
- `scripts/verify-qemu-inputd-session-contract.sh`

## What can be reproduced directly

The script reproduces the QEMU display-monitoring proof:

- captures Regolith/Sway session state
- applies a reversible `cosmic-randr` mode change
- watches Sway IPC output events
- restores the configured restore mode tuple
- checks user failed units afterward

The session-contract verifier checks an already-installed, already-running
Regolith/Sway COSMIC guest without changing guest services or session state:

- running `sway` with `XDG_CURRENT_DESKTOP` containing `COSMIC`, checked from the Sway process environment
- running `regolith-inputd` with `XDG_CURRENT_DESKTOP` containing `COSMIC`, checked separately from the inputd process environment
- `regolith-cosmic.target` active and `regolith-gnome.target` inactive or masked
- `regolith-init-inputd.service` and `regolith-init-displayd.service` active,
  with `Result=success` and `NRestarts=0`
- no `gnome-session-bin` process
- no project-owned failed user units
- user failed units plus target, helper-service, process, and session evidence in the selected proof directory

Run it with the same `HOST`/`GUEST` convention as the display script:

```bash
HOST=my-qemu-host \
GUEST='ssh -p 2222 user@127.0.0.1' \
REMOTE_PROOF_DIR=/tmp/regolith-cosmic-inputd-session-proof \
bash scripts/verify-qemu-inputd-session-contract.sh
```

Prerequisites: SSH access to the QEMU host and guest, an active logged-in
Regolith/Sway COSMIC session, and guest access to `bash`, `pgrep`, `ps`,
`loginctl`, `systemctl`, `grep`, `head`, `tee`, and `tr`. The verifier creates
only the caller-selected proof directory and its evidence files. Its PASS
result requires both the Sway and regolith-inputd process environments to
contain the COSMIC selector, COSMIC target ownership, healthy inputd/displayd
helpers, GNOME exclusion, and no project-owned failed user units. Kanshi does
not need to be active. It is an installed-session contract check, not proof of
hardware, cold-login, or touchpad behavior.

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
- installed-session keyboard/input-source live update and restoration
- installed-session mouse natural-scroll update and restoration
- `cosmic-randr` changes visible through Sway IPC output events
- the 2026-07-26 fresh single-output rerun and restore check

QEMU-boundary findings:

- the current guest has no touchpad device, so touchpad state-change coverage
  remains open
- fallback timeout-to-lock and unlock now have QEMU evidence; native idle and
  logind semantics remain open

Source-package proven:

- `cosmic-osd` source package generation

Source/unit reviewable from the public branch, with limits:

- The reviewed `regolith-displayd` source branch contains the `Monitor` and
  `LogicalMonitor` equality/hash fixes, empty-output guard, and direct
  regression tests at commit `9b7fb458` on the
  [Rahul displayd branch](https://github.com/Rahul-2k4/regolith-displayd/tree/rahul/displayd-observed-output-persistence).
- The laptop test logs and fixed-binary QEMU proof are not copied into this
  public snapshot; the private vault/current audit remains authoritative for
  those environment-specific results.
- single-output fixed-binary QEMU smoke test through Sway IPC

Source-researched:

- COSMIC display apply path through `cosmic-randr` / Wayland output-management
- native `cosmic-comp` display persistence, multi-display/hotplug, mixed DPI,
  and hardware behavior remain unverified

Not done yet:

- vanilla `cosmic.desktop` / `cosmic-comp` persistence proof
- multi-display, hotplug, and mixed-DPI runtime proof
- final installed package-set runtime matrix
- direct Settings-panel interaction and media-key delivery
- hardware/full laptop boot proof
