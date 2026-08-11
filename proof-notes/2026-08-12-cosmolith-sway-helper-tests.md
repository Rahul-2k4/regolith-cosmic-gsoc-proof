# Cosmolith Sway helper test proof

Date: 2026-08-12

The personal cosmolith branch
[`fix/startup-xkb-events-atomic`](https://github.com/Rahul-2k4/cosmolith/tree/fix/startup-xkb-events-atomic)
now includes reviewed unit coverage for the pure Sway command-formatting
helpers used by the COSMIC shortcut and keyboard paths.

Current branch tip:
[`8bf1960`](https://github.com/Rahul-2k4/cosmolith/commit/8bf1960)

The test delta covers:

- keyboard-option normalization;
- modifier plus XKB keysym binding formatting;
- representative close, focus, move, workspace, and custom actions.

Verification was run from a fresh Linux clone of the pushed branch:

```text
cargo test --lib -- --nocapture
10 passed; 0 failed
```

The full suite was then rerun:

```text
cargo test -- --nocapture
10 library tests passed; 10 binary-target tests passed; 0 failed; exit 0
```

`git diff --check` passed. `cargo fmt --check` remains non-zero because the
branch already contains unrelated formatting differences in existing files;
the first reported differences are outside this test delta. No runtime IPC,
dependency, package, or graphical-session behavior was changed by this slice.

This is source-level regression evidence only. It does not prove live
`cosmic-settings` UI delivery, multimedia keys, hardware input, or a native
COSMIC compositor session.
