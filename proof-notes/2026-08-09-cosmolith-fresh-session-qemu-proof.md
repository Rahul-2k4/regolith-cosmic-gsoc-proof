# Cosmolith fresh-session QEMU proof - 2026-08-09

## Scope

This note records a sanitized QEMU proof of the installed cosmolith package
after a fresh graphical login. It proves the packaged runtime observation in
the Regolith/Sway-backed COSMIC session only. It does not claim hardware,
upstream, `main`, or release status.

## Installed package

- Package: `cosmolith 0.1.0-1-1regolith-resolute`
- Executable observed: `/usr/bin/cosmolith`

## Runtime observation

After the graphical QEMU login:

- a running `/usr/bin/cosmolith` process was observed;
- its environment contained
  `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`;
- its environment exposed the expected Wayland and Sway sockets;
- `regolith-cosmic.target` was active;
- the inputd and displayd helper units were active with `NRestarts=0`;
- `dpkg --audit` was empty; and
- the failed user-unit audit was empty.

This is packaged cosmolith runtime QEMU proof after a fresh graphical login.

## Boundaries

Signing, canonical publication, reverse-sync runtime behavior, native Settings
panel validation, the full display matrix, and hardware validation remain
open. No upstream PR, `main` merge, or release claim is made.
