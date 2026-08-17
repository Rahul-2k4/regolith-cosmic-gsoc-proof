#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
runbook=${repo_root}/scripts/run-final-cosmic-tuple.sh

[[ "$(bash "${runbook}" --contract-test)" == 'CONTRACT_TUPLE=PASS' ]]
for source in 54d5684 10ba5d8 ba8a35a 592c1f6 e530ab7; do
  grep -q "${source}" "${runbook}"
done

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
printf 'RUNBOOK_CONTRACT=PASS\n'
