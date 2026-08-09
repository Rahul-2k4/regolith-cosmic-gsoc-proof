# Final package tuple: two sequential QEMU cold logins - 2026-08-09

## Scope

This note records two sequential cold boots of a disposable QEMU guest using
the final Regolith package tuple and the installed `regolith-session-cosmic`
wrapper. Both boots returned to the Sway-backed Regolith Wayland COSMIC
session.

## Installed tuple

- `regolith-displayd 0.3.4-1-1regolith-resolute`
- `regolith-inputd 0.4.1-1-1regolith-resolute`
- `regolith-session-cosmic 1.2.0-1ubuntu1-1regolith-resolute`
- `regolith-wm-config 4.11.11-1regolith-resolute`

## Result

For both sequential cold logins:

- the COSMIC target and its helper units were active;
- `regolith-inputd` and `regolith-displayd` reported `Result=success`;
- both helper units reported `NRestarts=0`;
- `dpkg --audit` was empty; and
- no failed user units remained after the reset.

The fallback session used `swayidle + gtklock`.

## Boundary

This is Sway-backed QEMU wrapper proof. Native `cosmic-comp` has separate
QEMU proof, but this note does not combine the two paths. Hardware behavior,
Settings-panel validation, the complete session/idle/lock lifecycle, and
package signing or release readiness remain open.
