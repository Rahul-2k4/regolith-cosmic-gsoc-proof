# `regolith-inputd` canonical COSMIC QEMU runtime

Date: 2026-08-16
Status: Pop!_OS/QEMU evidence; not Ubuntu Resolute or hardware proof

## Inputs

- Source branch: [`rahul/inputd-cosmic-canonical-20260812`](https://github.com/Rahul-2k4/regolith-inputd/tree/rahul/inputd-cosmic-canonical-20260812)
- Source commit: [`c658754e`](https://github.com/Rahul-2k4/regolith-inputd/commit/c658754ec10ac75422cba8e1c3517bba6075795f)
- Guest: Pop!_OS 24.04 LTS in a disposable QEMU overlay
- Package: `regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb`
- Package SHA-256: `52dfaba9617f046100ae0b32392662254e5411cc8d3c7c1265c57358e1901d34`
- Installed binary SHA-256: `955bc3838fda47d69d14cd132cba64960b35a52323e88d201d986fbc75be6315`

## Observed

- Package installation exited `0` and the guest rebooted successfully.
- greetd started the COSMIC/Sway session.
- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway` was present in Sway and
  `regolith-inputd`.
- `regolith-cosmic.target`, `regolith-init-inputd.service`, and
  `regolith-init-displayd.service` were active.
- `regolith-gnome.target` was inactive and `dpkg --audit` was empty.
- `Mod4+Space` launched ilia.
- `Mod4+2` followed by `Mod4+1` produced workspace sequence `1 -> 2 -> 1`.

## Limits

This proves the packaged COSMIC backend/session contract in Pop!_OS QEMU. It
does not prove live COSMIC input-source mutation, physical touchpad reverse
sync, Ubuntu Resolute graphical login, or hardware behavior. The QEMU overlay
and socket were removed; the protected base image was not modified.

The wrapper emitted the complete proof before a shell-specific cleanup mistake
caused a nonzero wrapper exit: the remote default shell is zsh, while the
wrapper used Bash `PIPESTATUS`. The temporary preparation files were then
removed explicitly. No project or guest credential was exposed.
