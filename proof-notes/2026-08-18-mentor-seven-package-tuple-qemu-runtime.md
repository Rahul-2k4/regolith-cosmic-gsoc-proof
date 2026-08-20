# Mentor seven-package tuple QEMU runtime proof

Date: 2026-08-18

## Scope

This is the first end-to-end install→reboot→greetd-login→verify run of the
exact seven-package bundle in `artifacts/mentor-test-2026-08-18.sha256`, in a
disposable Pop!_OS 24.04 QEMU overlay. Two prior attempts on 2026-08-18 did
not reach this result; both are recorded here rather than discarded.

## Attempt 1 — blocked before install

The guest credential file used by the harness was provisioned with an empty
value (a `read -p` prompt behaved differently than expected in the operator's
shell and silently captured nothing). No install, reboot, or login was
attempted. Package transfer and SHA-256 verification (local → remote → guest,
three independent checks) passed. Cleanup completed; base image confirmed
unchanged.

## Attempt 2 — real defect found: `regolith-session-common` version regression

With the credential fixed, the run reached `apt-get install -y
<7 files>.deb` and it failed with exit code `100`:

```
The following packages will be DOWNGRADED:
  regolith-session-common
E: Packages were downgraded and -y was used without --allow-downgrades.
```

Root cause: the base QEMU image already has `regolith-session-common`
installed at `1.2.0-1ubuntu1-1-1regolith-resolute` (SHA-256 `dfa3a8ac...`, per
`artifacts/README.md`, from the 2026-08-12 session-repin build). The
`mentor-test-2026-08-18.sha256` manifest shipped
`regolith-session-common_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb`
(SHA-256 `bcf78bba...`) — a version string with **one fewer** `-1` segment,
which Debian version ordering ranks *lower* than the installed baseline. apt
correctly refused to silently downgrade under `-y`. No package state changed;
`dpkg --audit` was clean before and after the aborted transaction.

This same failure mode was already noted once before, in
[`2026-08-18-final-cosmic-tuple-settings-daemon-integration.md`](2026-08-18-final-cosmic-tuple-settings-daemon-integration.md#qemu-downgrade-correction),
where an *internal test runner* was patched to pass `--allow-downgrades` —
explicitly scoped to that disposable runner and not carried into the
real-system installer. That internal fix was never followed by a documented
successful controller run, and does not fix the underlying version defect.
This note treats the version string itself as the bug.

## Fix

`regolith-session-common`'s source (`regolith-session`, commit `1948857061e`,
branch `codex/cosmic-target-start-20260816`) was rebuilt on branch
[`rahul/session-common-version-fix-20260818`](https://github.com/Rahul-2k4/regolith-session/tree/rahul/session-common-version-fix-20260818)
with the changelog version bumped directly to `1.2.0-1ubuntu1-2-1regolith-resolute`.
This was verified empirically, not assumed:

```
dpkg --compare-versions "1.2.0-1ubuntu1-2-1regolith-resolute" gt "1.2.0-1ubuntu1-1-1regolith-resolute"
# → true
dpkg --compare-versions "1.2.0-1ubuntu1-1regolith-resolute"   gt "1.2.0-1ubuntu1-1-1regolith-resolute"
# → false (reproduces the original bug)
```

Rebuilt through the same Voulage local-build path as the rest of the tuple
(`ubuntu`/`resolute`/`unstable`). Lintian reported only pre-existing,
unrelated warnings (missing man pages, long file names,
virtual-package-depends). New artifact:

- `regolith-session-common_1.2.0-1ubuntu1-2-1regolith-resolute_amd64.deb`
- SHA-256: `b30a39055ee49783aaf51025da0818ea746043af057c5d784fa4d44a5cc0d066`

`artifacts/mentor-test-2026-08-18.sha256` and
`tests/install-real-system-contract.sh` were updated to this corrected
filename/hash. The source commit itself
(`codex/cosmic-target-start-20260816`) existed only as a local branch on the
shared build host and was not independently fetchable from a GitHub URL at
build time; the fix branch above is the reviewable, pushed artifact.

**Known follow-up, not yet done:** the same `regolith-session` source
produces five sibling binaries (`-cosmic`, `-flashback`, `-flashback-ext`,
`-gnome-targets`, `-sway`) sharing one changelog. The version-fix build also
bumped those five to `1.2.0-1ubuntu1-2-1regolith-resolute`, but only
`regolith-session-common` was staged and tested here. If any of those five
are shipped elsewhere at the old version, they carry the same class of
version-ordering risk relative to any host that already has a newer-suffixed
copy installed.

**Update, 2026-08-19: this follow-up is done for `-cosmic`.** An audit
found `regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb`
(the exact old version shown in the table below) was still the one staged
in `mentor-seven-package-bundle/` and pinned in the manifest — carrying the
identical version-ordering risk as the original `-common` bug, just not
yet triggered because attempt 3 above was a fresh install, not a downgrade
against a newer-suffixed baseline. Swapped in the already-built
`1.2.0-1ubuntu1-2-1regolith-resolute` binary (sha256
`790dbb85cd49b19930edca9c52a6f1157f0bd7cd4b97629faa8a55fe4a25957d`, from
the same Voulage run that fixed `-common`), updated the manifest and
contract test to match. The other four siblings
(`-flashback`/`-flashback-ext`/`-gnome-targets`/`-sway`) are not part of
this bundle and carry no live shipping risk today. See
`05_Testing_Proof/2026-08-19-mentor-cosmic-version-fix-staged.md` in the
vault for the full audit trail; a fresh QEMU install proof with the
corrected bundle is the remaining step to close this out end to end.

## Attempt 3 — success

Same procedure as attempt 2, with the corrected `regolith-session-common`
substituted in the bundle. All seven files re-verified by SHA-256 at three
points (local → remote host → guest) before install.

### Install

`apt-get install -y` on the seven staged files: **exit code 0**. Pulled in
24 new dependency packages (Qt6/breeze-icon-theme, for the newer
`cosmic-settings`) and upgraded 7 packages total. `dpkg --audit`: clean
before and after.

| Package | Before | After |
|---|---|---|
| `cosmic-settings` | `1.0.2~1769727671~24.04~18beed5` | `1.0.12-1-1regolith-resolute` |
| `cosmic-settings-daemon` | `0.1.0~1767386013~24.04~ef024bf` | `0.1.0-1-1regolith-resolute` |
| `cosmolith` | `0.1.0-1-1regolith-resolute` | `0.1.0-1-1regolith-resolute` |
| `regolith-displayd` | `0.3.4-1-1regolith-resolute` | `0.3.4-1-1regolith-resolute` |
| `regolith-inputd` | `0.4.1-1-1regolith-resolute` | `0.4.1-2-1regolith-resolute` |
| `regolith-session-common` | `1.2.0-1ubuntu1-1-1regolith-resolute` | **`1.2.0-1ubuntu1-2-1regolith-resolute`** (the fix) |
| `regolith-session-cosmic` | `1.2.0-1ubuntu1-1regolith-resolute` | `1.2.0-1ubuntu1-1regolith-resolute` |

### Reboot + greetd login

Guest SSH returned on the first post-reboot retry. The greetd client reported
`CANCEL_REPLY success`, `REPLY auth_message`, `REPLY success`,
`START_REPLY success` — exit code 0.

### Runtime verification (~20s after login)

- `swaymsg -t get_workspaces`: succeeded, one active workspace on `Virtual-1`.
- `regolith-cosmic.target`: **active**
- `regolith-gnome.target`: **inactive**
- `regolith-init-inputd.service`: **active**
- `regolith-init-displayd.service`: **active**
- `XDG_CURRENT_DESKTOP=Regolith-Wayland:COSMIC:sway`,
  `XDG_SESSION_TYPE=wayland`, confirmed via `/proc/<pid>/environ` for both
  the `sway` and `cosmic-session` processes.
- `loginctl list-sessions`: two active sessions for the guest user on
  `seat0`/`tty1`.
- Processes confirmed running: `cosmic-session`, `sway`, `regolith-inputd`.
  `regolith-displayd` was **not** found by `pgrep -ax` — this is a known
  `pgrep` 15-character `comm` name truncation artifact (the same limitation
  noted in `proof-notes/2026-08-12-final-inputd-qemu-runtime-success.md`),
  not a service failure: `systemctl --user is-active
  regolith-init-displayd.service` independently reported `active` for the
  same process. Treat the process-list line as inconclusive, not negative.
- Failed units: only the known, pre-existing, unrelated
  `app-polkit-mate-authentication-agent-1@autostart.service`. No other unit
  failed.

### Evidence

- [Framebuffer screenshot](../artifacts/mentor-seven-package-tuple-qemu-20260818.png)
- [Full run transcript](../artifacts/mentor-seven-package-tuple-qemu-20260818/transcript.log)
  (checked for credential leakage before committing — none present)

### Cleanup

QEMU powered down cleanly via HMP `system_powerdown`; overlay, HMP socket,
and staged files removed from the remote scratch directory; no
`qemu-system-x86` process remained afterward. Base image SHA-256 confirmed
unchanged before and after: `956b6634c73dad5e35891ad7417c3b81344aa58528861975ff3c3d8007a3a60d`.

## What this does and does not prove

This proves the exact seven-file bundle in
`artifacts/mentor-test-2026-08-18.sha256` installs cleanly over a realistic
pre-existing package state, survives a reboot, and reaches a healthy COSMIC
session with both helper daemons active — in QEMU, on Pop!_OS 24.04. It does
not prove: physical hardware behavior, Ubuntu 26.04 Resolute graphical login,
package signing, archive publication, or mentor acceptance. It does not
re-verify the four behavioral claims in `docs/INSTALL.md` ("try these four
things") beyond login itself — those still carry their own package-version
caveat documented there.
