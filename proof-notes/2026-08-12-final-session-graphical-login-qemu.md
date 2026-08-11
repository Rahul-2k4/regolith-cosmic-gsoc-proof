# Final session graphical-login proof (QEMU)

Date: 2026-08-12

## Scope

The final `regolith-session` transition source
[`831596f`](https://github.com/Rahul-2k4/regolith-session/commit/831596f8f054a6904b0846b6a899912c6c13d465)
was built through the Resolute Voulage path and installed with the current
`regolith-inputd` routing source
[`271bc2a`](https://github.com/Rahul-2k4/regolith-inputd/commit/271bc2a4ae21546c9b79c1d1c9b1ffd454eb0c57),
displayd, and wm-config artifacts in a disposable QEMU overlay.
The canonical base image was not modified.

## Observed result

- `dpkg -i` completed with `INSTALL_RC=0`.
- The package transition replaced the old Sway-owned GNOME target file.
- Package state and the installed inputd binary hash were unchanged after a
  cold reboot.
- The installed inputd package was `0.4.1-2-1regolith-resolute`; its binary
  SHA-256 was
  `9c656284dfe10ea10c9bb82eb0ffd8a198209fbed01ce493e7f20f83fc6e334e` before
  and after reboot.
- greetd IPC returned successful cancellation, authentication, and session
  start responses for `regolith-session-cosmic-launch`.
- `cosmic-session`, Sway, and `regolith-inputd` were running.
- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway` and
  `XDG_SESSION_TYPE=wayland` were observed, with `WAYLAND_DISPLAY` and
  `SWAYSOCK` present.
- `regolith-cosmic.target` and both target-owned inputd/displayd helpers were
  active; `regolith-gnome.target` was inactive.
- Final `dpkg --audit` output was empty.
- QEMU and all temporary overlay artifacts were removed after the run; the
  base image remained present.

## Boundary

This is a QEMU graphical-login and package-transition proof. It does not claim
hardware validation, native `cosmic-comp` display mutation, complete display
hotplug/mixed-DPI coverage, signing, publication, or mentor acceptance. The
reviewer-facing proposal status remains **62-68%** with **4 of 12** criteria
fully met; this run strengthens the session/runtime evidence without changing
the strict headline.
