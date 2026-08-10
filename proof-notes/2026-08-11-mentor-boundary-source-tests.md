# Mentor-aligned source tests

Date: 2026-08-11

These changes strengthen the existing COSMIC source branches. They were tested
on the Linux development host after being pushed to Rahul's personal forks.
They are source and package tests, not hardware or graphical-session proof.

## Session package ownership

Commit [`ac673cd`](https://github.com/Rahul-2k4/regolith-session/commit/ac673cd85a471fe20b6fec09c07bf350c583fd59)
on branch `rahul/flashback-gnome-target-20260811` updates
`tests/regolith-systemd-targets.sh`.

The test derives the COSMIC-only paths from
`debian/regolith-session-cosmic.install`, checks each one is owned exactly
once there, and rejects exact or parent/child overlaps in every other
`regolith-session-*.install` manifest. Unsupported wildcard or
source/destination `dh_install` syntax fails explicitly instead of being
silently ignored.

Linux checks passed:

```text
bash tests/regolith-systemd-targets.sh
systemd target metadata: PASS
bash tests/regolith-cosmic-launch.sh
PASS
bash -n tests/regolith-systemd-targets.sh
PASS
git diff --check
PASS
```

This supports the mentor rule that COSMIC-only files stay out of common GNOME
session packages. It does not prove package installation or session startup.

## Inputd reverse sync

Commit [`5831628`](https://github.com/Rahul-2k4/regolith-inputd/commit/583162806af85590e2ce4f17380fe4bf2f092a92)
on branch `rahul/inputd-touchpad-lintian-reconciled-20260811` adds a direct
test of `CosmicTouchpadHandler::sync_from_sway_input`.

The test checks that Sway's acceleration and natural-scroll values are written
to the COSMIC touchpad configuration while the other seeded touchpad fields
and the separate override setting remain unchanged. The test restores
`XDG_CONFIG_HOME` even when it unwinds after a failure.

Linux checks passed:

```text
cargo fmt --check
PASS
cargo test --features cosmic touchpad_reverse_sync_persists_sway_values_without_overwriting_other_config -- --test-threads=1
1 passed; 0 failed
cargo test --features cosmic -- --test-threads=1
50 passed; 0 failed
git diff --check
PASS
```

This is source-level reverse-sync coverage. It does not prove a physical
touchpad or a live COSMIC Settings panel.

## Display observer lifecycle

Commit [`72f81ef`](https://github.com/Rahul-2k4/regolith-displayd/commit/72f81ef21af0b13a9cb77e790d8543c885e329e0)
on branch `worker/displayd-frozen-gap-20260810` adds tests for the existing
Wayland observer state collector.

The tests verify that a finished output head disappears from the next
publication and that removing its current mode clears the mode state. The
change is test-only. The brittle assertion against a private collector error
was removed during review.

Linux checks passed:

```text
cargo fmt --check
PASS
cargo test wayland_observer
9 library tests passed; 2 binary tests passed
git diff --check
PASS
```

The compiler still reports the repository's existing `num_derive`
`non_local_definitions` warning. No new warning was introduced by this test.
These tests do not prove native `cosmic-comp` mutation, physical hotplug, or
mixed-DPI behavior.

## Proposal status

The new evidence improves the source/package subgates only. The public status
therefore remains **4 of 12 criteria fully met** and **62-68% strict proposal
completion**, with all four fully met criteria limited to QEMU or package
evidence as already described in `WORK_PRODUCT.md`.
