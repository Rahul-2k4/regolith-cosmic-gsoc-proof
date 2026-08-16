# Canonical inputd COSMIC xkb live-watch proof - 2026-08-17

Status: Pop!_OS 24.04/QEMU evidence; not hardware or Ubuntu Resolute proof.

## Inputs

- Source: [`regolith-inputd` `c658754e`](https://github.com/Rahul-2k4/regolith-inputd/commit/c658754ec10ac75422cba8e1c3517bba6075795f)
- Package: `regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb`
- Package SHA-256: `52dfaba9617f046100ae0b32392662254e5411cc8d3c7c1265c57358e1901d34`
- Installed binary SHA-256: `955bc3838fda47d69d14cd132cba64960b35a52323e88d201d986fbc75be6315`
- Guest: Pop!_OS 24.04 LTS in a disposable QEMU overlay

## Result

After a fresh package install, reboot, and greetd COSMIC/Sway login, the
existing COSMIC xkb helper wrote `com.system76.CosmicComp` `xkb_config` from
US/600/25 to French/AZERTY/540/31. Sway then reported `French`, repeat delay
`540`, and repeat rate `31`. The helper restored US/600/25, and Sway reported
`English (US)`, repeat delay `600`, and repeat rate `25` again.

The run also verified the COSMIC target and inputd/displayd helpers were
active, the GNOME target was inactive, `dpkg --audit` was empty, and no user
units were failed. `Mod4+Space` launched ilia and representative workspace
switching passed.

## Boundary

This closes current-package QEMU live input-source and keyboard-repeat
watcher coverage. The helper writes the COSMIC config layer directly; this is
not a claim that the COSMIC Settings GUI was exercised. Physical touchpad
reverse-sync, hardware coverage, Ubuntu Resolute graphical validation, and
release acceptance remain open.
