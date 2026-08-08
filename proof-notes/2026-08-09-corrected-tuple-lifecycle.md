# Corrected COSMIC tuple lifecycle proof - 2026-08-09

This note covers the current Sway-backed QEMU path. It is not hardware or
native `cosmic-comp` proof.

## Current tuple

- `regolith-session`: `fc03e975`
- Voulage model: `954fe159`
- Session package SHA-256: `f3bc8588857b0361f0b1c22b33811576f650afd9611fffd1515e1f054a813d67`
- `regolith-inputd`: `e32d049`
- `regolith-displayd`: `e8cc8e`
- `regolith-wm-config`: `10225c5`

## QEMU result

After reboot and controlled relogin, the guest reported:

```text
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
WAYLAND_DISPLAY=wayland-1
regolith-cosmic.target              active
regolith-init-inputd.service        active, Result=success, NRestarts=0
regolith-init-displayd.service     active, Result=success, NRestarts=0
regolith-init-cosmic-idle.service  active, Result=success, NRestarts=0
systemctl --user --failed           empty
dpkg --audit                        empty
swayidle -w timeout 300 gtklock     one owner
```

No user `cosmic-comp` or `cosmic-idle` process was present. The old session's
deliberate teardown produced one `gtklock` broken-pipe message before relogin;
that race remains documented rather than hidden.

## Rollback

The earlier native-idle session package was installed and launched. Its
metadata included `cosmic-idle` and did not include the fallback executable.
The corrected session package was then reinstalled, and the fallback owner and
zero-restart project units returned after a fresh session.

This proves package-level rollback and restoration of the changed session
component. The available disk snapshots did not boot with the expected
Regolith package set, so no full-image rollback claim is made.

## GNOME coexistence and retained surface

The GNOME-backed session was also started in the same guest:

```text
gnome-session-binary --session=regolith-wayland
XDG_CURRENT_DESKTOP=Regolith-Wayland:GNOME:sway
regolith-gnome.target          active
regolith-wayland.target        active
regolith-init-inputd.service   active, Result=success, NRestarts=0
regolith-init-displayd.service active, Result=success, NRestarts=0
regolith-init-kanshi.service   inactive, Result=exec-condition
```

The only failed user unit was the unrelated guest tracker service. In the
COSMIC session, Sway IPC reported `Virtual-1` at `1280x800@74.994 Hz` and
workspace `1`; `i3status-rs` was running and the Ilia package/config was
present. Ilia's visible process could not be verified in headless QEMU.

## Remaining limits

Native compositor behavior, multi-display/hotplug/mixed-DPI, complete
keyboard layout/variant runtime, idle timeout/unlock lifecycle, visible
greeter selection, Ilia/OSD interaction, signing, and release publication are
still open.
