# Ubuntu 26.04 Resolute: GPU fix confirmed, new non-GPU blocker found

Date: 2026-08-19

## Scope

Direct follow-up to
`05_Testing_Proof/2026-08-18-ubuntu-2604-resolute-first-package-closure.md`,
which diagnosed a QEMU display-plumbing gap (no GPU render node) as the
reason the COSMIC/Sway compositor crashed after a successful greetd login on
Ubuntu 26.04 Resolute. This note tests the identified fix: relaunching the
same already-installed disk with `-device virtio-gpu-pci` instead of legacy
VGA.

## What the fix actually closed

Relaunched a copy-on-write overlay of `ubuntu-26.04-resolute-qual.qcow2`
with the corrected GPU device. Confirmed on two independent boots:

- `/dev/dri/` now shows `renderD128`/`renderD129` (previously: only a
  legacy VGA-only `card0`, no render node at all).
- The exact prior crash text — `libEGL warning: egl: failed to create dri2
  screen`, `DRI2: failed to create screen`, `DRM_IOCTL_MODE_CREATE_DUMB
  failed: Permission denied`, `gbm_bo_create failed: Permission denied` — is
  completely absent from this run's `journalctl` (grepped explicitly for
  `EGL|DRI2|gbm_bo_create|Permission denied|DRM_IOCTL`: zero hits).

**The diagnosed GPU-plumbing gap is genuinely fixed.** This is a real,
reusable result for any future Resolute QEMU work in this project, not
specific to this one attempt.

## What's still blocking, and why it's a different problem now

greetd login itself succeeded again (`CANCEL_REPLY success` → `REPLY
auth_message` → `REPLY success` → `START_REPLY success`), same as every
other successful login in this project. But the session still does not
reach a healthy running state, for two separate, non-GPU reasons:

**1. `cosmic-comp`/Sway exits with code 1, then 137 after a fast restart,
before ever creating an IPC socket.** The exact in-process crash reason
isn't visible in `journalctl --user` — `cosmic-session` only logs its own
supervisor messages ("process failed with code 1", "restarted process",
"cancelled"), not the child process's own stderr text. Getting the real
reason would need running `sway`/`cosmic-comp` manually to capture direct
stderr, which is new, open-ended debugging beyond "retry the known GPU
fix" — not attempted in this pass, per this project's rule against
thrashing past a clear escalation point.

**2. `regolith-inputd` fails independently, with an explicit
packaging/config mismatch, unrelated to whether Sway is alive:**

```
ERROR regolith_inputd > Failed to connect to Sway IPC during startup:
GNOME input backend selected, but regolith-inputd was built without the
gnome feature
```

This says the running configuration selected a GNOME input backend, but the
installed `regolith-inputd` binary (part of the mentor seven-package
bundle, hash `a277811b...`) was compiled without the `gnome` Cargo feature.
`XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway` was confirmed correctly
set on both the `dbus-run-session` and `cosmic-session` processes — so this
isn't a desktop-detection failure at the environment-variable level; either
the backend-selection logic elsewhere is picking GNOME anyway, or something
in this distro's Regolith config defaults to GNOME regardless of
`XDG_CURRENT_DESKTOP`. This is a real, distinct bug worth its own
investigation — it does not depend on the Sway crash and would likely
recur even if the Sway exit-1 issue were fixed separately.

`regolith-init-displayd.service` also failed, but purely as a downstream
consequence: it can't reach a Sway IPC socket that never existed
("`Sway IPC backend unavailable after 3 attempts: No such file or
directory`"). Its first attempt failed differently
("`Connection reset by peer`") because it connected to a socket right as
the first `cosmic-comp` process died under it. Not independent signal
beyond confirming Sway/cosmic-comp died.

Also failed, but expected and not new signal: `nm-applet` and
`org.gnome.Evolution-alarm-notify` autostart entries — both fail with
`cannot open display:`, a normal side effect of no live Wayland compositor,
not a Regolith-specific problem.

## Evidence

Serial console screenshot at the failure point (identical failure signature
to the pre-fix screenshot at the display layer — confirms this is genuinely
still failing, not a rounded-up success) and full transcript with exact log
excerpts, at
`/Users/rahul/Desktop/Gsoc/.tmp/ubuntu-2604-resolute-proof-20260818/attempt-2-gpu-fix/`
(`screen1.png`, `transcript.md`). Local-only artifacts, not yet copied into
a git-tracked location.

## Current state

QEMU stopped cleanly (HMP `system_powerdown`), overlay and all scratch
files removed from the remote host. The base disk
(`ubuntu-26.04-resolute-qual.qcow2`) was not modified — this attempt worked
entirely on a disposable overlay, so the disk still reflects the same state
as the prior proof note (Ubuntu 26.04 Resolute + `regolith-session-cosmic` +
mentor bundle installed, `regolith-inputd`'s GNOME/feature mismatch bug
already present in that installed state, not introduced by this attempt).
Remote disk space unchanged (34GB free). The Pop!_OS rig's disk hash was
reconfirmed unchanged:
`956b6634c73dad5e35891ad7417c3b81344aa58528861975ff3c3d8007a3a60d`.

The disposable guest's SSH access was restored via a fresh ed25519 keypair
injected offline with `virt-customize` (no host root/sudo needed), and a
fresh disposable password was set only because the greetd IPC client
requires real PAM auth. Neither value was printed or retained; both were
deleted from remote scratch space at the end of this run, per this
project's credential-handling rule.

## What this does and does not change

Strengthens the same already-`Partial` Criterion 9 evidence further: the
GPU-plumbing gap identified yesterday is now confirmed fixed and
documented, narrowing what's left to close a graphical Resolute login down
to two specific, named problems instead of one open unknown. The strict
ledger stays at **62-68%, 5/12** — this is progress within an existing
`Partial` criterion, not a new `Met` criterion. Graphical COSMIC login on
Ubuntu 26.04 Resolute remains unproven.

## Next steps, if pursued

1. **`regolith-inputd` GNOME/feature mismatch** — the more concretely
   scoped of the two remaining problems. Needs checking why a GNOME input
   backend gets selected on this distro despite `XDG_CURRENT_DESKTOP`
   correctly reporting COSMIC, and/or whether the shipped binary needs the
   `cosmic` feature enabled at build time for this specific config path.
2. **`cosmic-comp`/Sway exit code 1** — needs direct reproduction (run
   `sway -c /etc/regolith/sway/config` manually as the session user, outside
   the `cosmic-session` supervisor, to capture real stderr) rather than
   reading journald's already-filtered supervisor messages.

Both are real, bounded engineering tasks — neither is a repeat of
yesterday's GPU-plumbing problem.
