# Sway-exit parent-session lifecycle boundary

Date: 2026-08-10

## Scope

This is a bounded QEMU test of the Sway-backed COSMIC wrapper. It is a
boundary result, not a clean-logout claim and not hardware proof.

## Procedure

1. Start from a logged-in QEMU Regolith/COSMIC session.
2. Query the live Sway IPC socket and confirm the Sway version.
3. Run `SWAYSOCK=<live-socket> swaymsg exit`.
4. Wait eight seconds and inspect the user session, COSMIC target, helper
   services, and parent processes.
5. Reset the disposable QEMU guest through HMP and verify the greeter state.

The compositor did not export `SWAYSOCK` in its process environment, so the
test used the socket discovered under `/run/user/1000/`. This is recorded to
avoid confusing an environment-export issue with a lifecycle result.

## Observed result

- `swaymsg -t get_version` returned Sway `1.9`.
- `swaymsg exit` closed the compositor IPC connection and returned non-zero.
- After eight seconds, `regolith-cosmic.target`, `regolith-init-inputd.service`,
  and `regolith-init-displayd.service` were inactive.
- Sway, the Regolith wrapper, `regolith-inputd`, and `regolith-displayd` were
  absent.
- The parent `cosmic-session` and `dbus-run-session` processes remained alive.
- The normal display-manager session ID was not available for termination;
  HMP reset restored the disposable guest to the `cosmic-greeter` with no
  project session processes and an inactive COSMIC target.

## Result

`regolith-session` correctly loses ownership of the compositor and helper
processes, but direct Sway exit does not terminate the parent session-bus and
`cosmic-session` processes. The parent-session lifecycle remains `Partial`.
Display-manager-owned `loginctl terminate-session` remains the separately
proven clean logout path.

No source code or persistent guest configuration was changed.
