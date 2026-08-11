# Display harness session discovery - 2026-08-12

## Result

The display proof harness was hardened to discover the live Sway runtime from
the compositor process instead of assuming that a non-interactive SSH shell
exports the session variables. It now:

- reads `XDG_RUNTIME_DIR`, `WAYLAND_DISPLAY`, and `SWAYSOCK` from the live Sway
  process when available;
- derives `WAYLAND_DISPLAY` from a `wayland-*` runtime socket when Sway omits
  that variable;
- verifies `swaymsg -t get_version` and `cosmic-randr list` before mutation;
- writes a clear discovery artifact when `cosmic-session` exists without a
  usable compositor.

The updated harness was run in a disposable QEMU COSMIC/Sway guest. It found
the live compositor, observed one output event, changed `Virtual-1` from
`1280x800 @ 74.994 Hz` to `1024x768 @ 60.004 Hz`, restored the original mode,
and reported zero failed user units.

The source changes are in commits `3c03fbc` and `14422a2`.

## Reproduction

From the public repository, provide a host and guest SSH command for a
disposable QEMU guest that is already logged into the Regolith/Sway session:

```sh
HOST=<qemu-host> \
GUEST='ssh -p <guest-port> user@127.0.0.1' \
REMOTE_PROOF_DIR=/tmp/regolith-cosmic-display-proof \
bash scripts/reproduce-qemu-display-proof.sh
```

The script stores the raw proof directory in the guest and restores the
original output mode on exit.

## Boundary

This validates session discovery and single-output QEMU observation. It does
not prove reboot persistence, physical hotplug, multiple physical displays,
mixed DPI, native `cosmic-comp`, or Kanshi activation.
