# Exact session-package QEMU proof

Date: 2026-08-17

The exact Resolute session-target tuple was installed on a disposable
copy-on-write overlay of the Pop!_OS qualification VM. The protected base
image was not changed. The tuple used the six session packages from Voulage
model `22105aa6`, plus `regolith-inputd 0.4.1-2-1regolith-resolute`,
`regolith-displayd 0.3.4-1-1regolith-resolute`, and
`regolith-wm-config 4.11.11-1regolith-resolute`.

The install returned `INSTALL_RC=0`. After reboot, the greetd client returned
`START_REPLY success`.

Runtime checks showed:

- `cosmic-session` and Sway running in a Wayland user session;
- `regolith-cosmic.target` active;
- `regolith-gnome.target` inactive;
- `regolith-init-inputd.service` and `regolith-init-displayd.service` active;
- no failed user units;
- empty `dpkg --audit`;
- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway` and
  `XDG_SESSION_TYPE=wayland` in Sway;
- `ilia` launched through the tested Sway binding.

The GNOME-target package owned the GNOME target and drop-in files. They were
not attributed to the COSMIC package.

This is graphical QEMU evidence from an overlay, not a clean archive install.
The base guest already contained an earlier tuple, so `dpkg` reported package
replacement warnings. The run does not prove that every GNOME runtime
package is excluded from the complete transaction, signed archive
publication, or hardware behavior. Criterion 9 therefore remains `Partial`.
