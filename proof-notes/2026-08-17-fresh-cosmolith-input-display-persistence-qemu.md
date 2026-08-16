# Fresh COSMolith input/display persistence proof - 2026-08-17

Status: Pop!_OS 24.04 in a disposable QEMU overlay; single virtual output.
The overlay was rebooted after installation and rebooted again after the live
mutation before the second greetd login.

## Exact inputs

- COSMolith source commit: `708ecab1`.
- Diagnostic libcosmic source commit: `6183239a`.
- Voulage model commit: `3f8f2959`.
- COSMolith package version: `0.1.0-1-1regolith-resolute`.
- COSMolith package SHA-256:
  `2e903bd96c7c6fe8539068b6f2df74e11d6436720f838b942a59b00672de4000`.
- Installed `/usr/bin/cosmolith` SHA-256:
  `8588c0ca3b8301fc86c0395ff7f5dc866baa48e0b7fee7eaa9f2600070769326`.
- Corrected complete-schema helper SHA-256:
  `dac4cece648e9b756f155ffc799345070e4edb142f478ba5ed45f7cce08330fd`.
- Session-context launcher SHA-256:
  `0414c8fa9899e1544944eec7b22645fc11f39713050a8fc03654a328bfca76d0`.

## Run

The corrected complete `XkbConfig` helper was installed and exercised through
the COSMolith launcher. The launcher inherited the active Sway
`XDG_CURRENT_DESKTOP` and D-Bus context. In the live session, Sway reported
French/AZERTY with repeat delay/rate `540/31`. The helper generated the
corresponding directives. After a second cold reboot and greetd login, the
same input state remained. The virtual display reported `1024x768` before and
after that reboot.

The harness emitted `SECOND_REBOOT`, `GUEST_SECOND_REBOOTED`,
`SECOND_GREETD_LOGIN`, and `COMBINED_PERSISTENCE_VERIFY` in that order. The
post-login verification then found the active unprivileged graphical session,
queried Sway through the post-login socket, and confirmed the COSMIC session,
Sway, inputd, and displayd processes and targets in `SESSION_PROOF`. This ties
the retained values to the second session rather than to the pre-reboot shell.

The COSMIC target, `regolith-inputd`, and `regolith-displayd` were active; the
GNOME target was inactive. No user units were failed, and `dpkg --audit` was
clean.

## Boundary

This is QEMU-only proof for one virtual output. It does not cover hardware
hotplug, mixed DPI, a physical touchpad, multimedia keys, or the native
COSMIC Settings GUI.

## Why this supersedes the earlier same-day result

The earlier combined note used a manually traced COSMolith launch that did not
inherit the active Sway session identity and D-Bus context. It received the
config event but left live Sway at `600/25`, so that result was retained as a
diagnostic failure. This run used the worker-reviewed launcher, verified its
local and remote SHA-256 values, and inherited the full Sway environment. The
live `540/31` result and the second cold reboot/login are therefore the current
QEMU evidence for this tuple; the older result is not a competing product
state.

Related package/runtime evidence: [canonical inputd live-watch proof](2026-08-17-inputd-canonical-xkb-live-watch-qemu.md).
