# COSMIC Wayland observer persistence QEMU proof

Date: 2026-08-04

## Result

The reviewed `regolith-displayd` Wayland observer passed a single-output
COSMIC QEMU persistence check. It uses `zwlr_output_manager_v1` snapshots and
the COSMIC-only side-effect path, without reloading Kanshi or reverting the
output.

This is not proof of the COSMIC Settings panel, multi-display hotplug, mixed
DPI, full package closure, or hardware behavior.

## Inputs

- Source: `regolith-displayd` commit `c744f55c9c60f50ff5cb31209a8654ff7a8879ca`
- Branch: `rahul/cosmic-wayland-persist-without-kanshi-20260804`
- Package version: `0.3.4-1-1regolith-resolute`
- Package SHA-256: `98fc7b4ff4615b143283f2d3a51e9484fb1deb136d25122105255b900b809ddb`

The source passed formatting, locked tests, and diff checks. The package build
completed; known local-builder Lintian findings remained.

## QEMU evidence

After a fresh reboot, the displayd journal reported:

```text
Starting Wayland output observation for COSMIC
Emiting monitor changed
```

The service stayed active with `Result=success` and `NRestarts=0`, while
Kanshi stayed inactive.

The reversible mode change was:

```text
cosmic-randr mode Virtual-1 1024 768 --refresh 60 --pos-x 0 --pos-y 0 --scale 1
```

The stored profile and live output converged to `1024x768@60.004Hz`. The
original `1280x800@74.994Hz` mode was then restored and remained active after
the observer retry interval.

## Boundary

This proves the observer and single-output COSMIC persistence path on the
reviewed branch. The current final corrected-session tuple uses a later
displayd pin, so this note must not be presented as proof that the observer is
already part of that frozen tuple.
