# Patched display persistence QEMU proof - 2026-08-16

## Result

The patched `regolith-displayd` and `regolith-session-cosmic` packages were
installed in a disposable QEMU overlay. After a cold login, the COSMIC target
started `regolith-init-kanshi.service`. The Kanshi profile named
`Red_Hat,_Inc._QEMU_Monitor_Unknown` held `1024x768@60.004Hz`, and Sway IPC
reported `Virtual-1` at `1024x768 @ 60.004 Hz`.

This verifies the patched display-persistence path for one virtual QEMU
output. It does not increase the overall proposal count: criterion 7 remains
`Partial`, and the strict status remains **62-68%** and **4 of 12 criteria
fully met**.

## Source and package references

- `regolith-displayd` personal-fork branch:
  [`rahul/displayd-wayland-description-persistence-20260815`](https://github.com/Rahul-2k4/regolith-displayd/tree/rahul/displayd-wayland-description-persistence-20260815)
- `regolith-displayd` commit:
  [`55fd00c`](https://github.com/Rahul-2k4/regolith-displayd/commit/55fd00c)
- `regolith-session` personal-fork branch:
  [`rahul/cosmic-target-kanshi-persistence-20260815`](https://github.com/Rahul-2k4/regolith-session/tree/rahul/cosmic-target-kanshi-persistence-20260815)
- `regolith-session` commit:
  [`417cc63`](https://github.com/Rahul-2k4/regolith-session/commit/417cc63)

Installed Voulage packages:

```text
regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb
SHA-256: bb134bf2c60c679304de68ad5a446d91d403659ec80081fc09d97ba66054794d

regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb
SHA-256: 1b1e187523b962c0a8b5269136cf48c8eb421431dd4c68d478af7669e21609dc
```

## What the patches prove

- The displayd source fix preserves Wayland output descriptions when writing
  Kanshi profiles.
- The session target wiring makes Kanshi a COSMIC target dependency.
- The installed packages exercised that wiring after a cold QEMU login, with
  the expected profile and Sway output mode observed.

## Boundaries

This is QEMU-only evidence for one virtual output. It does not prove hardware,
multiple displays, hotplug, mixed DPI, native `cosmic-comp`, the COSMIC
Settings GUI, or a full display-manager lifecycle. The packages are unsigned
and unpublished. `regolith-init-kanshi.service` is a started helper; its
presence does not by itself prove the complete display-manager process
lifecycle.
