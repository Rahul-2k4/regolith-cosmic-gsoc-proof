# Installed display observation rerun - 2026-07-27

In the running COSMIC QEMU session, `Virtual-1` was changed with
`cosmic-randr` from `1280x800@74.994 Hz` to `1024x768@60.004 Hz`. Sway
reported the temporary `1024x768` geometry while `regolith-displayd` stayed
running. No failed user units appeared.

The original `1280x800@74.994 Hz` mode was then restored and marked current
and preferred by `cosmic-randr`.

This is reversible single-output observation proof. It does not, by itself,
prove profile persistence, native `cosmic-comp` behavior, multi-display,
hotplug, mixed DPI, or hardware behavior.
