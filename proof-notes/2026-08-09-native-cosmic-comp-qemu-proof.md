# Native COSMIC compositor QEMU proof

## Scope

This note proves the packaged native COSMIC compositor on a real QEMU seat.
It does not claim that the Regolith experimental wrapper should launch
`cosmic-comp`; that project path remains `cosmic-session` plus Sway under the
mentor-approved interoperability design.

## Method

The disposable guest's greetd `default_session` was temporarily pointed at
`/usr/bin/start-cosmic`. The original greeter configuration was backed up and
restored after the capture. No canonical source tree or host session was
changed.

## Observed result

- A visible COSMIC desktop rendered on the QEMU seat.
- User-owned `/usr/bin/cosmic-session` started successfully.
- User-owned `cosmic-comp` started as its compositor child.
- The native session environment contained `XDG_CURRENT_DESKTOP=COSMIC`.
- No Sway process or `regolith-session-cosmic-runtime` process was present.
- `~/.local/state/cosmic-comp/outputs.ron` was present.

The screenshot and raw process output remain in the private vault because
they are environment-specific artifacts. This public note records the claim
boundary; it does not represent native Regolith-wrapper validation.

## Status

**Pass for native `cosmic-comp` compositor runtime on the QEMU seat.** Native
Regolith-wrapper runtime, reboot ordering, physical display behavior, and the
remaining release gates are still open.
