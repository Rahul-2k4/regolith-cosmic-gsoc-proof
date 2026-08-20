#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
runbook=${repo_root}/scripts/run-final-cosmic-tuple.sh
manifest=${repo_root}/artifacts/mentor-test-2026-08-18.sha256

expected_manifest=$(cat <<'MANIFEST'
8e3559e8dfd1eb33cbe3187da4772055a4f0ee048d69bf188ca0196b43635643  regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb
bcf78bbabd644bc2e4c382c7eefb0a525e9f1b7dc4852b0473213901989dcf7f  regolith-session-common_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb
a277811b7843791b3556f2bbb0d5c5a600b483f41f34d71f5f75cad08886aa19  regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb
949b9aedf8b4e64f2feeabc67947e7a64d6ca0cfb810e11a87896fb654afea1d  regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb
ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e  cosmolith_0.1.0-1-1regolith-resolute_amd64.deb
5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f  cosmic-settings_1.0.12-1-1regolith-resolute_amd64.deb
16dbe4a274d31080055a6f0a2699f9b9d0d1a542c44798c9724ff3a0bfbb2fe1  cosmic-settings-daemon_0.1.0-1-1regolith-resolute_amd64.deb
MANIFEST
)
[[ "$(cat "${manifest}")" == "${expected_manifest}" ]]
[[ "$(wc -l <"${manifest}")" -eq 7 ]]

tuple_contract=(
  '8e3559e8dfd1eb33cbe3187da4772055a4f0ee048d69bf188ca0196b43635643|regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb|regolith-session-cosmic.deb'
  'bcf78bbabd644bc2e4c382c7eefb0a525e9f1b7dc4852b0473213901989dcf7f|regolith-session-common_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb|regolith-session-common.deb'
  'a277811b7843791b3556f2bbb0d5c5a600b483f41f34d71f5f75cad08886aa19|regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb|regolith-inputd.deb'
  '949b9aedf8b4e64f2feeabc67947e7a64d6ca0cfb810e11a87896fb654afea1d|regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb|regolith-displayd.deb'
  'ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e|cosmolith_0.1.0-1-1regolith-resolute_amd64.deb|cosmolith.deb'
  '5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f|cosmic-settings_1.0.12-1-1regolith-resolute_amd64.deb|cosmic-settings.deb'
  '16dbe4a274d31080055a6f0a2699f9b9d0d1a542c44798c9724ff3a0bfbb2fe1|cosmic-settings-daemon_0.1.0-1-1regolith-resolute_amd64.deb|cosmic-settings-daemon.deb'
)
[[ ${#tuple_contract[@]} -eq 7 ]]
for entry in "${tuple_contract[@]}"; do
  IFS='|' read -r sha manifest_name staged_name <<<"${entry}"
  grep -Fq "${sha}" "${runbook}"
  grep -Fq "${manifest_name}" "${manifest}"
  grep -Fq "${staged_name}" "${runbook}"
done

source_contract=(
  'readonly SESSION_SOURCE=54d5684'
  'readonly INPUTD_SOURCE=rahul/voulage-vendor-optin-20260818'
  'readonly DISPLAYD_SOURCE=rahul/cosmic-live-apply-20260818'
  'readonly COSMOLITH_SOURCE=592c1f6'
  'readonly SETTINGS_SOURCE=e530ab7'
)
for source_ref in "${source_contract[@]}"; do
  grep -Fq "${source_ref}" "${runbook}"
done
! grep -Eq '3b3309a|91bdd26' "${runbook}"

[[ "$(bash "${runbook}" --contract-test)" == 'CONTRACT_TUPLE=PASS' ]]
grep -Fq "apt-get install -y --allow-downgrades /tmp/regolith-final-cosmic-tuple-pkgs/*.deb" "${runbook}"
! grep -Fq "apt-get install -y /tmp/regolith-final-cosmic-tuple-pkgs/*.deb" "${runbook}"
grep -q 'printf.*GUEST_PASS.*guest_ssh_with_stdin' "${runbook}"
! grep -A4 '^guest_ssh_with_stdin()' "${runbook}" | grep -q '/dev/null'

tmp=$(mktemp -d)
trap 'rm -rf -- "${tmp}"' EXIT

OVERLAY=${tmp}/overlay.qcow2
HMP=${tmp}/hmp.sock
LOG=${tmp}/qemu.log
STAGE_DIR=${tmp}/stage
KNOWN_HOSTS=${tmp}/known_hosts
mkdir -p "${STAGE_DIR}"
: >"${OVERLAY}"
: >"${HMP}"
: >"${LOG}"
: >"${KNOWN_HOSTS}"

env OVERLAY="${OVERLAY}" HMP="${HMP}" LOG="${LOG}" \
  STAGE_DIR="${STAGE_DIR}" KNOWN_HOSTS="${KNOWN_HOSTS}" \
  bash -c 'source "$1"; cleanup' bash "${runbook}"

[[ ! -e "${OVERLAY}" && ! -e "${HMP}" && ! -e "${LOG}" && ! -e "${KNOWN_HOSTS}" ]]
[[ ! -e "${STAGE_DIR}" ]]

fake_bin=${tmp}/bin
mkdir -p "${fake_bin}"
printf '#!/usr/bin/env bash\ncat >"$CAPTURE"\n' >"${fake_bin}/ssh"
chmod +x "${fake_bin}/ssh"
capture=${tmp}/captured-stdin
printf 'secret-from-pipe\n' | env PATH="${fake_bin}:${PATH}" CAPTURE="${capture}" \
  bash -c 'source "$1"; guest_ssh_with_stdin test-command' bash "${runbook}"
[[ "$(cat "${capture}")" == 'secret-from-pipe' ]]
printf 'RUNBOOK_CONTRACT=PASS\n'
