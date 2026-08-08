# Current tuple display persistence - 2026-08-08

With current displayd source `e8cc8e07e41e7b0b6dc2f1c9a7765876dfe0c46c`, the
Sway-backed session initially reported `1280x800 @ 74.994 Hz`. This command
returned exit `0`:

```sh
XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1 \
  cosmic-randr mode Virtual-1 1024 768 --refresh 60.004
```

The live output changed to `1024x768 @ 60.004 Hz`, and the persisted profile
changed to:

```text
output "Virtual-1" mode 1024x768@60.004Hz position 0,0 transform normal scale 1 enable
```

The updated profile remained after five seconds. Displayd stayed active with
`Result=success` and `NRestarts=0` during the mutation. The later restore
command returned exit `0` but did not change the Sway-backed output; cleanup
restored the profile file and a fresh session returned to `1280x800`.

This proves single-output observation and persistence in the Sway-backed QEMU
path. Native `cosmic-comp`, multi-display, hotplug, mixed DPI, and Settings
popup behavior remain separate boundaries.
