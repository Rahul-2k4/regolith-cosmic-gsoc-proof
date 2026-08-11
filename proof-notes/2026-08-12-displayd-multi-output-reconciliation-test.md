# Displayd multi-output reconciliation test

Date: 2026-08-12

## Isolated source branch

The reviewed test branch is [`rahul/displayd-wayland-multi-output-test-20260812`](https://github.com/Rahul-2k4/regolith-displayd/tree/rahul/displayd-wayland-multi-output-test-20260812)
at [`3db213c`](https://github.com/Rahul-2k4/regolith-displayd/commit/3db213c93c1a1043f407f20da1f1210ae4fc80aa).
It is based on the frozen displayd observer source and adds only a regression
test.

## Covered behavior

The test starts with two enabled outputs, replaces the state with a Wayland
snapshot containing one output, and verifies that the serial, monitor list,
and logical-monitor list no longer retain the disconnected head. This guards
the multi-output removal path used before profile derivation.

## Laptop verification

The exact commit was fetched into a temporary detached worktree on the
development laptop. The following checks passed:

- `cargo fmt --check`
- `cargo test --lib`: 51 passed, 0 failed
- `cargo test --bin regolith-displayd`: 25 passed, 0 failed
- `git diff --check`

The existing `num_derive` non-local-definition compiler warning remains. It is
not introduced by this test and is not presented as a zero-warning result.

This is source/test proof only. It does not claim a compositor-backed
`zwlr_output_manager_v1` integration run, native COSMIC Settings UI proof,
hardware hotplug, mixed-DPI behavior, or native `cosmic-comp` validation.
