# GNOME target split QEMU package transition

Date: 2026-08-11

The revised Ubuntu Resolute session packages from source commit
[`cbd810f`](https://github.com/Rahul-2k4/regolith-session/commit/cbd810f68f2713be91f1a61cdd326cd128a857c5)
were installed in a disposable QEMU overlay. The canonical base image was not
modified.

## Install and reboot

The revised `regolith-session-common`, `regolith-session-cosmic`, legacy Sway
and Flashback packages, and `regolith-session-gnome-targets` were copied to the
guest. `dpkg -i` configured the complete set with exit code `0`. The guest was
then cold rebooted and SSH became available on the second bounded readiness
attempt.

After reboot:

- all five session packages reported the candidate version
  `1.2.0-1ubuntu1-1-1regolith-resolute`;
- `dpkg --audit` produced no output;
- both GNOME target files were owned by `regolith-session-gnome-targets`;
- `regolith-session-common` had no GNOME or `regolith-(gnome|wayland)` payload;
- both user targets were inactive because the SSH check was outside a logged-in
  graphical user session.

The QEMU process, monitor socket, and overlay were shut down and removed after
the check. The base disk remains the source of truth.

## Boundary

This is revised package-transition and cold-reboot evidence. It does not claim
a graphical COSMIC/Sway login, native `cosmic-comp`, hardware coverage, signed
publication, or removal of the three documented transitive GNOME resource
packages. The proposal headline remains `4/12` fully met and strict
`62-68%`.
