#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

# Final accepted COSMIC tuple. These are package hashes, not runtime claims.
readonly SESSION_SOURCE=54d5684
readonly INPUTD_SOURCE=3b3309a
readonly DISPLAYD_SOURCE=44660e8
readonly COSMOLITH_SOURCE=592c1f6
readonly SETTINGS_SOURCE=e530ab7
readonly SESSION_SHA=8e3559e8dfd1eb33cbe3187da4772055a4f0ee048d69bf188ca0196b43635643
readonly INPUTD_SHA=7fbd2078e423f73dcdd05276057eb6bf5dfcd71150fd473dc9ad63b785ccb811
readonly DISPLAYD_SHA=11ac1a713aa5437a1b598e590c5980127b84f150b671de0896acd36a078d78fd
readonly COSMOLITH_SHA=ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e
readonly SETTINGS_SHA=5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f
# Optional COSMIC component, required for this runtime tuple.
readonly SETTINGS_DAEMON_SHA=16dbe4a274d31080055a6f0a2699f9b9d0d1a542c44798c9724ff3a0bfbb2fe1

readonly BASE_IMAGE=${BASE_IMAGE:-}
readonly VM_ROOT=${VM_ROOT:-}
readonly LOGIN_CLIENT=${LOGIN_CLIENT:-}
readonly SESSION_DEB=${SESSION_DEB:-}
readonly INPUTD_DEB=${INPUTD_DEB:-}
readonly DISPLAYD_DEB=${DISPLAYD_DEB:-}
readonly COSMOLITH_DEB=${COSMOLITH_DEB:-}
readonly COSMIC_SETTINGS_DEB=${COSMIC_SETTINGS_DEB:-}
readonly SETTINGS_DAEMON_DEB=${SETTINGS_DAEMON_DEB:-}
readonly GUEST_USER=${GUEST_USER:-rahul}
readonly SSH_PORT=${SSH_PORT:-2222}
readonly OVERLAY=${OVERLAY:-/tmp/regolith-final-cosmic-tuple.qcow2}
readonly HMP=${HMP:-/tmp/regolith-final-cosmic-tuple.sock}
readonly LOG=${LOG:-/tmp/regolith-final-cosmic-tuple.log}
readonly STAGE_DIR=${STAGE_DIR:-/tmp/regolith-final-cosmic-tuple-pkgs}
readonly KNOWN_HOSTS=${KNOWN_HOSTS:-/tmp/regolith-final-cosmic-tuple-known_hosts}

qemu_pid=''

usage() {
  cat <<'USAGE'
Usage: configure the six *_DEB paths, BASE_IMAGE, VM_ROOT, LOGIN_CLIENT,
and GUEST_PASS, then run this script.

Required variables:
  SESSION_DEB INPUTD_DEB DISPLAYD_DEB COSMOLITH_DEB COSMIC_SETTINGS_DEB SETTINGS_DAEMON_DEB
  BASE_IMAGE VM_ROOT LOGIN_CLIENT GUEST_PASS

Optional paths: OVERLAY HMP LOG STAGE_DIR KNOWN_HOSTS; GUEST_USER SSH_PORT.
GUEST_PASS is read only for sudo/reboot/login after package hash preflight.
The script does not store or print it. Use --contract-test for local checks.
USAGE
}

cleanup() {
  set +e
  if [[ -n "${qemu_pid}" ]] && kill -0 "${qemu_pid}" 2>/dev/null; then
    if [[ -S "${HMP}" ]] && command -v nc >/dev/null 2>&1; then
      printf 'system_powerdown\n' | timeout 10 nc -U -q1 "${HMP}" >/dev/null 2>&1
    fi
    wait "${qemu_pid}" 2>/dev/null
    kill "${qemu_pid}" 2>/dev/null
  fi
  rm -rf -- "${STAGE_DIR}" "${OVERLAY}" "${HMP}" "${LOG}" "${KNOWN_HOSTS}"
}
trap cleanup EXIT

die() { printf 'ERROR: %s\n' "$1" >&2; exit 1; }

require_file() {
  [[ -f "$1" ]] || die "missing artifact: $1"
}

verify_and_stage() {
  local path=$1 expected=$2 name=$3
  require_file "${path}"
  [[ "${expected}" =~ ^[[:xdigit:]]{64}$ ]] || die "invalid expected SHA256 for ${name}"
  printf '%s  %s\n' "${expected}" "${path}" | sha256sum --check --status --strict - ||
    die "SHA256 mismatch for ${name}: ${path}"
  cp -- "${path}" "${STAGE_DIR}/${name}"
}

stage_tuple() {
  mkdir -p -- "${STAGE_DIR}"
  verify_and_stage "${SESSION_DEB}" "${SESSION_SHA}" regolith-session-cosmic.deb
  verify_and_stage "${INPUTD_DEB}" "${INPUTD_SHA}" regolith-inputd.deb
  verify_and_stage "${DISPLAYD_DEB}" "${DISPLAYD_SHA}" regolith-displayd.deb
  verify_and_stage "${COSMOLITH_DEB}" "${COSMOLITH_SHA}" cosmolith.deb
  verify_and_stage "${COSMIC_SETTINGS_DEB}" "${SETTINGS_SHA}" cosmic-settings.deb
  verify_and_stage "${SETTINGS_DAEMON_DEB}" "${SETTINGS_DAEMON_SHA}" cosmic-settings-daemon.deb
}

guest_ssh() {
  ssh -p "${SSH_PORT}" -o BatchMode=yes -o ConnectTimeout=5 \
    -o StrictHostKeyChecking=no -o UserKnownHostsFile="${KNOWN_HOSTS}" \
    "${GUEST_USER}@127.0.0.1" "$1" </dev/null
}

guest_ssh_with_stdin() {
  ssh -p "${SSH_PORT}" -o BatchMode=yes -o ConnectTimeout=5 \
    -o StrictHostKeyChecking=no -o UserKnownHostsFile="${KNOWN_HOSTS}" \
    "${GUEST_USER}@127.0.0.1" "$1"
}

guest_root() {
  printf '%s\n' "${GUEST_PASS}" | ssh -p "${SSH_PORT}" -o BatchMode=yes \
    -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile="${KNOWN_HOSTS}" "${GUEST_USER}@127.0.0.1" \
    "sudo -S -p '' $1"
}

wait_for_guest_package_manager() {
  guest_root "sh -c 'for attempt in \$(seq 1 60); do if ! pgrep -x apt-get >/dev/null 2>&1 && ! pgrep -x dpkg >/dev/null 2>&1; then exit 0; fi; sleep 2; done; exit 1'"
}

wait_for_guest() {
  local attempt
  for attempt in $(seq 1 40); do
    if guest_ssh true >/dev/null 2>&1; then
      printf 'GUEST_SSH_UP attempt=%s\n' "${attempt}"
      return 0
    fi
    sleep 10
  done
  die 'guest SSH did not become ready'
}

launch_qemu() {
  [[ -f "${BASE_IMAGE}" ]] || die "base image not found: ${BASE_IMAGE}"
  [[ -d "${VM_ROOT}" ]] || die "VM root not found: ${VM_ROOT}"
  [[ -f "${VM_ROOT}/scripts/qemu-common.sh" ]] || die 'qemu-common.sh not found under VM_ROOT'
  qemu-img create -f qcow2 -F qcow2 -b "${BASE_IMAGE}" "${OVERLAY}" >/dev/null
  (
    cd "${VM_ROOT}"
    DISK_PATH="${OVERLAY}" VM_SSH_PORT="${SSH_PORT}" bash -c '
      source scripts/qemu-common.sh
      args=(); skip=0
      for arg in "${common_qemu_args[@]}"; do
        if [[ "${skip}" -eq 1 ]]; then skip=0; continue; fi
        if [[ "${arg}" == "-display" || "${arg}" == "-audiodev" || "${arg}" == "-device" ]]; then
          skip=1; continue
        fi
        args+=("${arg}")
      done
      exec "${QEMU_SYSTEM}" "${args[@]}" -display none \
        -monitor "unix:'"${HMP}"',server,nowait"
    '
  ) >"${LOG}" 2>&1 < /dev/null &
  qemu_pid=$!
  sleep 5
  kill -0 "${qemu_pid}" 2>/dev/null || die 'QEMU exited during launch'
  [[ -S "${HMP}" ]] || die 'QEMU HMP socket was not created'
}

run_runtime() {
  : "${GUEST_PASS:?GUEST_PASS is required only for the runtime phase}"
  [[ -f "${LOGIN_CLIENT}" ]] || die "login client not found: ${LOGIN_CLIENT}"
  launch_qemu
  wait_for_guest
  guest_ssh "mkdir -p /tmp/regolith-final-cosmic-tuple-pkgs"
  scp -q -P "${SSH_PORT}" -o BatchMode=yes -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile="${KNOWN_HOSTS}" "${STAGE_DIR}"/*.deb \
    "${GUEST_USER}@127.0.0.1:/tmp/regolith-final-cosmic-tuple-pkgs/"
  wait_for_guest_package_manager
  guest_root 'DEBIAN_FRONTEND=noninteractive apt-get install -y /tmp/regolith-final-cosmic-tuple-pkgs/*.deb'
  guest_root 'dpkg --audit'
  guest_root 'systemctl reboot' || true
  sleep 10
  wait_for_guest
  scp -q -P "${SSH_PORT}" -o BatchMode=yes -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile="${KNOWN_HOSTS}" "${LOGIN_CLIENT}" \
    "${GUEST_USER}@127.0.0.1:/tmp/regolith-final-cosmic-tuple-login.py"
  printf '%s\n%s\n' "${GUEST_PASS}" "${GUEST_PASS}" | guest_ssh_with_stdin \
    "sudo -S -p '' python3 /tmp/regolith-final-cosmic-tuple-login.py"
  printf 'RUNTIME_COMMANDS_COMPLETED=1\n'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
if [[ "${1:-}" == '--help' || "${1:-}" == '-h' ]]; then usage; exit 0; fi
if [[ "${1:-}" == '--contract-test' ]]; then
  [[ "${SESSION_SHA}" == 8e3559e8dfd1eb33cbe3187da4772055a4f0ee048d69bf188ca0196b43635643 ]]
  [[ "${INPUTD_SHA}" == 7fbd2078e423f73dcdd05276057eb6bf5dfcd71150fd473dc9ad63b785ccb811 ]]
  [[ "${DISPLAYD_SHA}" == 11ac1a713aa5437a1b598e590c5980127b84f150b671de0896acd36a078d78fd ]]
  [[ "${COSMOLITH_SHA}" == ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e ]]
  [[ "${SETTINGS_SHA}" == 5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f ]]
  [[ "${SETTINGS_DAEMON_SHA}" == 16dbe4a274d31080055a6f0a2699f9b9d0d1a542c44798c9724ff3a0bfbb2fe1 ]]
  printf 'CONTRACT_TUPLE=PASS\n'
  exit 0
fi

for required in BASE_IMAGE VM_ROOT LOGIN_CLIENT SESSION_DEB INPUTD_DEB DISPLAYD_DEB COSMOLITH_DEB COSMIC_SETTINGS_DEB SETTINGS_DAEMON_DEB; do
  [[ -n "${!required}" ]] || die "${required} is required"
done
stage_tuple
printf 'PACKAGE_PREFLIGHT=PASS\n'
run_runtime
fi
