# COSMIC keyboard event tests

The `cosmolith` source branch `fix/startup-xkb-events-atomic` now includes two
focused tests at commit `17d148746aa2169fc0cf732bf1ba951b8f406cb7`:

- a variant-only update such as `us` to `us+intl`
- a multi-layout update such as `us,fr` with matching variants

The tests exercise the existing `xkb_config` watcher-to-event conversion. They
do not add a second input daemon or change the GNOME path.

Checks completed:

- `cargo test`: 2 tests passed
- `cargo check`: passed
- `git diff --check`: passed
- `cargo fmt --check`: reports pre-existing unrelated formatting drift

This is source-level proof. Current packaged-session runtime proof and the
touchpad hardware boundary remain separate.
