#!/usr/bin/env bash
# Regression test for the preflight SIGPIPE abort.
#
# dependency_available() piped `apt-cache policy` into `grep -q`. grep -q exits
# on first match, apt-cache takes SIGPIPE and exits 141, and because the script
# runs under `set -o pipefail` a successful match was reported as a failure.
# Preflight then aborted claiming a dependency had no apt candidate.
#
# The real failure is a race, so it only showed up when the writer was still
# writing as grep exited. This test makes it deterministic by having the
# apt-cache mock emit far more than one pipe buffer.
set -Eeuo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
SCRIPT=$ROOT_DIR/scripts/install-real-system.sh
WORK=$(mktemp -d "${TMPDIR:-/tmp}/dep-available-sigpipe.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

# Big enough that grep -q is guaranteed to exit while the writer still has data.
cat >"$WORK/apt-cache" <<'MOCK'
#!/usr/bin/env bash
printf '%s:\n' "${2:-pkg}"
printf '  Candidate: 1.0\n'
for _ in $(seq 1 200000); do printf '  ***  1.0 500 filler line to overrun the pipe buffer\n'; done
MOCK
chmod +x "$WORK/apt-cache"
PATH=$WORK:$PATH

# Pull dependency_available() and its trim() helper out of the installer and
# exercise them under the same shell options the real script sets.
sed -n '/^trim()/,/^}/p;/^dependency_available()/,/^}/p' "$SCRIPT" >"$WORK/fn.sh"
grep -q '^dependency_available()' "$WORK/fn.sh" || { echo "FAIL: could not extract dependency_available()"; exit 1; }
is_bundled() { return 1; }
# shellcheck disable=SC1090
source "$WORK/fn.sh"

failures=0
for dep in dbus cosmic-session libc6; do
    if dependency_available "$dep"; then
        printf 'PASS: %s resolved\n' "$dep"
    else
        printf 'FAIL: %s reported unavailable despite a matching Candidate line\n' "$dep"
        failures=$((failures + 1))
    fi
done

if (( failures )); then
    printf '\n%d/3 dependencies spuriously reported unavailable (SIGPIPE regression)\n' "$failures"
    exit 1
fi
printf '\nall dependencies resolved, no SIGPIPE regression\n'
