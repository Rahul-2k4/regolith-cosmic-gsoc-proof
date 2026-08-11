# Inputd keyboard to input-source routing proof

Date: 2026-08-12

## Source and tests

- Repository: [`regolith-inputd`](https://github.com/Rahul-2k4/regolith-inputd)
- Branch: [`rahul/inputd-keyboard-source-routing-20260812`](https://github.com/Rahul-2k4/regolith-inputd/tree/rahul/inputd-keyboard-source-routing-20260812)
- Commit: [`271bc2a`](https://github.com/Rahul-2k4/regolith-inputd/commit/271bc2a4ae21546c9b79c1d1c9b1ffd454eb0c57)

The change adds a pure handler-index mapping and uses it in
`sync_input_settings`. Pointer events still route to handler `0`, keyboard
events route to handlers `1` and `3` (keyboard and input sources), and
touchpad events route to handler `2`. Unsupported input types still return the
existing error.

The regression test was added before the implementation. Linux verification
passed:

- COSMIC-only Cargo suite: `47 passed`
- all-feature Cargo suite: `50 passed`
- `cargo fmt --check`
- `git diff --check`

The Ubuntu Resolute Voulage binary build exited `0`. Its Lintian result was
not treated as clean: the only findings were `bogus-mail-host` warnings from
the generated build-host email. A separate focused shell check failed because
it asserts session-unit lines (`Wants=gnome-session.target` and
`WantedBy=regolith-wayland.target`) that do not belong to the inputd unit.

## Boundary

This proves internal event routing and source/build integrity. It does not
prove live Sway delivery, active-layout persistence, keyboard reverse-sync,
or graphical QEMU behavior.
