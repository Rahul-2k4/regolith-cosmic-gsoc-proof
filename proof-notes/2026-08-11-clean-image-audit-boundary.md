# Clean-image audit boundary - 2026-08-11

## Result

The retained QEMU images do not provide a pristine base for the proposal's
clean-install criterion.

The image labelled `regolith-clean-install-20260711.qcow2` was inspected
read-only through a disposable overlay. Before any current-tuple install, its
filesystem already contained `gnome-session-bin`, `gnome-settings-daemon`,
Regolith packages including `regolith-session-sway`, `regolith-inputd`, and
`regolith-displayd`, plus `regolith-wayland.desktop`.

The image labelled `pop-cosmic-fresh-20260712.qcow2` was booted through a
disposable overlay and unlocked through the existing QEMU test path. Its guest
SSH became available as the pre-existing `regolith` user, and the package
state included Noble Regolith packages, GNOME session packages, and the Sway
session before any current reviewed tuple was installed.

## Boundary

Neither image can support the claim “current reviewed tuple installed on an
empty target-distro base”. The overlay boots were shut down cleanly and the
base images were not modified. A new verified empty Trixie or Ubuntu 26.04
image is still required for that proposal gate.
