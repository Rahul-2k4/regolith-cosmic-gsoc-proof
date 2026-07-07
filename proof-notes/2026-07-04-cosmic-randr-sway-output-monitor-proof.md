# cosmic-randr output monitoring proof - 2026-07-04

## Claim

In the current QEMU Regolith/COSMIC-on-Sway session, display changes applied through `cosmic-randr` can be observed through Sway IPC output monitoring.

This proves the fallback monitoring path for the mentor-directed display persistence design:

> COSMIC Settings / `cosmic-randr` applies the display change. Regolith monitors the resulting output state and stores a persistence profile.

## Environment

- Host: QEMU test host alias, redacted in this public note
- Guest: QEMU Pop/COSMIC qualification VM
- Guest display session: Regolith/Sway
- `XDG_CURRENT_DESKTOP`: `Regolith-Wayland:COSMIC:sway`
- Wayland display: `/run/user/1000/wayland-1`
- Sway IPC socket: `/run/user/1000/sway-ipc.1000.1221.sock`

## Commands

Baseline:

```bash
swaymsg -t get_outputs
cosmic-randr list
```

Monitor:

```bash
swaymsg -t subscribe '["output"]'
```

Reversible display change:

```bash
cosmic-randr mode Virtual-1 1024 768 --refresh 60.004
cosmic-randr mode Virtual-1 1280 800 --refresh 74.994
```

## Result

Sway IPC emitted an output event while `cosmic-randr` applied the display change:

```json
{ "change": "unspecified" }
```

State proof:

- Before: `cosmic-randr list` showed `1280x800 @ 74.994 Hz` as current.
- After change: `cosmic-randr list` showed `1024x768 @ 60.004 Hz` as current.
- After restore: `cosmic-randr list` showed `1280x800 @ 74.994 Hz` as current again.
- Final `systemctl --user --failed --no-legend` output was empty.

## Proof assets

The raw command outputs are retained in the private working vault. This public bundle includes the command path and the result excerpts needed to review the claim. The reproduction script in `scripts/reproduce-qemu-display-proof.sh` regenerates the same class of artifacts.

Files:

- `01-before-sway.json`
- `02-before-randr.txt`
- `03-sway-subscribe.jsonl`
- `03-sway-subscribe.err`
- `04-mode-1024.log`
- `05-after-mode-sway.json`
- `06-after-mode-randr.txt`
- `07-restore.log`
- `08-after-restore-sway.json`
- `09-after-restore-randr.txt`
- `10-user-failed.txt`

## Caveat

This is QEMU Regolith/Sway proof, not true vanilla `cosmic.desktop` / `cosmic-comp` persistence proof.

It proves Sway IPC can observe the output change caused by `cosmic-randr` in the current Regolith testbed. It does not yet prove whether vanilla COSMIC remembers changes after restarting `cosmic-comp`.

## Next

Implement a small source path in `regolith-displayd`:

- reuse the existing kanshi profile serialization
- persist observed output state from the watcher after real changes
- skip first baseline write
- avoid rewriting if profile content is unchanged
