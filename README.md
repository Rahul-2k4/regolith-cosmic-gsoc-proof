# Regolith COSMIC proof bundle

This bundle contains the original midterm snapshot plus the reviewed QEMU
proof notes. Use `WORK_PRODUCT.md` for the current submission status. Native
`cosmic-comp` compositor runtime and the installed Sway-backed Regolith
wrapper cold-reboot path are proven on the QEMU seat; hardware/display
coverage, full idle lifecycle, signing, and final release review remain open.

For the current status and the latest sanitized evidence, start with the
[stable reviewer-facing work product](WORK_PRODUCT.md). The dated
[2026-08-09 snapshot](WORK_PRODUCT_2026-08-09.md) remains available as a
dated companion record.

For handoff and reproduction order, use the [final handoff](FINAL_HANDOFF.md).
For system boundaries and design rationale, use the [architecture reference](ARCHITECTURE.md).

This bundle contains the proof notes and reproduction scripts for the current
closure state of the Regolith COSMIC session work.

The public branch includes the new
[inputd candidate QEMU verifier](scripts/verify-inputd-candidate-qemu-runtime.sh)
(introduced in `cedcd52`); it is read-only with respect to package installation
and persistent session configuration.

## Latest source checkpoint - 2026-08-23

The reconciled inputd branch now contains vendored offline build wiring
(`e3fbd5c`), keyboard/input-source reverse synchronization (`b07ea315`), and
pointer reverse synchronization (`e8fce66`).
The current unsigned package is
`regolith-inputd_0.4.1-2-1regolith-resolute_e8fce66_amd64.deb`, SHA-256
`650bd6f38bf67a08e140fa566aff4e7c63b2a41fc2cc60b04aada670a420823b`, with 55
GNOME+COSMIC feature tests passing. This is source/package evidence only; the
strict ledger remains 5 of 12, QEMU-only.

See the [pointer reverse-sync source checkpoint](proof-notes/2026-08-23-inputd-pointer-reverse-sync-source.md).
The [QEMU package-install checkpoint](proof-notes/2026-08-23-inputd-pointer-qemu-package-install.md)
records the matching in-guest hash and cold-boot boundary.

## Historical closure update - 2026-08-21

The public status is still **5 of 12**, QEMU-only. One criterion moved up and
one different criterion moved back down on the same day, so the headline count
did not change.

The [combined three-fix verification boot](proof-notes/2026-08-21-combined-three-fix-verification-qemu.md)
is the current package-audit result. The tested COSMIC session path had no
`gdm3`, `gnome-shell`, `gnome-session-bin`, or `ubuntu-session`, zero failed
user units, clean `dpkg --audit`, and only documented non-bootstrap
GNOME-named survivors. That is enough to treat the package-audit criterion as
met for the tested QEMU scope.

The [displayd real apply and persistence proof](proof-notes/2026-08-21-displayd-real-apply-and-persistence-qemu.md)
is the current display result. It proved live mode and scale changes on a real
QEMU output and showed those settings surviving cold reboot. It also found a
real bug: refresh rate persisted wrong (`60Hz` requested, `50Hz` restored).
That pulled the broad settings-persist criterion back to `Partial`, which is
why the ledger stays at **5 of 12**.

The August 22 inputd gate is packaged at
`0.4.1-2-1regolith-resolute` from source
`fc895d00b890ff010dae58be8f4265fa219cabbb`. Its unsigned package hash is
`e1cf3eaca8a73b0aab6b1f117897baddb724c914c1797f9d3ecb126d89d2a221`; 61
offline feature tests and staged-install checks passed. A fresh post-reboot
greetd launch was later rerun after the COSMIC handshake and absent-legacy-unit
fixes; the rebuilt package keeps Sway and the target helpers alive with
persistent IPC.

The [2026-08-23 target-edge rerun](proof-notes/2026-08-23-session-target-edge-rerun.md)
rebuilt the session package from `35a0833eb98acbdcb756b65655e08c3ece37e0ac`
as `1.2.0-1ubuntu1` (SHA-256
`5a74aba9ccb9f0ca9bb499237be7ebc1187c7e25af789f2ce57242f545b9c3b3`). It
removes the premature parent-target `Wants=` edge and starts
`regolith-cosmic.target` only after compositor readiness. The fresh QEMU login
reached the target through that path. Follow-up commits `a29cc13` and `6670d8b`
bridge the COSMIC `SetEnv` handshake and tolerate absent legacy units. The
rebuilt package keeps Sway, cosmic-session, inputd, displayd, and the idle
fallback active with persistent Wayland/Sway IPC sockets. See the follow-up
section in the linked proof note for the exact package hash and QEMU-only GPU
override boundary.

The earlier 2026-08-17 section below is kept as a dated stage result, not the
current ledger authority.

## Latest closure update - 2026-08-17

The [fresh COSMolith input/display persistence proof](proof-notes/2026-08-17-fresh-cosmolith-input-display-persistence-qemu.md)
supersedes the earlier same-day diagnostic tuple. With the active Sway session
context inherited, live Sway applied French/AZERTY and repeat `540/31`; the
same state and `1024x768` remained after a second cold reboot/login. That was
the keyboard-side persistence result at the time. Later Aug 21 display testing
found the refresh-rate bug noted above, so this section is historical rather
than current-ledger status.

The [Ubuntu 26.04 local-pool closure proof](proof-notes/2026-08-17-ubuntu-resolute-local-pool-closure.md)
adds a fresh disposable package transaction. The local Resolute pool indexed
44 entries from 47 artifacts, and installing the COSMIC, GNOME-target, and
Sway session packages returned `0` with an empty `dpkg --audit`. This improves
the package-install evidence for Criteria 9 and 10. It does not prove a
greeter-selected graphical Resolute login, signed archive publication, or
hardware behavior.

The [clean COSMIC-only survivor audit](proof-notes/2026-08-17-clean-cosmic-only-install-survivor-audit.md)
replays `apt-get install regolith-session-cosmic` without explicitly
installing the GNOME target. That dated run found four GNOME-related
transitive packages still needing written removal plans. The later August 21
combined verification supersedes its status wording and closes Criterion 9
for the tested QEMU scope; the survivor note remains historical evidence.

The [exact session-package QEMU proof](proof-notes/2026-08-17-exact-session-package-qemu-criterion-9.md)
then installed the same Resolute session tuple on a copy-on-write overlay,
rebooted, and reached a greetd COSMIC login with the COSMIC target and both
helpers active, the GNOME target inactive, and an empty `dpkg --audit`. This
is stronger QEMU evidence for Criterion 9, not a clean archive or hardware
claim.

The [managed logout harness boundary](proof-notes/2026-08-17-managed-logout-harness-boundary.md)
is now followed by a successful [exact-tuple managed logout proof](proof-notes/2026-08-17-managed-logout-exact-tuple-success.md).
The supported [fallback idle-to-lock proof](proof-notes/2026-08-17-fallback-lock-exact-tuple-success.md)
is also recorded for the same QEMU scope. The earlier boundary note records a
separate lifecycle attempt where login and target/helper health passed, but the
SSH/logind session race prevented a valid managed termination request. No
logout, shutdown, or native idle claim is made from that attempt.

Additional package and runtime evidence is in
[r31 package closure and QEMU runtime proof](proof-notes/2026-08-16-r31-package-and-qemu-runtime.md).
It records an exact local-provider apt transaction in a disposable Ubuntu
26.04 build environment and two graphical Pop!_OS 24.04 QEMU logins with a
reboot between them. The Pop!_OS result is useful runtime evidence, but it is
not an Ubuntu Resolute runtime claim.

The same note records two package-metadata boundaries: a stale bare inputd
artifact and a Voulage double-distro suffix in the current `cosmic-osd`
output. The suffix issue is now fixed and independently rebuilt on the
personal fork; see the [Voulage version-composition fix](proof-notes/2026-08-16-voulage-version-composition-fix.md).
The stale inputd artifact and release-level packaging checks remain open.

The corrected `cosmic-osd` metadata has now been rebuilt independently with
zero Lintian findings; see the [cosmic-osd metadata and Lintian closure](proof-notes/2026-08-16-cosmic-osd-lintian-closure.md).
The artifact is unsigned and from a personal fork, so this does not prove
official publication or final release readiness.

The [cosmic-settings-daemon metadata closure](proof-notes/2026-08-16-cosmic-settings-daemon-lintian-closure.md)
now records a corrected DEP-5 copyright, successful vendored Resolute build,
correct package version composition, and clean direct binary-package Lintian.
Source and generated debug-package warnings remain explicitly listed.

The [final tuple graphical-login rerun](proof-notes/2026-08-16-final-tuple-graphical-login-rerun.md)
adds a fresh disposable Pop!_OS QEMU login after reboot. It verifies the
COSMIC target, healthy inputd/displayd helpers, GNOME target exclusion, empty
`dpkg --audit`, the ilia launcher binding, and representative workspace
switching. It remains Pop!_OS/QEMU-only evidence.

The [canonical inputd QEMU runtime note](proof-notes/2026-08-16-inputd-canonical-qemu-runtime.md)
repeats that contract with the canonical inputd source commit and the
`0.4.1-2-1regolith-resolute` package. Live COSMIC input-source mutation and
physical touchpad reverse-sync were not covered by that verifier note.

The [canonical inputd xkb live-watch proof](proof-notes/2026-08-17-inputd-canonical-xkb-live-watch-qemu.md)
adds a fresh Pop!_OS QEMU mutation/restore run for the current package. The
COSMIC xkb config changed to French/AZERTY with repeat `540/31`, Sway reflected
the change, and the US `600/25` state was restored. This does not claim the
COSMIC Settings GUI or physical touchpad coverage.

The [combined input/display persistence proof](proof-notes/2026-08-17-combined-input-display-persistence-qemu.md)
is retained as a historical diagnostic tuple. Its manually traced COSMolith
process lacked the active Sway session context, so repeat reverted to `600/25`.
The fresh session-context proof above is the current Criterion 7 evidence.

## Current closure slice - 2026-08-12

Current aggregate public proof tip: `main`.

The corrected 2026-08-09 lifecycle result supersedes the older native-idle
tuple for current claims:

- [Corrected tuple lifecycle and rollback](proof-notes/2026-08-09-corrected-tuple-lifecycle.md)

The reference wrapper source tuple for this closure slice is
`regolith-session` `3523047b`, `regolith-wm-config` `10225c05`,
`regolith-inputd` `e32d049`, and `regolith-displayd` `817becd9`.
The corrected Voulage model is `f3827893`; older models such as `9794c188`,
`bf0145e3`, and source `9c35074` remain historical proof only.

The frozen `regolith-displayd` source audit passed 73 locked tests and retained
the Wayland observer; it does not claim native or physical display coverage.
See [the source audit](proof-notes/2026-08-10-displayd-frozen-source-audit.md).

**Acceptance-boundary note:** the submitted PDF says the legacy inputd and
displayd units should remain inactive after a COSMIC login. Mentor feedback
later approved separate GNOME/COSMIC targets and target-owned helper units.
The current implementation therefore expects those helpers to be active under
`regolith-cosmic.target`; the QEMU proof checks target ownership, healthy
services, zero restarts, and GNOME-session exclusion. This supersedes the
older inactive-helper wording without changing the goal of removing the GNOME
bootstrap path.

Provenance correction: the corrected Voulage model has now been rebuilt and
exercised through the real QEMU greeter. Model commit
[`f38278934be32e9d051390b19cc416c3f320e7e5`](https://github.com/Rahul-2k4/voulage/commit/f38278934be32e9d051390b19cc416c3f320e7e5) restores session source `3523047b`,
and the exact unsigned package is recorded in [the corrected-model proof](proof-notes/2026-08-10-corrected-voulage-model-real-greeter.md).

The exact source pins for the frozen session, inputd, and displayd model are
also protected by the test-only Voulage commit
[`abbf6562dd670637d9c7fa70284befc5dba01fd6`](https://github.com/Rahul-2k4/voulage/commit/abbf6562dd670637d9c7fa70284befc5dba01fd6).
See the [pin regression proof](proof-notes/2026-08-10-voulage-frozen-cosmic-pin-regression.md).

- [Current Voulage tuple build](proof-notes/2026-08-08-voulage-current-tuple-build.md)
- [QEMU Sway resource fallback rerun](proof-notes/2026-08-08-qemu-sway-resource-fallback-rerun.md)
- [QEMU live manager/socket repair](proof-notes/2026-08-08-qemu-live-manager-socket-repair.md)
- [Current tuple QEMU runtime rerun](proof-notes/2026-08-08-current-tuple-qemu-runtime-rerun.md)
- [Current tuple display persistence](proof-notes/2026-08-08-current-tuple-display-persistence.md)
- [Voulage reproduction script](scripts/reproduce-voulage-branch-tuple.sh)
- [Clean Voulage rebuild and exact package hashes](proof-notes/2026-08-09-clean-voulage-rebuild.md)
- [Display profile reapplication fix and fresh-login proof](proof-notes/2026-08-09-display-profile-reapply-fix.md)
- [Wayland/wlr display observer QEMU proof](proof-notes/2026-08-04-cosmic-wayland-observer-qemu-proof.md)
- [COSMIC keyboard layout and variant event tests](proof-notes/2026-08-09-cosmolith-input-tests.md)
- [Current tuple acceptance](proof-notes/2026-08-09-current-tuple-acceptance.md)
- [Current-hash regolith-inputd QEMU proof](proof-notes/2026-08-09-current-hash-inputd-qemu-proof.md)
- [Regolith wrapper cold-reboot QEMU proof](proof-notes/2026-08-09-regolith-wrapper-cold-reboot-qemu-proof.md)
- [Real disposable Trixie install](proof-notes/2026-08-09-real-trixie-container-install.md)
- [Cosmolith package/install boundary](proof-notes/2026-08-09-cosmolith-package-install-boundary.md)
- [Cosmolith fresh-session QEMU proof](proof-notes/2026-08-09-cosmolith-fresh-session-qemu-proof.md)
- [Live QEMU runtime recheck](proof-notes/2026-08-09-live-qemu-runtime-recheck.md)
- [Inputd reverse-sync tests](proof-notes/2026-08-09-inputd-reverse-sync-tests.md)
- [GNOME coexistence boundary](proof-notes/2026-08-09-gnome-regression-boundary.md)
- [Lintian release audit](proof-notes/2026-08-09-lintian-release-audit.md)
- [Native compositor launch boundary](proof-notes/2026-08-09-native-compositor-launch-boundary.md)
- [Native compositor QEMU seat proof](proof-notes/2026-08-09-native-cosmic-comp-qemu-proof.md)
- [Fallback idle timeout](proof-notes/2026-08-09-idle-timeout-fallback.md)
- [Current tuple fallback lock/unlock QEMU proof](proof-notes/2026-08-09-fallback-lock-unlock-current-tuple-qemu-proof.md)
- [COSMIC volume OSD](proof-notes/2026-08-09-cosmic-osd-volume.md)
- [Media-key test boundary](proof-notes/2026-08-09-media-key-boundary.md)
- [Historical seven-package installer](scripts/install-current-tuple.sh)
- [Corrected Voulage model real-greeter proof](proof-notes/2026-08-10-corrected-voulage-model-real-greeter.md)
- [Native COSMIC display mutation boundary](proof-notes/2026-08-10-native-cosmic-display-mutation-boundary.md)
- [Frozen Voulage pin regression](proof-notes/2026-08-10-voulage-frozen-cosmic-pin-regression.md)
- [Inputd Voulage package proof](proof-notes/2026-08-10-inputd-voulage-package-proof.md)
- [Inputd candidate QEMU runtime follow-up](proof-notes/2026-08-10-inputd-candidate-verifier-qemu-runtime.md)
- [Managed display-manager logout](proof-notes/2026-08-10-managed-logout-qemu-proof.md)
- [Sway-exit parent-session lifecycle boundary](proof-notes/2026-08-10-sway-exit-parent-lifecycle-boundary.md)
- [Current parent lifecycle diagnostic](proof-notes/2026-08-11-parent-lifecycle-diagnostic-qemu-proof.md)
- [Current `a14abe3` `cosmic-session` package QEMU proof](proof-notes/2026-08-11-current-a14-cosmic-session-package-qemu-proof.md)
- [Upstream `cosmic-session` parent-exit source/package proof](proof-notes/2026-08-11-cosmic-session-parent-exit-source-package-proof.md)
- [Voulage session repin and retained package build](proof-notes/2026-08-11-voulage-session-repin.md)
- [Canonical inputd branch reconciliation](proof-notes/2026-08-11-inputd-canonical-reconciliation.md)
- [Displayd multi-output reconciliation test](proof-notes/2026-08-11-displayd-multi-output-reconciliation-test.md)
- [Voulage displayd candidate model](proof-notes/2026-08-12-voulage-displayd-candidate-model.md)
- [Canonical inputd QEMU session boundary](proof-notes/2026-08-11-canonical-inputd-qemu-session-boundary.md)
- [Corrected Voulage session rebuild and QEMU proof](proof-notes/2026-08-10-corrected-voulage-session-rebuild-qemu-proof.md)
- [COSMIC session launcher manpage Voulage proof](proof-notes/2026-08-10-session-manpage-voulage-proof.md)
- [Voulage `--arch` parser and exact session build](proof-notes/2026-08-10-voulage-arch-parser-session-build.md)
- [COSMIC idle ownership and fallback QEMU proof](proof-notes/2026-08-10-idle-ownership-cold-login.md)
- [Inputd candidate QEMU verifier](scripts/verify-inputd-candidate-qemu-runtime.sh)
- [Inputd candidate verifier QEMU runtime proof](proof-notes/2026-08-10-inputd-candidate-verifier-qemu-runtime.md)
- [Inputd touchpad reverse-sync candidate](proof-notes/2026-08-10-inputd-touchpad-reverse-sync.md)
- [Keyboard `bindsym` injection boundary](proof-notes/2026-08-11-keyboard-bindsym-injection-boundary.md)

The corrected Voulage session rebuild is documented in
[the rebuild and QEMU proof](proof-notes/2026-08-10-corrected-voulage-session-rebuild-qemu-proof.md).

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

The older slice below records superseded model and package hashes. Builds
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

### Candidate-bound inputd session verifier

The candidate verifier checks an already-installed QEMU session and requires
the expected package version and binary SHA-256. It verifies the COSMIC target,
GNOME target exclusion, target dependency membership for both helpers, helper
health with zero restarts, allowlisted COSMIC process environment variables,
absence of `gnome-session-bin`, and project-owned failed units. It writes proof
files with restrictive permissions and does not install packages, restart
services, reboot, or change persistent configuration.

When `INPUTD_HELPER` is supplied, it temporarily changes live input settings
for a round trip and restores them on exit. That mode is not purely read-only
and does not prove physical touchpad behavior, native `cosmic-comp` display
mutation, or hardware coverage.

Example:

`EXPECTED_BINARY_SHA256` is the hash of the installed
`/usr/bin/regolith-inputd` binary, not the `.deb` archive hash.

```bash
HOST=my-qemu-host \
GUEST='ssh -p 2222 user@127.0.0.1' \
EXPECTED_PACKAGE_VERSION=0.4.1-2-1regolith-resolute \
EXPECTED_BINARY_SHA256=b484e3f05f8042f217d1fca46507a8c1011c565bc2c69034b202f8d8599981eb \
REMOTE_PROOF_DIR=/tmp/regolith-cosmic-inputd-candidate-proof \
bash scripts/verify-inputd-candidate-qemu-runtime.sh
```

### Existing session-contract verifier

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

Reviewer-facing technical article: [docs/ARTICLE.md](docs/ARTICLE.md).
`TECHNICAL_ARTICLE.md` remains a legacy snapshot.

## Claim boundaries

QEMU-proven:

- fresh staged Resolute package/session install followed by greetd graphical
  login: COSMIC session, Sway, inputd, active COSMIC target, active target-owned
  inputd/displayd units, inactive GNOME target, and empty `dpkg --audit`
- current-hash `regolith-inputd` COSMIC login, active service, COSMIC backend
  environment, and one keyboard/input-source live transition with restoration
- COSMIC session helper cleanup
- `regolith-inputd` mouse natural-scroll live watch
- installed-session keyboard/input-source live update and restoration
- installed-session mouse natural-scroll update and restoration
- `cosmic-randr` changes visible through Sway IPC output events
- the 2026-07-26 fresh single-output rerun and restore check

QEMU-boundary findings:

- the final staged tuple is QEMU-only; source provenance for every binary is
  recorded in the private build packet, not inferred from the runtime alone
- the current guest has no touchpad device, so touchpad state-change coverage
  remains open
- this current-hash inputd result does not prove reverse-sync runtime behavior,
  hardware behavior, signing/release, or an upstream merge
- two real five-minute fallback timeout-to-lock/unlock cycles now have QEMU
  evidence; native cosmic-idle/logind semantics remain open
- direct `swaymsg exit` stops the Regolith wrapper, compositor, COSMIC target,
  and helpers but leaves the parent `cosmic-session`/`dbus-run-session` alive;
  the display-manager-owned logout path remains the clean lifecycle path
- representative workspace binding proof is recorded separately; it remains
  partial coverage, not a complete keyboard matrix
- a corrected QEMU `meta_l-spc` run launched `ilia`; launcher and workspace
  evidence remain representative, not a complete keyboard/media-key matrix
- the project laptop was checked read-only and is Ubuntu GNOME without a
  native COSMIC session; see the [native-host boundary](proof-notes/2026-08-11-native-cosmic-host-boundary.md)

Source/package proven:

- `cosmic-osd` source package generation
- Cosmolith vendored/offline build, binary `.deb` creation, and exact QEMU
  installation, followed by a fresh graphical QEMU login observing the
  packaged `/usr/bin/cosmolith` runtime. Signing and canonical publication
  remain open.

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
- parent `cosmic-session`/`dbus-run-session` teardown after direct Sway exit
- hardware/full laptop boot proof
