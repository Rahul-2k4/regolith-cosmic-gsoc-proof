#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-}"
GUEST="${GUEST:-}"
REMOTE_PROOF_DIR="${REMOTE_PROOF_DIR:-/tmp/regolith-cosmic-inputd-candidate-proof}"
INPUTD_HELPER="${INPUTD_HELPER:-}"
EXPECTED_PACKAGE_VERSION="${EXPECTED_PACKAGE_VERSION:-}"
EXPECTED_BINARY_SHA256="${EXPECTED_BINARY_SHA256:-}"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'USAGE'
Usage: HOST=... GUEST='ssh ...' REMOTE_PROOF_DIR=/path \
  [INPUTD_HELPER=/guest/path] [EXPECTED_PACKAGE_VERSION=...] \
  [EXPECTED_BINARY_SHA256=...] bash scripts/verify-inputd-candidate-qemu-runtime.sh

Verifies an already-installed Regolith/COSMIC QEMU session. The guest payload
does not install packages, restart services, or change persistent configuration.
With INPUTD_HELPER, the helper must support --json, the --set-* options used by
this script, and --restore-json <json>.
USAGE
  exit 0
fi

[[ -n "${HOST}" && -n "${GUEST}" ]] || {
  printf 'HOST and GUEST are required\n' >&2
  exit 2
}

read -r -d '' GUEST_SCRIPT_CONTENT <<'GUEST_SCRIPT' || true
set -euo pipefail

proof_dir=$1
expected_version=$2
expected_hash=$3
helper=$4
mkdir -p "${proof_dir}"
failures=0
fail() { printf 'FAIL: %s\n' "$1" >&2; failures=$((failures + 1)); }

dpkg-query -W -f='${Version}\n' regolith-inputd >"${proof_dir}/01-package-version.txt" 2>&1 || fail 'regolith-inputd is not installed'
actual_version=$(cat "${proof_dir}/01-package-version.txt" 2>/dev/null || true)
if [[ -n "${expected_version}" && "${actual_version}" != "${expected_version}" ]]; then
  fail "regolith-inputd version mismatch: expected ${expected_version}, got ${actual_version}"
fi

binary=$(command -v regolith-inputd || true)
if [[ -z "${binary}" ]]; then
  fail 'regolith-inputd binary is not on PATH'
else
  printf '%s\n' "${binary}" >"${proof_dir}/02-binary-path.txt"
  sha256sum "${binary}" >"${proof_dir}/03-binary-sha256.txt" || fail 'could not hash regolith-inputd binary'
  actual_hash=$(awk '{print $1}' "${proof_dir}/03-binary-sha256.txt" 2>/dev/null || true)
  if [[ -n "${expected_hash}" && "${actual_hash}" != "${expected_hash}" ]]; then
    fail "regolith-inputd hash mismatch: expected ${expected_hash}, got ${actual_hash}"
  fi
fi

check_desktop() {
  local name=$1 pid=$2 output="${proof_dir}/04-${name}-environment.txt"
  if [[ -z "${pid}" ]]; then fail "${name} process is not running"; return; fi
  if [[ ! -r "/proc/${pid}/environ" ]]; then fail "cannot read ${name} environment"; return; fi
  tr '\0' '\n' <"/proc/${pid}/environ" >"${output}"
  grep -Eq '^XDG_CURRENT_DESKTOP=.*COSMIC' "${output}" || fail "${name} lacks COSMIC XDG_CURRENT_DESKTOP"
}

sway_pid=$(pgrep -x sway | head -n 1 || true)
inputd_pid=$(pgrep -x regolith-inputd | head -n 1 || true)
check_desktop sway "${sway_pid}"
check_desktop regolith-inputd "${inputd_pid}"

for target in regolith-cosmic.target; do
  systemctl --user is-active "${target}" >"${proof_dir}/05-${target}.txt" 2>&1 || fail "${target} is not active"
done
for unit in regolith-init-inputd.service regolith-init-displayd.service; do
  state=$(systemctl --user show "${unit}" -p ActiveState -p Result -p NRestarts 2>&1 || true)
  printf '%s\n' "${state}" >"${proof_dir}/06-${unit}.txt"
  grep -q '^ActiveState=active$' <<<"${state}" || fail "${unit} is not active"
  grep -q '^Result=success$' <<<"${state}" || fail "${unit} result is not success"
done

systemctl --user --failed --no-legend >"${proof_dir}/07-user-failed-units.txt" || true
if grep -Eq '(^|[[:space:]])(regolith-|cosmic-)' "${proof_dir}/07-user-failed-units.txt"; then
  fail 'project-owned failed user units are present'
fi

if [[ -n "${helper}" ]]; then
  [[ -x "${helper}" ]] || fail "INPUTD_HELPER is not executable: ${helper}"
  if [[ -x "${helper}" ]]; then
    before=$("${helper}" --json) || { fail 'INPUTD_HELPER --json failed'; before='{}'; }
    printf '%s\n' "${before}" >"${proof_dir}/08-inputd-before.json"
    changed=0
    "${helper}" --set-layout fr --set-variant azerty --set-repeat-delay 540 --set-repeat-rate 31 && changed=1 || fail 'INPUTD_HELPER apply failed'
    after=$("${helper}" --json) || { fail 'INPUTD_HELPER after-state failed'; after='{}'; }
    printf '%s\n' "${after}" >"${proof_dir}/09-inputd-after.json"
    if [[ "${changed}" -eq 1 ]]; then
      "${helper}" --restore-json "${before}" || fail 'INPUTD_HELPER restore failed'
      restored=$("${helper}" --json) || { fail 'INPUTD_HELPER restored-state failed'; restored='{}'; }
      printf '%s\n' "${restored}" >"${proof_dir}/10-inputd-restored.json"
      [[ "${restored}" == "${before}" ]] || fail 'restored JSON does not match before JSON'
    fi
  fi
fi

printf 'Runtime verification failures: %s\n' "${failures}" | tee "${proof_dir}/11-result.txt"
if [[ "${failures}" -ne 0 ]]; then exit 1; fi
printf 'PASS: installed package/binary, COSMIC environments, target/helper health, failed-unit check%s verified\n' \
  "$( [[ -n "${helper}" ]] && printf ', keyboard/repeat helper round-trip' || true )"
printf 'Proof dir: %s\n' "${proof_dir}"
GUEST_SCRIPT

printf '%s\n' "${GUEST_SCRIPT_CONTENT}" | ssh "${HOST}" "${GUEST} 'bash -s'" -- \
  "${REMOTE_PROOF_DIR}" "${EXPECTED_PACKAGE_VERSION}" "${EXPECTED_BINARY_SHA256}" "${INPUTD_HELPER}"
