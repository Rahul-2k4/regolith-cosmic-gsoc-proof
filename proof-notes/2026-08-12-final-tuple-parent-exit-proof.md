# Final tuple parent-exit proof

Date: 2026-08-12

A fresh copy-on-write QEMU overlay was created from the qualification image.
The staged Resolute session tuple was installed, the guest was rebooted, and
greetd IPC created a real COSMIC-backed Regolith session.

The run verified:

- `INSTALL_RC=0`;
- greetd authentication and session start succeeded;
- `cosmic-session`, Sway, and `regolith-inputd` were present;
- `XDG_SESSION_TYPE=wayland`;
- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`;
- `regolith-cosmic.target` was active;
- `regolith-init-inputd.service` and `regolith-init-displayd.service` were
  active;
- `regolith-gnome.target` was inactive;
- `dpkg --audit` was empty;
- the `Mod4+Space` launcher binding opened `ilia`;
- `Mod4+2` followed by `Mod4+1` produced the workspace sequence `1 -> 2 -> 1`;
- after a controlled Sway exit, `PARENT_EXIT_PASS` was reported and no
  `cosmic-session` or `dbus-run-session` parent remained.

The wrapper trap removed the overlay, staging directory, QEMU socket, and
temporary logs while preserving the base image. The displayd process name was
not matched with `pgrep` because Linux limits process-name matching to 15
characters; its target-owned systemd unit was active.

This is fresh QEMU proof for the staged package tuple and controlled parent
teardown. It does not prove display-manager-owned logout/shutdown, native
logind idle semantics, physical hardware, native `cosmic-comp` persistence,
package signing, publication, or an upstream merge.
