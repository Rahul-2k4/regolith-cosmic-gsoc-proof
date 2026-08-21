# Mentor installer aborts in preflight: SIGPIPE under `pipefail`

Date: 2026-08-21
Severity: **blocks the documented install path entirely**
Found by: combined three-fix verification run
(`05_Testing_Proof/2026-08-21-combined-three-fix-verification-qemu.md`)

## Symptom

`scripts/install-real-system.sh` (published on proof-repo `main`, HEAD
`0380836`, contains `eb385d0`) aborts during preflight, naming a *different*
dependency on each run:

```
run 1: FAIL: no apt candidate for dependency: cosmic-session   check_exit=1
run 2: FAIL: no apt candidate for dependency:  dbus            check_exit=1
```

All 15 dependencies genuinely resolve. The script is wrong, not the system.

## Root cause, independently reproduced

Line 2 sets `set -Eeuo pipefail`. Line 181, inside `dependency_available()`:

```bash
if apt-cache policy "$dependency" | grep -Eq 'Candidate:[[:space:]]+[^()]'; then
```

`grep -q` exits the moment it matches. `apt-cache` is still writing, takes
SIGPIPE, and exits 141. `pipefail` propagates 141 as the pipeline status, so a
**successful match is read as a failure** and `dependency_available()` returns 1.

Reproduced directly on the Mac, not just taken from the worker report:

```
$ ( set -Eeuo pipefail; yes "Candidate: 1.0" | head -200000 | grep -Eq "Candidate:" )
run1 pipeline_rc=141 ; run2 pipeline_rc=141 ; run3 pipeline_rc=141
$ ( set -Eeu;          yes "Candidate: 1.0" | head -200000 | grep -Eq "Candidate:" )
rc=0
```

With a small writer the pipe buffer absorbs everything and the race does not
fire, which is exactly why it names a different dependency each run and why it
escaped notice.

## Why it shipped

`eb385d0` was validated by a contract test rather than an end-to-end run, and
the 2026-08-19 `--no-install-recommends` proof called `apt-get` directly
instead of going through the script. So the **flag** was verified; the
**script** never was.

## Impact on claims

- Criterion 9 is unaffected. The combined run installed with the script's own
  line-261 command verbatim (`apt-get install -y --no-install-recommends` over
  the seven bundle debs): `install_exit=0`, `introduced_count=0`, clean
  `dpkg --audit`. The behaviour the criterion asserts is proven.
- The **installer script itself is not proven** and is currently broken for
  anyone told to run it, including the mentor, who was sent this bundle.
  This must not ride along under a Criterion 9 promotion.

## Fix

Capture the output, then match, so no early-exit reader can signal the writer:

```bash
local policy
policy=$(apt-cache policy "$dependency" 2>/dev/null || true)
if grep -Eq 'Candidate:[[:space:]]+[^()]' <<<"$policy"; then
```

Then re-run the combined verification **through the script** so the script is
covered, not only the flag.
