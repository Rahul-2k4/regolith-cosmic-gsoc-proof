# Mouse reverse-sync and session teardown source verification - 2026-08-11

This note records Linux verification for two isolated personal-fork branches.
It is source and test evidence, not a package-install or graphical-session
claim.

## `regolith-inputd`

- [Branch](https://github.com/Rahul-2k4/regolith-inputd/tree/rahul/inputd-mouse-reverse-sync-20260811)
- [Commit `66099f67`](https://github.com/Rahul-2k4/regolith-inputd/commit/66099f67a5498f3ad10fe65ef69eb6e8b57ac0c2)

The COSMIC mouse handler reverse-syncs Sway acceleration, natural-scroll, and
left-handed values into `input_default` while preserving unrelated settings.
The watcher gate is checked before opening Sway, and the tests exercise both
the real monitor callback path and the disabled path.

Linux results from a fresh laptop clone:

- 7 focused mouse/reverse-sync/watcher tests: `1 passed` each.
- `cargo test --features cosmic -- --test-threads=1`: `55 passed, 0 failed`.
- `cargo fmt --check`: exit `0`.
- `git diff --check`: exit `0`.

## `regolith-session`

- [Branch](https://github.com/Rahul-2k4/regolith-session/tree/rahul/cosmic-parent-ancestry-logout-20260811)
- [Commit `7fb72a8d`](https://github.com/Rahul-2k4/regolith-session/commit/7fb72a8d93e8b33fc6bfbca9292398252003b477)

The packaged COSMIC launcher sets an ownership marker. Cleanup then follows
only an exact `cosmic-session` ancestry from that launcher. It uses robust
`/proc` parsing, tracks PIDs early, and keeps cleanup idempotent. A generic
`dbus-run-session` without the marker is left alone. The GNOME path is
unchanged.

Linux results:

- Bash syntax checks: exit `0`.
- `bash tests/regolith-cosmic-launch.sh`: exit `0`.
- `bash tests/regolith-systemd-targets.sh`: `systemd target metadata: PASS`.
- `bash tests/regolith-cosmic-runtime-teardown.sh`: exit `0`.
- `git diff --check`: exit `0`.

## Boundary

These branches are on personal forks and are not upstream merges. This
strengthens source/test evidence only. It does not prove installed QEMU
runtime behavior for these exact heads, hardware behavior, package signing,
canonical publication, or final mentor acceptance. The work-product status
remains **62-68% strict completion** and **4 of 12 criteria fully met**.
