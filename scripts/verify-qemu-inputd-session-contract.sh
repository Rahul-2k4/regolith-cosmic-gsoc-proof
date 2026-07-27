#!/usr/bin/env bash
set -euo pipefail

# Verify the installed Regolith/Sway COSMIC session contract in a guest.
# This wrapper only reads guest state and writes proof artifacts.

HOST="${HOST:-regolith-test-host.example}"
GUEST="${GUEST:-ssh -p 2222 user@127.0.0.1}"
REMOTE_PROOF_DIR="${REMOTE_PROOF_DIR:-/tmp/regolith-cosmic-inputd-session-proof}"

printf -v REMOTE_PROOF_DIR_Q "%q" "${REMOTE_PROOF_DIR}"

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  cat <<'USAGE'
Usage: HOST=... GUEST='ssh ...' REMOTE_PROOF_DIR=/path bash scripts/verify-qemu-inputd-session-contract.sh

Connects to the configured host and guest, then verifies the installed
Regolith/Sway COSMIC session contract. The guest payload does not change
services, processes, or session configuration; it only creates the selected
proof directory and writes evidence files there.
USAGE
  exit 0
fi

read -r -d '' GUEST_SCRIPT_CONTENT <<'GUEST_SCRIPT' || true
set -euo pipefail

PROOF_DIR="${1:-/tmp/regolith-cosmic-inputd-session-proof}"
mkdir -p "${PROOF_DIR}"

failures=0
fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

USER_ID="$(id -u)"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/${USER_ID}}"

pgrep -x sway > "${PROOF_DIR}/01-sway-pids.txt" || true
pgrep -x regolith-inputd > "${PROOF_DIR}/02-regolith-inputd-pids.txt" || true
ps -eo pid=,ppid=,user=,comm=,args= > "${PROOF_DIR}/03-processes.txt"
loginctl session-status > "${PROOF_DIR}/04-session-status.txt" 2>&1 || true

SWAYPID="$(head -n 1 "${PROOF_DIR}/01-sway-pids.txt" || true)"
if [ -z "${SWAYPID}" ]; then
  fail "no running sway process"
else
  tr '\0' '\n' < "/proc/${SWAYPID}/environ" > "${PROOF_DIR}/05-sway-environ.txt"
  if ! grep -Eq '^XDG_CURRENT_DESKTOP=.*COSMIC' "${PROOF_DIR}/05-sway-environ.txt"; then
    fail "sway environment lacks XDG_CURRENT_DESKTOP containing COSMIC"
  fi
fi

if [ ! -s "${PROOF_DIR}/02-regolith-inputd-pids.txt" ]; then
  fail "regolith-inputd is not running"
fi

for unit in regolith-init-inputd.service regolith-init-displayd.service regolith-init-kanshi.service; do
  enabled="$(systemctl --user is-enabled "${unit}" 2>&1 || true)"
  active="$(systemctl --user is-active "${unit}" 2>&1 || true)"
  printf 'unit=%s is-enabled=%s is-active=%s\n' "${unit}" "${enabled}" "${active}" >> "${PROOF_DIR}/06-legacy-service-state.txt"
  case "${enabled}" in
    masked|masked-runtime) ;;
    *) fail "${unit} is not masked or masked-runtime (reported: ${enabled})" ;;
  esac
  if [ "${active}" != "inactive" ]; then
    fail "${unit} is not inactive (reported: ${active})"
  fi
done

pgrep -x gnome-session-bin > "${PROOF_DIR}/07-gnome-session-pids.txt" || true
if [ -s "${PROOF_DIR}/07-gnome-session-pids.txt" ]; then
  fail "gnome-session-bin process is present"
fi

systemctl --user --failed --no-legend > "${PROOF_DIR}/08-user-failed-units.txt" || true
printf 'Contract failures: %s\n' "${failures}" | tee "${PROOF_DIR}/09-result.txt"
if [ "${failures}" -ne 0 ]; then
  exit 1
fi

printf 'PASS: installed Regolith/Sway COSMIC session contract verified\n'
printf 'Proof dir: %s\n' "${PROOF_DIR}"
GUEST_SCRIPT

printf '%s\n' "${GUEST_SCRIPT_CONTENT}" | ssh "${HOST}" "${GUEST} 'bash -s'" -- "${REMOTE_PROOF_DIR_Q}"
