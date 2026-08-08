# COSMIC volume OSD - 2026-08-09

Changing the PipeWire default sink volume from 60% to 50% in the Sway-backed
COSMIC QEMU session produced a visible COSMIC volume overlay. The volume was
restored afterward.

This closes basic volume OSD rendering in QEMU. Media-key delivery, other OSD
types, native compositor behavior, and hardware graphics remain unverified.
