# COSMIC runtime teardown boundary - 2026-08-09

The reviewed session source is commit `bd418841a60b39e4a0db0b29636d7ecc680d2992`
on the personal-fork branch
[`rahul/cosmic-runtime-teardown-20260809`](https://github.com/Rahul-2k4/regolith-session/tree/rahul/cosmic-runtime-teardown-20260809).

The packaged QEMU test proved that sending `SIGTERM` to the Sway-backed
runtime cleans up the Regolith-owned compositor, `cosmolith`, helper process
groups, and COSMIC project targets. The package and QEMU result are recorded
in the private proof packet; this public note records the claim boundary only.

This is not a full logout proof. `cosmic-session` and `dbus-run-session` are
above the runtime wrapper and survived `swaymsg exit`; the testbed relaunched
the session instead of returning directly to the greeter. The child wrapper
does not claim ownership of that parent boundary until the mentor confirms the
correct launcher/session-manager design.

The later SIGKILL/late-helper hardening attempt was not integrated because its
focused test failed to start the helper deterministically. The reviewed
`bd41884` result remains the active evidence boundary.
