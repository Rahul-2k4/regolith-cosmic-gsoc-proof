#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/audit-session-package-metadata.sh package.deb [package.deb ...]

readonly GNOME_BOOTSTRAP_PACKAGES='gnome-session gnome-session-bin gnome-shell gnome-settings-daemon gnome-flashback gnome-keyring'

usage() {
  printf 'Usage: %s package.deb [package.deb ...]\n' "${0##*/}"
}

if [ "$#" -eq 0 ]; then
  usage >&2
  exit 2
fi

if ! command -v dpkg-deb >/dev/null 2>&1; then
  printf 'ERROR: dpkg-deb is required but was not found in PATH\n' >&2
  exit 127
fi

is_forbidden_direct_name() {
  local name=$1
  local forbidden
  for forbidden in ${GNOME_BOOTSTRAP_PACKAGES} kanshi; do
    if [ "${name}" = "${forbidden}" ]; then
      return 0
    fi
  done
  return 1
}

audit_direct_relations() {
  local package_name=$1
  local field_value=$2
  local relation
  local alternative
  local name

  case "${package_name}" in
    regolith-session-cosmic) ;;
    *) return 0 ;;
  esac

  for relation in ${field_value//,/ }; do
    for alternative in ${relation//|/ }; do
      name=${alternative%%[[:space:](<>=]*}
      name=${name%%:*}
      if is_forbidden_direct_name "${name}"; then
        printf 'ERROR: %s directly declares forbidden package %s\n' "${package_name}" "${name}" >&2
        return 1
      fi
    done
  done
}

for deb in "$@"; do
  if [ ! -f "${deb}" ]; then
    printf 'ERROR: Debian package not found: %s\n' "${deb}" >&2
    exit 2
  fi

  package_name=$(dpkg-deb --field "${deb}" Package) || {
    printf 'ERROR: cannot read Debian metadata: %s\n' "${deb}" >&2
    exit 1
  }
  printf '%s\n' "--- ${deb} ---"
  printf '%s: %s\n' "Package" "${package_name}"
  for field in Version Depends Recommends Suggests Breaks Conflicts Replaces; do
    value=$(dpkg-deb --field "${deb}" "${field}" 2>/dev/null || true)
    printf '%s: %s\n' "${field}" "${value}"
    case "${field}" in
      Depends|Recommends|Suggests)
        audit_direct_relations "${package_name}" "${value}"
        ;;
    esac
  done
done
