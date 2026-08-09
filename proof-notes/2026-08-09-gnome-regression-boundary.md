# GNOME coexistence boundary - 2026-08-09

The QEMU guest still contains the GNOME, Regolith COSMIC, and COSMIC session
entries. The GNOME launcher still points to `gnome-session --session=regolith-wayland`,
and `gnome-session-bin` remains installed.

The active session is the Sway-backed COSMIC path. The retained Regolith
surface is present through workspace state, `i3status-rs`, and Ilia. No failed
user units were reported.

A fresh visible GNOME login was not claimed. The current QEMU greeter
auto-starts COSMIC instead of reliably exposing a desktop selector. No greeter
files were edited and no desktop was forced over SSH.
