# Combined three-fix verification boot

Date: 2026-08-21
Scope: QEMU proof only. Nothing here ran on hardware.

This run exists to verify the three fixes that had only been proven
separately on 2026-08-19:

- `virtio-gpu-pci` for the Ubuntu 26.04 Resolute guest
- the `regolith-inputd` `XDG_CURRENT_DESKTOP` import fix
- `--no-install-recommends` on the mentor package bundle install path

The verification used one copy-on-write QEMU overlay, one fresh boot, and one
greetd login. All health checks below are from the same verification boot.

## Result

The boot reached a live COSMIC-backed Sway session and passed all nine checks:

- `dpkg -l | grep -Ei 'gdm3|gnome-shell|gnome-session-bin|ubuntu-session'`
  returned no matches
- `systemctl --user --failed` returned zero failed user units
- `regolith-cosmic.target` was active with the four COSMIC helpers running
- `regolith-inputd` imported the correct session identity and selected the
  COSMIC path
- Sway IPC answered successfully
- the guest exposed render nodes for the compositor path
- the earlier EGL or DRI2 crash text was absent from the journals
- no `cosmic-comp` or Sway exit-1 events were found in the journal slice
- `dpkg --audit` returned exit 0

Representative session identity from the verification boot:

```text
SWAYSOCK=/run/user/1000/sway-ipc.1000.2255.sock
WAYLAND_DISPLAY=wayland-1
XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway
```

Representative package-audit result:

```text
dpkg -l | grep -Ei 'gdm3|gnome-shell|gnome-session-bin|ubuntu-session'
  -> no matches
dpkg --audit
  -> exit 0
```

## Remaining GNOME-named packages

This run still found four GNOME-named packages installed:

- `gnome-icon-theme`
- `gnome-keyring`
- `gnome-themes-extra`
- `gnome-themes-extra-data`

They are not session or bootstrap leakage. At this stage they are retained as
documented runtime or theme dependencies, not counted as GNOME session bring-up
payload.

## Boundary

This closes the QEMU package-audit slice for the current proof bundle: no GNOME
session or bootstrap packages in the tested COSMIC session path, clean runtime
health, and clean package state on the same boot.

It does not claim:

- archive publication
- maintainer signing or acceptance
- hardware behavior
- a visible desktop render path; this run was headless

The installer script entry point was verified separately after its own preflight
fix. This note is only the combined QEMU package-audit and runtime result.
