# Midterm report - Regolith COSMIC session

Date: 2026-07-06

## Status

At midterm, the project has moved past research-only work. We now have QEMU runtime proof for session cleanup, input settings watching, and display-change monitoring in the Regolith/Sway testbed.

The main result so far: the COSMIC path is no longer a vague porting idea. We have working proof for several pieces of the session, and the remaining hard part is now specific: display persistence from externally observed output changes.

## What is done

### COSMIC session cleanup

The COSMIC session path was still starting `regolith-init-kanshi.service`. That conflicted with the direction we are taking for COSMIC display handling, so I added it to the same mask/reset path used for other legacy helpers.

Proof:

- Repo: `regolith-session`
- Branch: `rahul/cosmic-session-week1-2`
- Commit: `14cfaab Mask kanshi helper in COSMIC session`
- Tests passed:
  - `bash tests/regolith-cosmic-autostart.sh`
  - `bash tests/regolith-cosmic-status-bar.sh`
- QEMU reboot proof:
  - `regolith-init-kanshi.service` was `masked`
  - service was `inactive`
  - `systemctl --user --failed --no-legend` was empty

Proof note:

- `proof-notes/2026-07-04-regolith-session-kanshi-mask-qemu-proof.md`

Status: Done for the QEMU-tested path.

### regolith-inputd COSMIC backend proof

I tested `regolith-inputd` with a real COSMIC config write path. A temporary helper used `cosmic_config::ConfigSet` to toggle `input_default.scroll_config.natural_scroll`, then `regolith-inputd` applied that into Sway.

Proof result:

- Before daemon start, Sway did not reflect the COSMIC natural-scroll value.
- After starting staged `regolith-inputd`, Sway picked it up.
- Changing COSMIC config to `false` disabled natural scroll without daemon restart.
- Changing it back to `true` enabled it again.
- `regolith-inputd` stayed running.
- User failed units stayed empty.

Proof note:

- `proof-notes/2026-07-04-regolith-inputd-cosmic-mouse-live-watch-proof.md`

Status: Partial. Mouse live-watch works. Keyboard, touchpad, and input-source paths still need the same runtime proof.

### cosmic-osd source packaging

`cosmic-osd` source packaging now follows the Regolith/Voulage shape we agreed on.

Done:

- source format changed to quilt
- version set to `0.1.0-1-1regolith-resolute`
- `vendor.tar` source include metadata added
- source options added for generated/vendor/build paths
- source package build passed with:
  - `dpkg-buildpackage -S -us -uc -d`

Proof note:

- `proof-notes/2026-07-04-cosmic-osd-source-package-proof.md`

Status: Partial. Source package proof is done. Binary `.deb`, Voulage publish/install path, and lintian cleanup remain.

### Display persistence direction

Mentor clarified the expected model:

> COSMIC Settings / `cosmic-randr` applies the display configuration. Regolith monitors output changes and stores the persistence profile.

I checked the COSMIC side:

- `cosmic-settings` delegates display changes to `cosmic-randr`
- `cosmic-randr` uses `wlr-output-management-unstable-v1`
- COSMIC also uses output-management extensions through `cosmic-protocols`
- `cosmic-comp` writes output config after successful apply through `write_outputs(...)`

Then I checked the Regolith side:

- `regolith-displayd` already exposes `org.gnome.Mutter.DisplayConfig`
- it reads Sway output state through `swayipc-async`
- it writes kanshi profiles from the DBus `ApplyMonitorsConfig` path
- it already has a watcher loop for output/logical-monitor changes

The gap is narrow now: `regolith-displayd` can notice output changes, but it does not yet write a persistence profile from externally observed state.

Research note:

- `proof-notes/2026-07-04-regolith-displayd-display-persistence-monitoring.md`

Status: Direction clear. Implementation not finished yet.

### Display-change monitoring proof

In QEMU Regolith/Sway, I tested whether an output change made through `cosmic-randr` can be observed by Regolith.

Command path:

- monitor: `swaymsg -t subscribe '["output"]'`
- change: `cosmic-randr mode Virtual-1 1024 768 --refresh 60.004`
- restore: `cosmic-randr mode Virtual-1 1280 800 --refresh 74.994`

Result:

- Sway IPC emitted an output event.
- `cosmic-randr list` showed `1024x768 @ 60.004 Hz` after the change.
- restore returned to `1280x800 @ 74.994 Hz`
- user failed units stayed empty

Proof note:

- `proof-notes/2026-07-04-cosmic-randr-sway-output-monitor-proof.md`

Status: Sway IPC fallback monitoring works in QEMU. Wayland/wlr monitoring still needs investigation.

## Proposal alignment

Session bring-up and cleanup: Done for QEMU path

- COSMIC session helper cleanup is source-fixed.
- QEMU reboot proof is clean.
- Legacy display helper failure is removed from the tested path.

Input settings backend: Partial

- COSMIC backend direction is working.
- Mouse live-watch is proven.
- Other input categories still need runtime proof.

Display settings and persistence: Partial, active focus

- COSMIC display protocol path is understood.
- Regolith monitoring fallback is proven through Sway IPC.
- `regolith-displayd` is the first implementation target.
- Persistence implementation is still WIP.

Packaging/Voulage: Partial

- `cosmic-osd` source package proof is done.
- Binary package proof and install proof remain.

Cosmolith decision: Researched, not primary target right now

- `cosmolith` is useful as reference for native display watcher behavior.
- Current direction is still to make existing Regolith components interoperable first.
- `cosmolith` becomes the fallback only if `regolith-displayd` does not fit cleanly.

## What is not done yet

1. `regolith-displayd` observed-output persistence helper needs one more repair pass before it is usable.
2. We still need to decide whether COSMIC-session persistence should write kanshi profiles or Sway output config fragments.
3. We have not yet proven `regolith-displayd` can persist an externally observed `cosmic-randr` change without a write/reload loop.
4. True vanilla `cosmic.desktop` / `cosmic-comp` persistence proof is still pending.
5. `cosmic-osd` binary `.deb` proof is pending.
6. `regolith-inputd` needs runtime proof for keyboard, touchpad, and input-source behavior.

## Blockers and risks

- `regolith-displayd` implementation is WIP. The first helper refactor exposed a real type-boundary issue between `MonitorApply` and `LogicalMonitor`, so it needs a cleanup pass before more runtime testing.
- Current display proof is QEMU Regolith/Sway proof, not vanilla COSMIC proof.
- Full laptop boot should remain blocked until rollback/fallback is fully prepared and QEMU proof stays clean.
- Sway IPC monitoring is proven, but mentor preferred Wayland/wlr monitoring if practical. That still needs a separate source/runtime check.

## Midterm judgment

The project is in a good midterm state, but not because everything is complete. It is in a good state because the unknowns are now smaller and testable.

Before this phase, the display/input work still had a lot of "this should fit" reasoning. Now we have proof for:

- clean COSMIC session helper behavior in QEMU
- live COSMIC input config watching for mouse settings
- COSMIC display changes being visible through Sway IPC
- Regolith/Voulage-compatible source packaging for `cosmic-osd`

The next phase should be more implementation-heavy:

- finish `regolith-displayd` observed-output persistence
- prove the persistence loop end-to-end
- expand `regolith-inputd` runtime coverage
- finish binary package proof

## Mentor-facing summary

This is where the project stands at midterm.

I have QEMU proof for the COSMIC session cleanup: the old kanshi helper is masked in the COSMIC session path, and the reboot proof had no failed user units. I also proved that `regolith-inputd` can follow a real COSMIC config change for mouse natural scroll and apply it live into Sway without restarting the daemon.

For display persistence, I checked the COSMIC path first. `cosmic-settings` applies display changes through `cosmic-randr`, and `cosmic-randr` uses Wayland output-management. Then I tested the monitoring side in QEMU. A `cosmic-randr` mode change emitted a Sway IPC output event and restored cleanly, so Sway IPC works as a fallback monitoring path.

I also inspected `regolith-displayd`. It already watches Sway output state and already writes kanshi profiles through the DBus apply path, so it looks like the right first implementation target. The missing part is writing a profile from externally observed output changes. I started that helper path, but it still needs cleanup around the `MonitorApply` / `LogicalMonitor` boundary, so I am treating it as WIP and not claiming it as done.

Next I plan to finish that `regolith-displayd` helper, then test whether an observed `cosmic-randr` change can be persisted without creating a reload loop.
