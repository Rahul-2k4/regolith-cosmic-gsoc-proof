# Physical hardware capability boundary

The read-only host audit found a physical touchpad, but the host is currently
running GNOME Wayland rather than the experimental Regolith/COSMIC session. No
Regolith or COSMIC compositor/helper processes are active, only the internal
display is connected, and the usual live input inspection tools are absent.

No host session, package, or display state was changed. Physical touchpad,
multi-display, and hotplug behavior therefore remain unverified. The supported
proof surface remains the reversible QEMU testbed until maintainers provide a
safe hardware test environment.
