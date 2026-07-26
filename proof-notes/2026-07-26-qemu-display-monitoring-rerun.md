# QEMU display monitoring rerun - 2026-07-26

## Result

The Pop/COSMIC qualification VM was started from the repository-local QEMU
setup. In the Regolith/COSMIC-on-Sway session, the proof changed
`Virtual-1` from `1280x800@74.994 Hz` to `1024x768@60.004 Hz` with
`cosmic-randr`, observed the Sway IPC output event, and restored the original
mode tuple.

Observed event:

```json
{ "change": "unspecified" }
```

The COSMIC session kept `regolith-init-kanshi.service` masked. Failed-user-unit
output was empty before and after the test.

## Reproduce

Run the public script from the repository root after starting a QEMU guest and
logging into the Regolith/Sway COSMIC session:

```bash
bash scripts/reproduce-qemu-display-proof.sh
```

The script restores the configured mode tuple through its cleanup path if the
temporary mode step fails.

## Claim boundary

This is single-output Sway-observation proof in QEMU. It does not prove native
`cosmic.desktop`/`cosmic-comp` persistence, multi-display or hotplug behavior,
mixed-DPI behavior, or full-laptop hardware behavior.
