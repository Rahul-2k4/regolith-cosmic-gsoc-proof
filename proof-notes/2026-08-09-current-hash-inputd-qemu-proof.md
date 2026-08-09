# Current-hash regolith-inputd QEMU proof

Date: 2026-08-09

This note records the sanitized QEMU evidence for the current `regolith-inputd`
source and package tuple.

## Tuple

- Source: [`regolith-inputd` commit `e32d049`](https://github.com/Rahul-2k4/regolith-inputd/commit/e32d049)
- Package version: `0.4.1-1-1regolith-resolute`
- Environment: QEMU guest running the Regolith Sway-backed COSMIC session

## Observed checks

After the package was installed in the guest, a cold COSMIC login was completed
from the current-hash package. The `regolith-inputd` user service was active,
and its process environment selected the COSMIC backend through the session's
COSMIC desktop environment. No GNOME backend was used for this login.

One live keyboard/input-source transition was applied while the session was
running. The changed input-source state was observed, then the original state
was restored successfully. This is a single live transition with restoration,
not a full input-device or lifecycle matrix.

## Boundaries

This is QEMU-only evidence. The guest exposed no touchpad device, so touchpad
runtime behavior is not proven. Reverse-sync runtime behavior is not proven.
There is no hardware result, signing or release result, or upstream merge
claimed by this note.
