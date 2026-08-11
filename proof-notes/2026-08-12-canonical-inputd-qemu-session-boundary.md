# Canonical inputd QEMU session boundary

Date: 2026-08-12

## Attempt

A disposable copy-on-write overlay was started from the qualification image
with SSH forwarding and a VNC-backed virtual display. The base image was not
modified. Guest SSH became ready.

The run stopped before installing or testing the canonical `regolith-inputd`
package because the guest did not reach a usable Regolith/COSMIC user session:

- `regolith-cosmic.target`: inactive
- `regolith-init-inputd.service`: inactive
- `regolith-init-displayd.service`: inactive
- `swaymsg -t get_inputs`: no Sway socket
- `sudo -n true`: password required
- the captured VNC framebuffer was a blank greeter frame

The guest journal showed `cosmic-comp` failing with `Backend initialized
without output` on the first headless launch. The VNC relaunch supplied a
virtual display, but did not produce a usable logged-in Regolith session.

## Disposition

No package was installed, no persistent configuration was changed, and the
overlay, monitor socket, process, and temporary framebuffer were removed.
This is a runtime boundary, not canonical inputd proof. The source-level
canonical proof remains the separate `c658754` reconciliation note.
