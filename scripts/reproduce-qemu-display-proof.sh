#!/usr/bin/env bash
set -euo pipefail

# Reproduce the QEMU-side display monitoring proof.
#
# Assumptions:
# - This is run from the machine that can SSH to the host running QEMU.
# - QEMU guest is reachable from that host over SSH.
# - Guest is already logged into the Regolith/Sway COSMIC test session.
# - No passwords are stored in this script.

HOST="${HOST:-regolith-test-host.example}"
GUEST="${GUEST:-ssh -p 2222 user@127.0.0.1}"
REMOTE_PROOF_DIR="${REMOTE_PROOF_DIR:-/tmp/regolith-cosmic-display-proof}"
OUTPUT_NAME="${OUTPUT_NAME:-Virtual-1}"
TEST_WIDTH="${TEST_WIDTH:-1024}"
TEST_HEIGHT="${TEST_HEIGHT:-768}"
TEST_REFRESH="${TEST_REFRESH:-60.004}"
RESTORE_WIDTH="${RESTORE_WIDTH:-1280}"
RESTORE_HEIGHT="${RESTORE_HEIGHT:-800}"
RESTORE_REFRESH="${RESTORE_REFRESH:-74.994}"

printf -v REMOTE_PROOF_DIR_Q "%q" "${REMOTE_PROOF_DIR}"
printf -v OUTPUT_NAME_Q "%q" "${OUTPUT_NAME}"
printf -v TEST_WIDTH_Q "%q" "${TEST_WIDTH}"
printf -v TEST_HEIGHT_Q "%q" "${TEST_HEIGHT}"
printf -v TEST_REFRESH_Q "%q" "${TEST_REFRESH}"
printf -v RESTORE_WIDTH_Q "%q" "${RESTORE_WIDTH}"
printf -v RESTORE_HEIGHT_Q "%q" "${RESTORE_HEIGHT}"
printf -v RESTORE_REFRESH_Q "%q" "${RESTORE_REFRESH}"

echo "Host: ${HOST}"
echo "Guest proof dir: ${REMOTE_PROOF_DIR}"

ssh "${HOST}" "${GUEST} 'printf GUEST_OK'" >/dev/null

read -r -d '' GUEST_SCRIPT_CONTENT <<'GUEST_SCRIPT' || true
set -euo pipefail

PROOF_DIR="${1:-/tmp/regolith-cosmic-display-proof}"
OUTPUT_NAME="${2:-Virtual-1}"
TEST_WIDTH="${3:-1024}"
TEST_HEIGHT="${4:-768}"
TEST_REFRESH="${5:-60.004}"
RESTORE_WIDTH="${6:-1280}"
RESTORE_HEIGHT="${7:-800}"
RESTORE_REFRESH="${8:-74.994}"
mkdir -p "${PROOF_DIR}"

USER_ID="$(id -u)"

RESTORE_NEEDED=0
restore_display() {
  if [ "${RESTORE_NEEDED}" = "1" ]; then
    cosmic-randr mode "${OUTPUT_NAME}" "${RESTORE_WIDTH}" "${RESTORE_HEIGHT}" --refresh "${RESTORE_REFRESH}" > "${PROOF_DIR}/99-restore-trap.log" 2>&1 || true
  fi
}
trap restore_display EXIT

SWAYPID="$(pgrep -x sway | head -1)"
if [ -z "${SWAYPID}" ]; then
  COSMIC_SESSION_PID="$(pgrep -x cosmic-session | head -1 || true)"
  {
    printf 'No live sway compositor found.\n'
    if [ -n "${COSMIC_SESSION_PID}" ]; then
      printf 'cosmic-session PID=%s is present without a compositor.\n' "${COSMIC_SESSION_PID}"
    else
      printf 'No cosmic-session process was found either.\n'
    fi
  } > "${PROOF_DIR}/00-discovery-failure.txt"
  echo "No live sway compositor found; see ${PROOF_DIR}/00-discovery-failure.txt" >&2
  exit 1
fi

SWAY_ENV_FILE="${PROOF_DIR}/00-sway-environ.txt"
if ! tr '\0' '\n' < "/proc/${SWAYPID}/environ" > "${SWAY_ENV_FILE}"; then
  printf 'Unable to read the live sway process environment (PID %s).\n' "${SWAYPID}" > "${PROOF_DIR}/00-discovery-failure.txt"
  exit 1
fi

WAYLAND_DISPLAY_VALUE="$(sed -n 's/^WAYLAND_DISPLAY=//p' "${SWAY_ENV_FILE}" | head -1)"
SWAY_RUNTIME_DIR="$(sed -n 's/^XDG_RUNTIME_DIR=//p' "${SWAY_ENV_FILE}" | head -1)"
SWAY_RUNTIME_DIR="${SWAY_RUNTIME_DIR:-/run/user/${USER_ID}}"
export XDG_RUNTIME_DIR="${SWAY_RUNTIME_DIR}"
if [ -z "${WAYLAND_DISPLAY_VALUE}" ]; then
  WAYLAND_SOCKET_VALUE="$(find "${SWAY_RUNTIME_DIR}" -maxdepth 1 -type s -name 'wayland-*' -print -quit 2>/dev/null)"
  if [ -n "${WAYLAND_SOCKET_VALUE}" ]; then
    WAYLAND_DISPLAY_VALUE="${WAYLAND_SOCKET_VALUE##*/}"
  fi
fi
WAYLAND_SOCKET_VALUE="${SWAY_RUNTIME_DIR}/${WAYLAND_DISPLAY_VALUE}"
SWAYSOCK_VALUE="$(sed -n 's/^SWAYSOCK=//p' "${SWAY_ENV_FILE}" | head -1)"
if [ -z "${SWAYSOCK_VALUE}" ] || [ ! -S "${SWAYSOCK_VALUE}" ]; then
  SWAYSOCK_VALUE="$(find "${SWAY_RUNTIME_DIR}" -maxdepth 1 -type s -name 'sway-ipc*.sock' -print -quit 2>/dev/null)"
fi

if [ -z "${WAYLAND_DISPLAY_VALUE}" ] || [ ! -S "${WAYLAND_SOCKET_VALUE}" ] || [ -z "${SWAYSOCK_VALUE}" ]; then
  {
    printf 'Sway discovery failed for PID %s.\n' "${SWAYPID}"
    printf 'XDG_RUNTIME_DIR=%s\n' "${SWAY_RUNTIME_DIR}"
    printf 'WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY_VALUE}"
    printf 'WAYLAND_SOCKET=%s\n' "${WAYLAND_SOCKET_VALUE}"
    printf 'SWAYSOCK=%s\n' "${SWAYSOCK_VALUE}"
    printf 'The guest may have cosmic-session without a live compositor runtime.\n'
  } > "${PROOF_DIR}/00-discovery-failure.txt"
  echo "Sway runtime discovery failed; see ${PROOF_DIR}/00-discovery-failure.txt" >&2
  exit 1
fi

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY_VALUE}"
export SWAYSOCK="${SWAYSOCK_VALUE}"

{
  echo "SWAYPID=${SWAYPID}"
  echo "WAYLAND_DISPLAY=${WAYLAND_DISPLAY}"
  echo "SWAYSOCK=${SWAYSOCK}"
  grep -E '^(XDG_CURRENT_DESKTOP|XDG_SESSION_TYPE|DBUS_SESSION_BUS_ADDRESS)=' "${SWAY_ENV_FILE}" || true
} > "${PROOF_DIR}/00-session-env.txt"

systemctl --user status regolith-init-kanshi.service --no-pager -l > "${PROOF_DIR}/01-kanshi-service-status.txt" 2>&1 || true
systemctl --user --failed --no-legend > "${PROOF_DIR}/02-user-failed-before.txt" || true

if ! swaymsg -t get_version > "${PROOF_DIR}/00-sway-version.txt" 2>&1; then
  printf 'swaymsg -t get_version failed with WAYLAND_DISPLAY=%s and SWAYSOCK=%s.\n' "${WAYLAND_DISPLAY}" "${SWAYSOCK}" > "${PROOF_DIR}/00-discovery-failure.txt"
  exit 1
fi
if ! cosmic-randr list > "${PROOF_DIR}/00-cosmic-randr-probe.txt" 2>&1; then
  printf 'cosmic-randr list failed before output mutation.\n' > "${PROOF_DIR}/00-discovery-failure.txt"
  exit 1
fi

swaymsg -t get_outputs > "${PROOF_DIR}/03-before-sway.json"
cp "${PROOF_DIR}/00-cosmic-randr-probe.txt" "${PROOF_DIR}/04-before-randr.txt"

(timeout 10 swaymsg -t subscribe '["output"]' > "${PROOF_DIR}/05-sway-output-events.jsonl" 2> "${PROOF_DIR}/05-sway-output-events.err" || true) &
MONITOR_PID="$!"
sleep 1

cosmic-randr mode "${OUTPUT_NAME}" "${TEST_WIDTH}" "${TEST_HEIGHT}" --refresh "${TEST_REFRESH}" > "${PROOF_DIR}/06-mode-test.log" 2>&1
RESTORE_NEEDED=1
sleep 2
swaymsg -t get_outputs > "${PROOF_DIR}/07-after-mode-sway.json"
cosmic-randr list > "${PROOF_DIR}/08-after-mode-randr.txt"

cosmic-randr mode "${OUTPUT_NAME}" "${RESTORE_WIDTH}" "${RESTORE_HEIGHT}" --refresh "${RESTORE_REFRESH}" > "${PROOF_DIR}/09-restore.log" 2>&1
RESTORE_NEEDED=0
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

printf '%s\n' "${GUEST_SCRIPT_CONTENT}" | ssh "${HOST}" "${GUEST} 'bash -s' -- ${REMOTE_PROOF_DIR_Q} ${OUTPUT_NAME_Q} ${TEST_WIDTH_Q} ${TEST_HEIGHT_Q} ${TEST_REFRESH_Q} ${RESTORE_WIDTH_Q} ${RESTORE_HEIGHT_Q} ${RESTORE_REFRESH_Q}"

echo
echo "Done. Proof remains in the guest at: ${REMOTE_PROOF_DIR}"
echo "To copy it out, SSH to ${HOST}, then use your configured guest SSH command to archive or copy that directory."
