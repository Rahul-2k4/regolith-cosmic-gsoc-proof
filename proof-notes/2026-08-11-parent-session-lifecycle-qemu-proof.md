# Parent COSMIC session lifecycle QEMU proof

Date: 2026-08-11
Scope: disposable QEMU overlay with the retained Resolute session tuple

## Result

The corrected session package tuple installed with `dpkg -i` exit `0`, survived
a cold reboot, and reached a COSMIC-backed Sway login through greetd. The tuple
used the separate `regolith-session-gnome-targets` package and the current
inputd package. `dpkg --audit` was empty before login and after reboot.

The installed inputd binary hash was unchanged across reboot:

```text
9c656284dfe10ea10c9bb82eb0ffd8a198209fbed01ce493e7f20f83fc6e334e
```

The transition-relevant session artifacts used package version
`1.2.0-1ubuntu1-1regolith-resolute`:

| Package | SHA-256 |
|---|---|
| `regolith-session-common` | `d5a6d8e6088e1d534c1a276a116d573d1ff55a20a9ad947d56dab41cd02ab74f` |
| `regolith-session-cosmic` | `39814dc2bfc98058d10e03c6228cc83562d2790078e7ec3d9e0c3816351cedff` |
| `regolith-session-sway` | `78d4df905d85b62533d6279006830ddf22dde10616df8334816573dac42c1f0f` |
| `regolith-session-gnome-targets` | `f3115bcb1f17002d539e3d5b2c0a3f363acb433a0963fdab3937775c92d0cc30` |

## Runtime evidence

After login, the guest reported:

- `cosmic-session`, Sway, and `regolith-inputd` running.
- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`.
- `XDG_SESSION_TYPE=wayland` with a live Sway IPC socket.
- `regolith-cosmic.target` and both Regolith helper services active.
- `regolith-gnome.target` inactive.

The harness then sent `swaymsg exit` through the live Sway socket. The IPC
client returned an error while teardown was in progress, so the return code is
not presented as a successful command acknowledgment. An independent audit ten
seconds later reported:

```text
COSMIC_PARENT_STOPPED
SWAY_STOPPED
inactive
active
failed
```

This shows the tested runtime stopped the exact `cosmic-session` parent after
the Sway exit path. The `failed` helper state is retained as a limitation: this
is not a claim of clean displayd shutdown or complete logout semantics.

The QEMU overlay, monitor socket, staging directory, and log were removed, and
the canonical base image was left intact.

## Boundaries

This is QEMU-only evidence. It does not prove native COSMIC/logind semantics,
hardware behavior, package signing, canonical publication, or mentor
acceptance. It improves lifecycle coverage but does not change the strict
headline of `62-68%` and `4 of 12` fully met criteria.
