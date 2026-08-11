# Direct Sway-exit parent lifecycle diagnostic

Date: 2026-08-11
Scope: disposable Ubuntu Resolute QEMU overlay using the reviewed Regolith
session/inputd/displayd tuple on the existing COSMIC base image

## Result

The latest bounded run reproduced the parent-session boundary. After the
direct Sway-exit request:

- the Sway IPC client returned an error while teardown was in progress;
- Sway and `regolith-session-cosmic-runtime` were absent;
- `regolith-cosmic.target`, `regolith-init-inputd.service`, and
  `regolith-init-displayd.service` were inactive;
- `cosmic-session` and its `dbus-run-session` parent were still present.

The target-owned helpers were healthy before the test: both were active,
reported `ExecMainStatus=0`, and the target had `Result=success`. The overlay
was removed by the harness and the canonical QEMU image was not modified.

## Package provenance boundary

This diagnostic installed the Regolith session, inputd, and displayd
artifacts. It did not replace or hash the pre-existing `cosmic-session`
package in the base image. Therefore this run proves the observed integrated
process boundary, but it does not bind that observation to the
`cosmic-session` source ref `a14abe3`. The source/package match remains an
open verification item; no `regolith-session` patch is justified from this
run.

## Relevant session evidence

Before the exit request, the process chain included:

```text
dbus-run-session -- /usr/bin/cosmic-session /usr/lib/regolith/regolith-session-cosmic-runtime sway -c /etc/regolith/sway/config
/usr/bin/cosmic-session /usr/lib/regolith/regolith-session-cosmic-runtime sway -c /etc/regolith/sway/config
/bin/bash /usr/lib/regolith/regolith-session-cosmic-runtime sway -c /etc/regolith/sway/config
sway -c /etc/regolith/sway/config
```

Ten seconds after the request, the exact `cosmic-session` and
`dbus-run-session` processes remained, while the runtime wrapper and Sway were
gone. The user journal included `cosmic-comp exited successfully`; the bounded
capture did not include a definitive `EXITING: session exited by request` or
`RESTARTING: session restarted by request` line.

## Interpretation

This is current QEMU evidence that direct compositor exit does not yet prove
complete parent-session teardown. It is not evidence that Regolith should kill
the outer `cosmic-session` process. The upstream session manager owns that
decision: its compositor-exit handler distinguishes a clean exit from a
restart request, and the session loop handles those requests separately.

- [COSMIC compositor-exit handling](https://github.com/pop-os/cosmic-session/blob/master/src/comp.rs)
- [COSMIC session restart loop](https://github.com/pop-os/cosmic-session/blob/master/src/main.rs)

The supported clean logout path remains the separately proven
`loginctl terminate-session` display-manager boundary. The strict proposal
status remains **62-68%**, with **4 of 12** criteria fully met.
