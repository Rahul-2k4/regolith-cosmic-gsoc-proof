# Live QEMU runtime recheck - 2026-08-09

Fresh read-only recheck of the installed Sway-backed COSMIC tuple:

- `cosmic-session.target`: active
- `regolith-cosmic.target`: active
- `regolith-init-inputd.service`: active, successful, zero restarts
- `regolith-init-displayd.service`: active, successful, zero restarts
- failed user units: none
- `dpkg --audit`: empty
- inputd and displayd carry the COSMIC desktop selector, Wayland display, and
  current Sway socket in their process environments

The fallback `swayidle + gtklock` owner was present, but `gtklock` was already
resident and `loginctl` reported `LockedHint=no`. A second timeout/recovery
cycle was not claimed from that state. Existing timeout-to-lock/unlock proof
remains separate.
