# QEMU greeter and guest-SSH boundary

Date: 2026-08-11

The qualification VM was launched from the recorded COSMIC disk and snapshot
path. Key-based guest SSH succeeded on the first bounded attempt. The
read-only guest check found the greeter only: no `cosmic-session`, Sway,
cosmolith, `regolith-init-inputd`, or `regolith-init-displayd` process was
present, and no `SWAYSOCK` was available.

No password, sudo, or greeter interaction was attempted. Since no user
COSMIC/Regolith session existed, no `cosmic-randr` or Wayland output mutation
was run. The VM was powered down through HMP, and the QEMU process, forwarded
SSH port, and monitor socket were absent afterward.

This confirms the guest-SSH and clean-shutdown path only. It does not prove
native display mutation, session lifecycle, hardware, or graphical login.
