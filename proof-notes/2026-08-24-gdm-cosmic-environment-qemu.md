# GDM COSMIC environment handoff — QEMU — 2026-08-24

This is a disposable Ubuntu Resolute QEMU run. It follows the mentor’s
required order for the Regolith unstable archive and checks the COSMIC session
through GDM.

## Upgrade order

The signed Regolith `ubuntu/unstable` source was enabled. The older
`sway-audio-idle-inhibit` package was installed first so its global
`default.target.wants` link could be reproduced. The user unit was disabled
with `systemctl --user disable --now`, then the confirmed stale link was
removed manually. The helper was upgraded to
`2.0.1-1regolith-resolute` from `unstable`.

After reboot, the helper was disabled and inactive, the wants link was absent,
the user failed-unit list was empty, and `dpkg --audit` was clean.

## GDM COSMIC login

The exact session package was installed and GDM autologin was enabled for the
COSMIC session. The fresh boot produced this process chain:

```text
gdm-wayland-session
  -> regolith-session-cosmic-launch
    -> dbus-run-session
      -> regolith-session-cosmic-bus
        -> cosmic-session
          -> sway
```

The session bus contained:

```text
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
XDG_SESSION_DESKTOP=cosmic
XDG_SESSION_TYPE=wayland
```

Both user services stayed active:

```text
regolith-init-inputd.service: active
regolith-init-displayd.service: active
systemctl --user --failed: empty
dpkg --audit: empty
```

The guest was restored to greetd. The disposable QEMU process was stopped and
`qemu-img check` reported no image errors.

## Source and package refs

```text
GDM environment fix:       regolith-session 57464d1
Test fixture hardening:    regolith-session 4da4ce3
GDM-tested package:        1.2.0-1ubuntu1-1-1regolith-resolute
GDM-tested SHA-256:        0786702d098854365ed1ea7404e6ea4aa1df4ea63e891c7a26f928d89e0e15e5
Final rebuilt SHA-256:     bfd7e2788cf7d5fda2a974e2c34d5da9aa979711f64fbdba9a7610c7bc6178a9
```

The final branch also passes all 11 session shell tests on macOS and Linux.
The test-only portability change does not alter the installed runtime files.

## Boundary

This is QEMU evidence. It does not claim native hardware, multi-display or
hotplug behavior, lock/idle replacement, archive signing, or archive
publication.
