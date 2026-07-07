# regolith-inputd COSMIC mouse live-watch proof - 2026-07-04

Status: `QEMU proof passed`

## Claim

`regolith-inputd` COSMIC backend watches the real COSMIC config path and applies live mouse setting changes to Sway without restarting the daemon.

This proof covers the mouse `input_default.scroll_config.natural_scroll` path.

## Source under test

- repo: `regolith-inputd`
- branch: `rahul/cosmic-integration-source-of-truth`
- commit: `60291210637bdd17d44b3ff2ad1ed3bcf63fe5b2`
- build command:

```bash
cargo build --no-default-features --features cosmic
```

Built binary SHA:

```text
ddba0f63368b9a29cc5b3e244a0004b45c2de256ef7556e601c8aa13e23682af  target/debug/regolith-inputd
```

## Proof assets

Vault assets:

```text
05_Testing_Proof/assets/inputd-watch-6029121/
```

The temporary setter helper source is saved as:

```text
05_Testing_Proof/assets/inputd-watch-6029121/cosmic_set_mouse_natural_scroll.rs
```

The helper was not committed to `regolith-inputd`; it was only used for proof. It writes through `cosmic_config::ConfigSet::set`, not by manually overwriting the config file.

## Why a helper was needed

Read-only audit found:

- `cosmic-settings mouse` only opens the settings page.
- No `cosmic-config` setter CLI is installed in the guest.
- `cosmic-settings-daemon` exposes watch/read behavior, not a setter CLI for this field.

The proof helper uses the same COSMIC config API path:

```rust
let config = Config::new("com.system76.CosmicComp", 1)?;
let mut input_config: CosmicInputConfig = config.get("input_default").unwrap_or_default();
config.set("input_default", &input_config)?;
```

## Runtime environment

Guest environment used for `regolith-inputd`:

```text
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
WAYLAND_DISPLAY=wayland-1
SWAYSOCK=/run/user/1000/sway-ipc.1000.1210.sock
```

Source: `05-env-run.txt`

## Result

Before `regolith-inputd` startup, Sway pointer `natural_scroll` was disabled while the COSMIC config had natural scroll true. After the staged daemon started, Sway pointer state became enabled:

```text
10-after-inputd-start-inputs.json:
natural_scroll: enabled
```

Then the helper wrote `natural_scroll: Some(false)` through `cosmic_config::ConfigSet`.

COSMIC config after false write:

```ron
scroll_config: Some((
    natural_scroll: Some(false),
))
```

Sway state after false write:

```text
16-after-false-inputs.json:
natural_scroll: disabled
```

Then the helper restored `natural_scroll: Some(true)` through the same API.

COSMIC config after restore:

```ron
scroll_config: Some((
    natural_scroll: Some(true),
))
```

Sway state after restore:

```text
22-after-restore-inputs.json:
natural_scroll: enabled
```

## Health checks

- `regolith-inputd` stayed running during the false and restore writes.
- `07-inputd.stderr` stayed empty.
- `25-inputd.stderr-after-proof.txt` stayed empty.
- `23-failed-units-after-watcher-proof.txt` was 0 bytes.
- `27-failed-units-final.txt` was 0 bytes.
- Temporary proof daemon was stopped after capture.

## Caveats

- This is QEMU proof, not hardware proof.
- This proves mouse live-watch behavior. Keyboard/input-source startup apply is already proven separately at commit `6029121`, but keyboard/input-source live-watch still needs a separate proof if required.
- Touchpad state-change proof remains limited by the QEMU guest not exposing a real touchpad device.

## Decision

This closes the main `regolith-inputd` live watcher proof gap for mouse settings using a real COSMIC config writer path.
