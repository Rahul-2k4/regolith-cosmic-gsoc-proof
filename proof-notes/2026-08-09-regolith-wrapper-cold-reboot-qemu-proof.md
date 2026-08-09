# Regolith wrapper cold-reboot QEMU proof - 2026-08-09

## Scope

This note records a clean, disposable QEMU reboot check for the installed
`regolith-session-cosmic` launcher. The guest returned to the Regolith
Wayland COSMIC session after reboot.

## Observed result

- The `regolith-session-cosmic` launcher was installed and selected for the
  test session.
- A disposable QEMU guest was rebooted cleanly, then logged in again.
- The session reported `Regolith-Wayland:COSMIC:sway`.
- The COSMIC target owned the active `regolith-inputd` and `regolith-displayd`
  helpers. Both were active and reported `NRestarts=0`.
- The GNOME target remained separate and inactive for this COSMIC login.
- `dpkg --audit` was empty.
- The failed-unit list was empty.
- The session exposed one output: `Virtual-1`.

This is QEMU proof of the installed wrapper and target ownership after a cold
reboot. It does not establish hardware behavior or release readiness.

## Still open

Physical hardware, the Settings panel, full session lifecycle coverage,
package signing, and release approval remain open.
