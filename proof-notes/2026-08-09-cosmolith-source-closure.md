# Cosmolith source closure - 2026-08-09

The personal fork branch
[`fix/startup-xkb-events-atomic`](https://github.com/Rahul-2k4/cosmolith/tree/fix/startup-xkb-events-atomic)
now contains the source-level Phase 2 closure.
This note records source-level status at capture time; the later package and
QEMU installation result is recorded in
[the cosmolith package/install boundary](2026-08-09-cosmolith-package-install-boundary.md).

Commits `2f53573` and `41a1af2` add structured `thiserror` context to the
startup and watcher paths, reject empty or whitespace-only session environment
values, recognize the composite `Regolith-Wayland:COSMIC:sway` session value,
and serialize the Rust 2024 environment tests.

Clean laptop verification passed:

```text
CARGO_NET_OFFLINE=true cargo check --locked --offline
CARGO_NET_OFFLINE=true cargo test --locked --offline
14 tests passed, 0 failed
git diff --check
```

This is source-level proof only. At capture time, the branch did not yet have
an accepted Voulage/Debian artifact. The later package result does not change
the source-level result recorded here, and signing or release readiness is not
claimed.
