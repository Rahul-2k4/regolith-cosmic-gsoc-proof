# Proposal criteria audit

This note checks the submitted proposal against the current proof bundle. It
does not turn partial evidence into a completed criterion.

## Current table

| Criterion | Status | What the evidence actually covers |
|---|---|---|
| Fresh COSMIC-backed login | Met | QEMU graphical login |
| COSMIC path without GNOME bootstrap | Met | Tested QEMU path |
| Multi-display, hotplug, mixed DPI | Not met | Hardware proof is unavailable |
| Keyboard layout through `cosmic-settings` | Not met as written | Settings-panel path is blocked by a crash; config mutation is proven |
| Lock/unlock | Met | QEMU |
| OSDs | Partial | Volume OSD observed; media-key delivery remains open |
| Settings persistence | Partial | Single-output display profile only |
| Retained Regolith surface | Partial | `i3status-rs`, `ilia`, and representative workspace switching |
| GNOME package/bootstrap audit | Partial | Direct separation and documented survivors; full transitive closure remains open |
| Voulage build and release work | Partial | Builds and metadata proven; signing and publication remain open |
| Vendored offline Rust builds | Met | Package/build evidence |
| Keyboard-first `bindsym` workflow | Partial | Launcher and reversible workspace switch in QEMU; full matrix remains open |

The strict headline remains **62-68%**, with **4 of 12** criteria fully met.
The four complete criteria are backed by QEMU or package/build evidence. No
hardware result is claimed.

## Important boundary

The submitted PDF's statement that the legacy inputd/displayd helper units
should remain inactive is no longer the right acceptance test. Later mentor
direction calls for separate GNOME and COSMIC systemd targets, with the COSMIC
target owning compatible helpers while GNOME bootstrap stays out of the COSMIC
path. The current work product records that correction explicitly.

The newly built target-owned lifecycle packages are source/package evidence
only at this point. A disposable QEMU run reached guest SSH, but guest sudo
rejected the supplied credential before installation, so no new lifecycle
runtime claim was added.

See the [reviewer-facing work product](../WORK_PRODUCT.md) and the linked proof
notes for the commands and artifacts behind each row.
