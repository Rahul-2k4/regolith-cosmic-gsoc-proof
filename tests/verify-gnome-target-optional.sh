#!/usr/bin/env bash
# Regression test: `verify` must not fail on a COSMIC-only install.
#
# verify_system() required /usr/lib/systemd/user/regolith-gnome.target as a
# mandatory file. No package in the seven-package COSMIC bundle ships that
# target; it belongs to the GNOME path (regolith-session-common's GNOME
# targets package). So a correct, complete COSMIC-only install failed verify:
#   FAIL: regolith-gnome.target unit missing: /usr/lib/systemd/user/...
#
# The target is optional. Absent means GNOME path not installed, which is fine.
set -Eeuo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
SCRIPT=$ROOT_DIR/scripts/install-real-system.sh
WORK=$(mktemp -d "${TMPDIR:-/tmp}/verify-gnome-optional.XXXXXX")
trap 'rm -rf "$WORK"' EXIT

# Exactly what the seven-package bundle installs. Verified by listing the debs:
# regolith-session-cosmic ships the desktop entry and regolith-cosmic.target,
# regolith-inputd ships regolith-init-inputd.service, regolith-displayd ships
# regolith-init-displayd.service. Nothing ships regolith-gnome.target.
mkdir -p "$WORK/usr/lib/systemd/user" "$WORK/usr/share/wayland-sessions"
touch "$WORK/usr/share/wayland-sessions/regolith-cosmic.desktop" \
      "$WORK/usr/lib/systemd/user/regolith-cosmic.target" \
      "$WORK/usr/lib/systemd/user/regolith-init-inputd.service" \
      "$WORK/usr/lib/systemd/user/regolith-init-displayd.service"

out=$(ROOT_PREFIX=$WORK bash "$SCRIPT" verify 2>&1) && rc=0 || rc=$?

printf '%s\n' "$out"
echo "---"
if (( rc != 0 )); then
    echo "FAIL: verify exited $rc on a complete COSMIC-only install"
    exit 1
fi
if grep -q 'FAIL:' <<<"$out"; then
    echo "FAIL: verify reported a failure on a complete COSMIC-only install"
    exit 1
fi
echo "PASS: verify accepts a COSMIC-only install with no GNOME target"

# Second scenario: when the GNOME path IS installed the target must still be
# recognised, so the fix cannot have simply deleted the check.
touch "$WORK/usr/lib/systemd/user/regolith-gnome.target"
out2=$(ROOT_PREFIX=$WORK bash "$SCRIPT" verify 2>&1) && rc2=0 || rc2=$?
if (( rc2 != 0 )) || grep -q 'FAIL:' <<<"$out2"; then
    printf '%s\n' "$out2"
    echo "FAIL: verify rejected an install that also has the GNOME target"
    exit 1
fi
grep -q 'PASS: regolith-gnome.target unit:' <<<"$out2" || {
    printf '%s\n' "$out2"
    echo "FAIL: verify did not acknowledge the present GNOME target"
    exit 1
}
echo "PASS: verify still recognises the GNOME target when it is installed"
