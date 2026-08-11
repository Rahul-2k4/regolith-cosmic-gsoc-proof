# Displayd Wayland multi-output reconciliation proof

Date: 2026-08-12

The isolated displayd branch
[`rahul/displayd-wayland-multi-output-reconcile-20260812`](https://github.com/Rahul-2k4/regolith-displayd/tree/rahul/displayd-wayland-multi-output-reconcile-20260812)
starts from the frozen target-safe source `817becd` and adds the reviewed
Wayland output-head and output-mode removal tests.

Branch tip:
[`e4b2168`](https://github.com/Rahul-2k4/regolith-displayd/commit/e4b2168)

The tests cover:

- removing a finished output head from the next `done` snapshot;
- clearing a finished mode from the next snapshot;
- replacing the display manager's multi-output state when one head is removed.

Fresh Linux clone verification:

```text
cargo fmt --check
passed
cargo test --locked
51 library tests passed; 25 binary-target tests passed; 0 failed
git diff --check
passed
```

The existing `num_derive` non-local-definition warning remains. The diff is
test-only; production behavior and package metadata were unchanged.

Boundary: this strengthens Wayland/source reconciliation evidence. It does
not prove physical hotplug, mixed-DPI hardware, or a native COSMIC graphical
session.
