# regolith-inputd feature-matrix verification - 2026-08-12

## Scope

This note records Linux source verification for the COSMIC/GNOME backend split
in `regolith-inputd`. It is not a hardware or full graphical-session result.

Source branch: `rahul/inputd-touchpad-lintian-reconciled-20260811`
Source commit: `271bc2a` (`Route keyboard events to input source handler`)

## Commands and results

From `regolith-inputd` on the project Linux laptop:

```text
cargo fmt --check                                      PASS
cargo test --locked --features cosmic                  50 passed, 0 failed
cargo test --locked --no-default-features --features cosmic
                                                        47 passed, 0 failed
cargo test --locked --no-default-features --features gnome
                                                        23 passed, 0 failed
git diff --check                                       PASS
```

The all-feature run covers the backend selector, COSMIC mouse/touchpad/XKB
watchers, reverse-sync preservation, event routing, and startup retry tests.
The feature-only runs confirm that the COSMIC and GNOME dependency gates build
and test independently.

The COSMIC-only build emits two Rust dead-code warnings for methods and a
trait that are not used by that feature combination. This is recorded rather
than hidden; it is separate from Debian Lintian status.

## Boundary

This proves source-level feature isolation and deterministic handler behavior on
Linux. It does not prove physical touchpad behavior, active-layout persistence,
full multimedia input, or a fresh QEMU runtime using this exact source commit.

## Reproduction

Use the project laptop checkout and run the commands above. The source branch
is available at:

<https://github.com/Rahul-2k4/regolith-inputd/tree/rahul/inputd-touchpad-lintian-reconciled-20260811>
