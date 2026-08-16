# Final tuple graphical-login rerun

Date: 2026-08-16

## Scope

The current session target-start packages, reviewed `regolith-inputd`, final
manpage-cleaned `regolith-displayd`, and retained `regolith-wm-config` were
installed in a disposable QEMU overlay. The guest identity was
`Pop!_OS 24.04 LTS`, so this is QEMU runtime evidence and not Ubuntu Resolute
runtime evidence.

The protected base image was used only as a backing image. A temporary login
credential was prepared on a disposable intermediate overlay and was not
stored in the proof bundle.

## Result

- Package installation completed with `INSTALL_RC=0`.
- After reboot, the package versions and installed inputd binary hash were
  unchanged; the binary hash was
  `955bc3838fda47d69d14cd132cba64960b35a52323e88d201d986fbc75be6315`.
- greetd IPC returned `success` for the COSMIC/Sway session start.
- `cosmic-session` and Sway were running with
  `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`.
- `regolith-cosmic.target`, `regolith-init-inputd.service`, and
  `regolith-init-displayd.service` were active; `regolith-gnome.target` was
  inactive.
- `dpkg --audit` was empty after graphical login.
- HMP-injected `Mod4+Space` launched `ilia`.
- HMP-injected `Mod4+2` followed by `Mod4+1` produced workspace sequence
  `1 -> 2 -> 1`.

## Package hashes

- `regolith-session-cosmic`: `4015a52400f2c59c2eee33198175b88b54d6c660830273428036a16b324fac40`
- `regolith-inputd`: `52dfaba9617f046100ae0b32392662254e5411cc8d3c7c1265c57358e1901d34`
- `regolith-displayd`: `ae5249b164cae2c65499b7b38b31bdea050bfe28f7ab753e0233e9a4dde1d3ad`
- `regolith-wm-config`: `5631df471d19308af9bf78c3cd7391070967e750cafba00d58248b9e54c9031f`

The remaining session package hashes are recorded in the private vault proof
note.

## Limits

The QEMU process, overlay, and temporary staging data were removed, and the
protected base image was unchanged. This rerun strengthens the installed
session and keyboard workflow evidence in Pop!_OS QEMU. It does not close the
Ubuntu Resolute graphical gate, physical hardware matrix, display-profile
ownership decision, signing/publication, or mentor acceptance. The strict
project status remains `62-68%` and `4/12` criteria fully met.
