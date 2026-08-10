# COSMIC idle ownership and fallback QEMU proof

Date: 2026-08-10

The canonical `regolith-wm-config` idle-ownership test passed at source
`10225c05`. The QEMU session uses the supported `swayidle` plus `gtklock`
fallback. It reported:

- the COSMIC target and both Regolith helper units active;
- `swayidle` running;
- no `cosmic-idle` or `gnome-session-bin` process;
- the GNOME target inactive; and
- no failed user units.

This confirms the fallback ownership and GNOME coexistence boundary for the
Sway-backed QEMU session. Native `cosmic-idle` timeout/logind behavior,
physical hardware, and complete logout/shutdown semantics remain open.
