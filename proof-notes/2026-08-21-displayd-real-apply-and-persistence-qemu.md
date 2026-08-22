# displayd real apply and persistence under QEMU

Date: 2026-08-21
Scope: QEMU proof only. Nothing here ran on hardware.

This run answers a narrower question than the earlier headless display notes:
can the live `ApplyMonitorsConfig` path change a real output state and can that
state survive a cold reboot?

The methodology change that made this possible was simple. Earlier display runs
used `-display none`, which gives the guest no real sink. This run used
`-device virtio-vga -vnc 127.0.0.1:<port>` so the guest had one active output
with an advertised mode list.

## What was proven

On the live compositor, `ApplyMonitorsConfig` changed the active output state
for a real QEMU display:

- `verify` returned success and left the session unchanged
- `apply-temporary` changed the output from the session default `1280x800` to
  `1920x1080`
- `apply-persistent` changed the output to `3840x2160` at scale `2.0`
- a second `apply-persistent` changed the output to `1920x1080` at scale `1.25`
- a wrong-serial control request failed with `InvalidArgs`, as expected

Representative live state after the final persistent apply:

```text
mode=1920x1080
scale=1.25
rect=1536x864
active=true
```

## Persistence result

The session then cold-booted twice with the same QEMU arguments. After each
fresh greetd login, Sway reported the persisted output state from the earlier
`apply-persistent` call rather than the default session state:

- `mode=1920x1080`
- `scale=1.25`
- `active=true`

That is real persistence for resolution and scale on the tested single-output
QEMU path.

## Bug found

The requested refresh rate did not persist correctly.

Requested:

```text
1920x1080@60Hz
```

Observed after reboot:

```text
1920x1080@50Hz
```

`60Hz` was present in the advertised mode list, so this was not an unavailable
mode. The current evidence says the mode-selection path persisted the right
resolution and scale but selected the wrong refresh rate.

## Boundary

This run strengthens the display evidence, but it does not close either broad
display criterion on its own:

- multi-display hotplug is still open
- mixed-DPI on simultaneous real outputs is still open
- hardware proof is still open

Most importantly, the refresh-rate mismatch means the broad "settings persist
across reboot" claim is not cleanly true. Resolution and scale persisted
correctly. Refresh rate did not. That keeps the proposal ledger at `5/12`
instead of `6/12`.
