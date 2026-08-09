# Corrected Voulage model: real greeter QEMU proof

Date: 2026-08-10

## Scope

This note closes the provenance gap recorded on 2026-08-09. Voulage model
commit [`f38278934be32e9d051390b19cc416c3f320e7e5`](https://github.com/Rahul-2k4/voulage/commit/f38278934be32e9d051390b19cc416c3f320e7e5) pins `regolith-session` to source
`3523047b7c2f7a2ca4e3d1fd800c10c342ca7a19`.

The exact unsigned artifact was:

```text
regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb
SHA-256: ec71adc91778129feb9c31d23be7dd147d8b3d3713b0eb00d44b39316e8caea3
```

## Real greeter check

In the disposable QEMU guest, the COSMIC greeter default session was
temporarily set to `/usr/bin/regolith-session-cosmic-launch`. The guest was
rebooted, the session was allowed to start from the greeter, and the original
greeter configuration was restored afterward.

The guest reported:

```text
Package: regolith-session-cosmic
Architecture: amd64
Version: 1.2.0-1ubuntu1-1regolith-resolute
dpkg --audit: empty
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
```

The real greeter-launched process tree included `cosmic-session`, Sway,
`regolith-displayd`, `regolith-inputd`, `swayidle`, `cosmolith`, and
`cosmic-osd`. The proposal-owned units reported:

```text
regolith-cosmic.target: active, Result=success, NRestarts=0
regolith-init-inputd.service: active/running, Result=success, NRestarts=0
regolith-init-displayd.service: active/running, Result=success, NRestarts=0
```

One unrelated Polkit autostart unit was failed in the disposable guest. This
note claims only the health of the proposal-owned target and helpers.

The original greeter configuration was restored and its checksum matched the
saved baseline:

```text
bd16dbee80d86e086c0e234a7d970e160754a761fc481a1d85e5927195b13b14
```

## Boundary

This proves the corrected package through a QEMU real-greeter session. It does
not claim hardware validation, signed-release readiness, native COSMIC
Settings-panel mutation, complete display hotplug/mixed-DPI coverage, native
idle/logind semantics, or complete logout/shutdown behavior.
