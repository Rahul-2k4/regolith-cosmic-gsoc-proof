#!/usr/bin/env bash
set -euo pipefail

# Reproduce the QEMU-side display monitoring proof.
#
# Assumptions:
# - This is run from the machine that can SSH to the laptop as `regolith-test-host`.
# - QEMU guest is reachable from the laptop at rahul@127.0.0.1:2222.
# - Guest is already logged into the Regolith/Sway COSMIC test session.
# - No passwords are stored in this script.

HOST="${HOST:-regolith-test-host}"
GUEST="${GUEST:-ssh -o StrictHostKeyChecking=no -p 2222 rahul@127.0.0.1}"
REMOTE_PROOF_DIR="${REMOTE_PROOF_DIR:-/tmp/regolith-cosmic-display-proof}"

echo "Host: ${HOST}"
echo "Guest proof dir: ${REMOTE_PROOF_DIR}"

ssh "${HOST}" "${GUEST} 'printf GUEST_OK'" >/dev/null

ssh "${HOST}" "${GUEST} 'bash -s' <<'GUEST_SCRIPT'"
set -euo pipefail

PROOF_DIR="${REMOTE_PROOF_DIR:-/tmp/regolith-cosmic-display-proof}"
mkdir -p "${PROOF_DIR}"

export XDG_RUNTIME_DIR=/run/user/1000

SWAYPID="$(pgrep -x sway | head -1)"
if [ -z "${SWAYPID}" ]; then
  echo "No sway process found" >&2
  exit 1
fi

WAYLAND_DISPLAY_VALUE="$(tr '\0' '\n' < "/proc/${SWAYPID}/environ" | sed -n 's/^WAYLAND_DISPLAY=//p' | head -1)"
SWAYSOCK_VALUE="$(find /run/user/1000 -maxdepth 1 -name 'sway-ipc*.sock' | head -1)"

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY_VALUE:-wayland-1}"
export SWAYSOCK="${SWAYSOCK_VALUE}"

{
  echo "SWAYPID=${SWAYPID}"
  echo "WAYLAND_DISPLAY=${WAYLAND_DISPLAY}"
  echo "SWAYSOCK=${SWAYSOCK}"
  tr '\0' '\n' < "/proc/${SWAYPID}/environ" | grep -E '^(XDG_CURRENT_DESKTOP|XDG_SESSION_TYPE|DBUS_SESSION_BUS_ADDRESS)=' || true
} > "${PROOF_DIR}/00-session-env.txt"

systemctl --user status regolith-init-kanshi.service --no-pager -l > "${PROOF_DIR}/01-kanshi-service-status.txt" 2>&1 || true
systemctl --user --failed --no-legend > "${PROOF_DIR}/02-user-failed-before.txt" || true

swaymsg -t get_outputs > "${PROOF_DIR}/03-before-sway.json"
cosmic-randr list > "${PROOF_DIR}/04-before-randr.txt"

(timeout 10 swaymsg -t subscribe '["output"]' > "${PROOF_DIR}/05-sway-output-events.jsonl" 2> "${PROOF_DIR}/05-sway-output-events.err" || true) &
MONITOR_PID="$!"
sleep 1

cosmic-randr mode Virtual-1 1024 768 --refresh 60.004 > "${PROOF_DIR}/06-mode-1024.log" 2>&1
sleep 2
swaymsg -t get_outputs > "${PROOF_DIR}/07-after-mode-sway.json"
cosmic-randr list > "${PROOF_DIR}/08-after-mode-randr.txt"

cosmic-randr mode Virtual-1 1280 800 --refresh 74.994 > "${PROOF_DIR}/09-restore.log" 2>&1
sleep 2
swaymsg -t get_outputs > "${PROOF_DIR}/10-after-restore-sway.json"
cosmic-randr list > "${PROOF_DIR}/11-after-restore-randr.txt"

wait "${MONITOR_PID}" || true
systemctl --user --failed --no-legend > "${PROOF_DIR}/12-user-failed-after.txt" || true

echo "Proof dir: ${PROOF_DIR}"
echo "Output events:"
cat "${PROOF_DIR}/05-sway-output-events.jsonl" || true
echo "Failed units after proof: $(wc -c < "${PROOF_DIR}/12-user-failed-after.txt") bytes"
GUEST_SCRIPT

echo
echo "Done. Copy proof from guest if needed:"
echo "  ssh ${HOST} \"scp -P 2222 -r rahul@127.0.0.1:${REMOTE_PROOF_DIR} /tmp/\""
