# Inputd COSMIC touchpad coverage audit

Frozen source: `regolith-inputd` `e32d0497f67fea94fb98f803c406c704191b741c`.

The existing source already covers COSMIC touchpad command mappings and partial
configuration cases with deterministic tests. Verification on the clean branch:

```text
cargo fmt --all -- --check                           PASS
cargo test --locked --no-default-features --features cosmic  43 passed
cargo test --locked --no-default-features --features gnome   20 passed
```

No code change was needed. This proves mapping coverage and the feature split,
not a physical touchpad, live compositor mutation, reverse synchronization,
QEMU device exposure, or release behavior.
