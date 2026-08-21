# COSMIC session aborted on a fresh, correct install — fix pushed, rebuild in progress

Date: 2026-08-21
Severity: **launch-blocking on a genuinely fresh COSMIC-only install**
Found by: fresh-install cold-login ordering replay for Criterion 3

## Symptom

On a fresh COW overlay with any earlier tuple purged first (a real new
install, not a version bump over leftovers), the first COSMIC login died in
under a second:

```
$ systemctl --user is-enabled regolith-gnome.target
not-found
rc=4
```

Journal: `Reached target cosmic-session.target` then `Stopped target
cosmic-session.target` in the same second.

## Root cause, confirmed against the shipped package

`/usr/lib/regolith/regolith-session-cosmic-runtime`,
`regolith_legacy_target_is_pre_masked()`:

```bash
case "$state" in
    masked|masked-runtime) return 0 ;;
    enabled|enabled-runtime|linked|linked-runtime|disabled|static|indirect|generated|transient|alias) return 1 ;;
esac
# falls through here on "not-found" -> return 2
```

`not-found` is exactly what `systemctl --user is-enabled` reports when the
unit does not exist on disk at all — the normal state of
`regolith-gnome.target` on a COSMIC-only install that never installed the
GNOME-targets package. The function returned 2; the caller
(`mask_regolith_legacy_targets_for_cosmic`) treats any non-1 return as fatal
and calls `regolith_cosmic_runtime_abort_session`.

Confirmed this is the actual shipped code, not a stale branch: extracted
`usr/lib/regolith/regolith-session-cosmic-runtime` directly from
`regolith-session-cosmic_1.2.0-1ubuntu1-2-1regolith-resolute_amd64.deb` in the
mentor bundle, sha256 `8cca2fb4c787d4ffd527a8a8224e25107b4932b3b0444cbd0a1d17346e3db3e5`,
and diffed it against the source branch — the broken function is byte-identical.

## Why prior runs never hit this

Every earlier QEMU run either reused a disk that still carried an older tuple
(so the legacy targets existed and were `disabled`, not `not-found`), or had
the runtime script hand-patched in already. This is the first run in the
project that purged the earlier tuple first, making it a genuine fresh
install — and that's what exposed it.

## Fix, and a lineage error caught and corrected

First attempt pushed as
[PR #2](https://github.com/Rahul-2k4/regolith-session/pull/2), on
`codex/session-target-ownership-20260818`, which this note originally (and
wrongly) claimed "matches the shipped package byte-for-byte." A rebuild of
that fix reached a real COSMIC login with no hand workaround in QEMU, across
three fresh-install cold boots — genuine proof the *behavior fix* is correct
— but the QEMU verification agent checked more rigorously than I had and
found the claim itself was wrong: hashing
`usr/lib/regolith/regolith-session-cosmic-runtime` across every candidate
branch shows `codex/session-target-ownership-20260818` produces sha256
`a3331e4f...`, not the shipped package's `8cca2fb4...`, and drops the
`regolith_cosmic_runtime_terminate_owned_parent` teardown block the shipped
package actually has. `git merge-base --is-ancestor` between the two returns
false — they are not related by ancestry at all.

The actually-matching branch, found by hashing every candidate rather than
assuming the most-recently-touched one was right, is
`rahul/session-common-version-fix-20260818`. Re-applied the identical fix
there, re-ran the full existing test suite (confirmed no regression against
that branch's own unmodified baseline), and pushed
[PR #3](https://github.com/Rahul-2k4/regolith-session/pull/3), which
supersedes #2. **PR #2 is closed** with the reason recorded on the PR itself.

Treats `not-found` (and empty state) the same as `disabled`.

TDD: wrote `tests/regolith-cosmic-runtime-not-found-legacy-target.sh` first,
proved it fails against the unfixed function (reproduces the exact abort
message), then fixed, then it passes. Wired into `debian/rules` so it runs on
every package build. The two pre-existing tests that also fail in my local
macOS shell (`regolith-cosmic-runtime-teardown.sh`,
`regolith-cosmic-runtime-environment.sh`) fail identically on the unmodified
baseline — both need `setsid` and Linux process-group semantics, unrelated to
this change.

## What is proven vs. not yet

**Proven:** the fix is correct at the shell-function level (TDD, both
branches). The *behavior* is proven in QEMU — a rebuilt package with this
exact fix reaches a real COSMIC login on a fresh, purged-first install with
no hand workaround, across three independent cold boots, journal free of the
abort message throughout.

**Not yet proven:** that specific rebuilt package (`1.2.0-1ubuntu1-3-1regolith-resolute`,
deb sha256 `ce5ac906aeba92f9f0ac464f29cbfa9a4290dddbbf5ac4b1e3d5e5f6a2d001ab`) was
built from the wrong-lineage branch (the original #2), so it is not a clean
successor to the shipped bundle — it is missing the parent-termination
teardown feature. A final rebuild from the corrected `PR #3` branch, re-run
through the same fresh-install harness including the plain-Sway negative
control, is the one remaining step. In progress.

## Impact on the mentor message

The mentor message already handed to the user assumes a working install path.
**If the mentor's host does not already have an existing Regolith install
with the legacy GNOME targets present, this exact abort will hit them on step
1 ("log out, pick Regolith COSMIC at the greeter").** `docs/INSTALL.md` says
the host should already have "working Regolith and COSMIC package sources,"
which likely means the legacy targets exist there too — but that is not
guaranteed, and the message should not go out until the rebuild is confirmed,
or the message should say explicitly that this specific failure mode is known
and what it looks like if hit.

## Claim boundary

QEMU proof only. No hand workaround was part of the diagnosis path recorded
here — the mask-and-retry used to get the diagnostic boot moving is disclosed
separately as a manual step, not part of any install claim.

## Resolved - 2026-08-21

Final rebuild on the corrected branch, verified before building (not
assumed): `git merge-base --is-ancestor` confirms
`rahul/session-common-version-fix-20260818` is a real ancestor of the fix
commit, and the fix commit's *parent* hashes to `8cca2fb4...` — the exact
shipped sha — while the fix commit itself is `+7` lines with nothing removed.
`regolith_cosmic_runtime_terminate_owned_parent` and the
`regolith-session-gnome-targets` build are both retained.

Built as `regolith-session-cosmic 1.2.0-1ubuntu1-4-1regolith-resolute`, deb
sha256 `3e2c58752fd4cd65ca710f8db440434bdc4eed0641c2753f31aa4686e35539a7`.
Reached a live COSMIC session with no hand mask across two independent
fresh-install cold boots, journal free of the abort message on both. A third
boot on the same overlay, running plain Sway instead of COSMIC, is the
negative control the prior rebuild skipped: no `cosmic-session` process, no
Regolith helpers, `regolith-cosmic.target` inactive, `is-enabled
regolith-gnome.target` → `not-found` (the exact state that used to abort the
session) with zero session impact, because the session identity wasn't
COSMIC. `verify` passes on both COSMIC boots, correctly `SKIP`s the absent
GNOME target rather than failing on it, and `SKIP`s correctly on the Sway
control (bare Sway never raises `graphical-session.target`).

[PR #3](https://github.com/Rahul-2k4/regolith-session/pull/3) merged at
`fa82772`. Proof:
`05_Testing_Proof/2026-08-21-cosmic-not-found-fix-correct-lineage-qemu.md`.

**The mentor message hold is lifted for this specific bug.** The install
path, on the actual shipped package lineage, no longer aborts on a fresh
COSMIC-only install. Remaining bounds: QEMU-only, headless (no pixels), local
unsigned debs (not archive), greetd IPC login (not greeter UI), single
user/seat/output, no long soak on this exact lineage.
