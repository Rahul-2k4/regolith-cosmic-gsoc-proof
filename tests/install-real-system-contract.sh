#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
SCRIPT=$ROOT_DIR/scripts/install-real-system.sh
MANIFEST=$ROOT_DIR/artifacts/mentor-test-2026-08-18.sha256
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/install-real-system-contract.XXXXXX")
MOCK_BIN=$TEST_ROOT/bin
PACKAGE_DIR=$TEST_ROOT/packages
ROOT_PREFIX=$TEST_ROOT/system
STATE_ROOT=$TEST_ROOT/state
OS_RELEASE_FILE=$TEST_ROOT/os-release
COMMAND_LOG=$TEST_ROOT/commands.log
OUTPUT=$TEST_ROOT/output.log
PACKAGE_DB_MARKER=$TEST_ROOT/package-db-post
FAILURES=0

readonly -a PACKAGE_FILES=(
    regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb
    regolith-session-common_1.2.0-1ubuntu1-2-1regolith-resolute_amd64.deb
    regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb
    regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb
    cosmolith_0.1.0-1-1regolith-resolute_amd64.deb
    cosmic-settings_1.0.12-1-1regolith-resolute_amd64.deb
    cosmic-settings-daemon_0.1.0-1-1regolith-resolute_amd64.deb
)
readonly -a PACKAGE_HASHES=(
    8e3559e8dfd1eb33cbe3187da4772055a4f0ee048d69bf188ca0196b43635643
    b30a39055ee49783aaf51025da0818ea746043af057c5d784fa4d44a5cc0d066
    a277811b7843791b3556f2bbb0d5c5a600b483f41f34d71f5f75cad08886aa19
    949b9aedf8b4e64f2feeabc67947e7a64d6ca0cfb810e11a87896fb654afea1d
    ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e
    5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f
    16dbe4a274d31080055a6f0a2699f9b9d0d1a542c44798c9724ff3a0bfbb2fe1
)
cleanup() { rm -rf -- "$TEST_ROOT"; }
trap cleanup EXIT
mkdir -p -- "$MOCK_BIN" "$PACKAGE_DIR" "$ROOT_PREFIX" "$STATE_ROOT"

write_mock() {
    local name=$1
    shift
    printf '%s\n' "$*" >"$MOCK_BIN/$name"
    chmod +x "$MOCK_BIN/$name"
}
write_mock uname '#!/usr/bin/env bash
case ${1:-} in
  -s) printf "%s\n" "${MOCK_UNAME_S:-Linux}" ;;
  -m) printf "%s\n" "${MOCK_UNAME_M:-x86_64}" ;;
  *) exit 2 ;;
esac'
write_mock sha256sum '#!/usr/bin/env bash
file=${@: -1}
case $(basename -- "$file") in
  regolith-session-cosmic_*) hash=8e3559e8dfd1eb33cbe3187da4772055a4f0ee048d69bf188ca0196b43635643 ;;
  regolith-session-common_*) hash=b30a39055ee49783aaf51025da0818ea746043af057c5d784fa4d44a5cc0d066 ;;
  regolith-inputd_*) hash=a277811b7843791b3556f2bbb0d5c5a600b483f41f34d71f5f75cad08886aa19 ;;
  regolith-displayd_*) hash=949b9aedf8b4e64f2feeabc67947e7a64d6ca0cfb810e11a87896fb654afea1d ;;
  cosmolith_*) hash=ad5af5edee6d278c4b9990c02f13ea3b715e260686cc6b58f2f5c48f6e6bb04e ;;
  cosmic-settings-daemon_*) hash=16dbe4a274d31080055a6f0a2699f9b9d0d1a542c44798c9724ff3a0bfbb2fe1 ;;
  cosmic-settings_*) hash=5459b91e7d5281ff0727cef8431a31a7e1dc4a70031da855984938068563d29f ;;
  *) exit 1 ;;
esac
[[ ${MOCK_BAD_HASH:-0} == 1 ]] && hash=bad
printf "%s  %s\n" "$hash" "$file"'
write_mock dpkg-deb '#!/usr/bin/env bash
file=$2 field=$3
case $field in
  Package) [[ -n ${MOCK_DEB_PACKAGE:-} ]] && printf "%s\n" "$MOCK_DEB_PACKAGE" || basename -- "$file" | sed -E "s/_.*//" ;;
  Version) base=$(basename -- "$file"); version=${base#*_}; printf "%s\n" "${MOCK_DEB_VERSION:-${version%_amd64.deb}}" ;;
  Architecture) printf "%s\n" "${MOCK_DEB_ARCH:-amd64}" ;;
  Pre-Depends) [[ $(basename -- "$file") == cosmic-settings-daemon_* ]] && printf "pre-required\n" ;;
  Depends) [[ $(basename -- "$file") == regolith-session-cosmic_* ]] && printf "cosmic-session (>= 1), sway | swayfx\n" ;;
  *) exit 1 ;;
esac'
write_mock dpkg-query '#!/usr/bin/env bash
if [[ $* == *binary:Package* ]]; then
  printf "pre-existing\t9.0\nregolith-session-cosmic\t1.0\nregolith-session-common\t1.0\nregolith-inputd\t1.0\nregolith-displayd\t1.0\ncosmic-settings\t1.0\ncosmic-settings-daemon\t1.0\n"
  [[ ! -e $PACKAGE_DB_MARKER ]] || printf "cosmolith\t1.0\ntransitive-new\t2.0\n"
  exit 0; fi
[[ $* != *Version* && $* == *Status-Status* ]] && { printf "installed\n"; exit 0; }
package=${@: -1}
if [[ ${MOCK_BASELINE_ABSENT:-} == "$package" ]]; then
  exit 1
else
  printf "installed\t1.0\n"
fi'
write_mock dpkg '#!/usr/bin/env bash
case ${1:-} in
  --print-architecture) printf "amd64\n" ;;
  --audit) exit 0 ;;
  --get-selections) printf "regolith-session-cosmic\tinstall\nregolith-session-common\thold\n" ;;
  *) exit 0 ;;
esac'
write_mock apt-mark '#!/usr/bin/env bash
[[ ${1:-} == showmanual ]] || exit 2
printf "pre-existing\nregolith-session-common\n"'

write_mock apt-cache '#!/usr/bin/env bash
printf "apt-cache" >>"$COMMAND_LOG"
for arg in "$@"; do printf " %q" "$arg" >>"$COMMAND_LOG"; done
printf "\n" >>"$COMMAND_LOG"
package=${@: -1}
if [[ ${MOCK_APT_NONE:-0} == 1 || ( ${MOCK_PREDEP_NONE:-0} == 1 && $package == pre-required ) ]]; then printf "Candidate: (none)\n"; else printf "Candidate: 1.0\n"; fi'

write_mock apt-get '#!/usr/bin/env bash
printf "apt-get" >>"$COMMAND_LOG"
for arg in "$@"; do printf " %q" "$arg" >>"$COMMAND_LOG"; done
printf "\n" >>"$COMMAND_LOG"
if [[ ${1:-} == install ]]; then
  [[ -z ${MUTATE_SOURCE:-} ]] || printf "changed\n" >"$MUTATE_SOURCE"
  for arg in "$@"; do [[ $arg != *.deb ]] || grep -qx deb "$arg" || exit 9; done
  : >"$PACKAGE_DB_MARKER"
fi'

write_mock curl '#!/usr/bin/env bash
printf "curl" >>"$COMMAND_LOG"
for arg in "$@"; do printf " %q" "$arg" >>"$COMMAND_LOG"; done
printf "\n" >>"$COMMAND_LOG"
while (($#)); do [[ $1 == -o ]] && { printf deb >"$2"; exit 0; }; shift; done
exit 2'

write_mock systemctl '#!/usr/bin/env bash
unit=${@: -1}
case $unit in
  graphical-session.target) state=${MOCK_GRAPHICAL_STATE:-active} ;;
  regolith-cosmic.target) state=${MOCK_COSMIC_STATE:-active} ;;
  regolith-gnome.target) state=${MOCK_GNOME_STATE:-inactive} ;;
  regolith-init-inputd.service) state=${MOCK_INPUTD_STATE:-active} ;;
  regolith-init-displayd.service) state=${MOCK_DISPLAYD_STATE:-active} ;;
  *) state=inactive ;;
esac
printf "%s\n" "$state"
[[ $state == active ]]'

write_mock sudo '#!/usr/bin/env bash
printf "sudo" >>"$COMMAND_LOG"
for arg in "$@"; do printf " %q" "$arg" >>"$COMMAND_LOG"; done
printf "\n" >>"$COMMAND_LOG"
"$@"'

write_os() { printf 'ID=%s\nVERSION_ID="%s"\nVERSION_CODENAME=%s\n' "$1" "$2" "$3" >"$OS_RELEASE_FILE"; }
prepare_packages() {
    rm -f -- "$PACKAGE_DIR"/*.deb
    local package
    for package in "${PACKAGE_FILES[@]}"; do printf 'deb\n' >"$PACKAGE_DIR/$package"; done
}
prepare_system_files() {
    mkdir -p -- "$ROOT_PREFIX/usr/share/wayland-sessions" "$ROOT_PREFIX/usr/lib/systemd/user"
    : >"$ROOT_PREFIX/usr/share/wayland-sessions/regolith-cosmic.desktop"
    : >"$ROOT_PREFIX/usr/lib/systemd/user/regolith-cosmic.target"
    : >"$ROOT_PREFIX/usr/lib/systemd/user/regolith-gnome.target"
    : >"$ROOT_PREFIX/usr/lib/systemd/user/regolith-init-inputd.service"
    : >"$ROOT_PREFIX/usr/lib/systemd/user/regolith-init-displayd.service"
}
reset_case() {
    : >"$COMMAND_LOG"; : >"$OUTPUT"
    rm -rf -- "$STATE_ROOT"/* "$ROOT_PREFIX"/*; rm -f -- "$PACKAGE_DB_MARKER"
    prepare_packages; write_os pop 24.04 noble
    unset MOCK_BAD_HASH MOCK_DEB_ARCH MOCK_DEB_PACKAGE MOCK_DEB_VERSION MOCK_APT_NONE MOCK_PREDEP_NONE MOCK_BASELINE_ABSENT
    unset MOCK_GRAPHICAL_STATE MOCK_COSMIC_STATE MOCK_GNOME_STATE MOCK_INPUTD_STATE MOCK_DISPLAYD_STATE MUTATE_SOURCE
}
run_script() {
    PATH="$MOCK_BIN:$PATH" COMMAND_LOG="$COMMAND_LOG" OS_RELEASE_FILE="$OS_RELEASE_FILE" \
    ROOT_PREFIX="$ROOT_PREFIX" STATE_ROOT="$STATE_ROOT" NOW=baseline-test PACKAGE_DB_MARKER="$PACKAGE_DB_MARKER" \
    "$SCRIPT" "$@" >"$OUTPUT" 2>&1
}
assert_contains() {
    local needle=$1 file=$2
    grep -Fq -- "$needle" "$file" || { printf 'FAIL: expected %q in %s\n' "$needle" "$file" >&2; cat -- "$file" >&2; FAILURES=$((FAILURES + 1)); }
}
assert_not_contains() {
    local needle=$1 file=$2
    ! grep -Fq -- "$needle" "$file" || { printf 'FAIL: unexpected %q in %s\n' "$needle" "$file" >&2; cat -- "$file" >&2; FAILURES=$((FAILURES + 1)); }
}
expect_failure() {
    run_script "$@" && { printf 'FAIL: expected command failure: %s\n' "$*" >&2; FAILURES=$((FAILURES + 1)); return 0; }
    return 0
}

test_manifest_contract() {
    (( $(wc -l <"$MANIFEST") == 7 )) || { printf 'FAIL: manifest must have seven lines\n' >&2; FAILURES=$((FAILURES + 1)); }
    local index
    for index in "${!PACKAGE_FILES[@]}"; do
        assert_contains "${PACKAGE_HASHES[index]}  ${PACKAGE_FILES[index]}" "$MANIFEST"
    done
}

test_os_and_metadata_guards() {
    reset_case; write_os ubuntu 24.04 noble
    expect_failure check --package-dir "$PACKAGE_DIR"
    assert_contains 'FAIL: unsupported OS' "$OUTPUT"
    run_script check --package-dir "$PACKAGE_DIR" --allow-unsupported
    assert_contains 'PASS: host compatibility override' "$OUTPUT"
    reset_case; MOCK_BAD_HASH=1 expect_failure check --package-dir "$PACKAGE_DIR"
    assert_contains 'FAIL: checksum mismatch' "$OUTPUT"
    reset_case; MOCK_DEB_PACKAGE=wrong-name expect_failure check --package-dir "$PACKAGE_DIR"
    assert_contains 'FAIL: package identity' "$OUTPUT"
    reset_case; MOCK_DEB_VERSION=0.0.0 expect_failure check --package-dir "$PACKAGE_DIR"
    assert_contains 'FAIL: package version' "$OUTPUT"
    reset_case; MOCK_DEB_ARCH=arm64 expect_failure check --package-dir "$PACKAGE_DIR"
    assert_contains 'FAIL: package architecture' "$OUTPUT"
    reset_case; rm -- "$PACKAGE_DIR/${PACKAGE_FILES[0]}"; ln -s "${PACKAGE_FILES[1]}" "$PACKAGE_DIR/${PACKAGE_FILES[0]}"
    expect_failure check --package-dir "$PACKAGE_DIR"; assert_contains 'FAIL: package source must be a regular file' "$OUTPUT"
}

test_preflight_and_download() {
    reset_case; MOCK_APT_NONE=1 expect_failure check --package-dir "$PACKAGE_DIR"
    assert_contains 'FAIL: no apt candidate' "$OUTPUT"
    reset_case; MOCK_PREDEP_NONE=1 expect_failure check --package-dir "$PACKAGE_DIR"
    assert_contains 'FAIL: no apt candidate for dependency: pre-required' "$OUTPUT"
    reset_case; run_script check
    local package
    [[ $(grep -c '^curl -fL' "$COMMAND_LOG" || true) == 7 ]] || { printf 'FAIL: expected seven downloads\n' >&2; FAILURES=$((FAILURES + 1)); }
    for package in "${PACKAGE_FILES[@]}"; do
        assert_contains "https://github.com/Rahul-2k4/regolith-cosmic-gsoc-proof/releases/download/mentor-test-2026-08-18/$package" "$COMMAND_LOG"
    done
    reset_case; run_script check --release-tag release-candidate
    assert_contains "https://github.com/Rahul-2k4/regolith-cosmic-gsoc-proof/releases/download/release-candidate/${PACKAGE_FILES[0]}" "$COMMAND_LOG"
    reset_case; run_script check --base-url https://packages.example.test/regolith
    assert_contains "https://packages.example.test/regolith/${PACKAGE_FILES[0]}" "$COMMAND_LOG"
    assert_contains 'PASS: package set validated' "$OUTPUT"
}

test_dry_run_is_non_mutating() {
    reset_case; run_script install --dry-run --package-dir "$PACKAGE_DIR"
    assert_contains 'DRY-RUN: would install exactly 7 packages' "$OUTPUT"
    assert_not_contains 'sudo' "$COMMAND_LOG"; assert_not_contains 'curl' "$COMMAND_LOG"; assert_not_contains 'apt-get' "$COMMAND_LOG"
    [[ ! -e $STATE_ROOT/baseline-test ]] || { printf 'FAIL: dry run created baseline\n' >&2; FAILURES=$((FAILURES + 1)); }
    reset_case; MOCK_BAD_HASH=1 expect_failure install --dry-run --package-dir "$PACKAGE_DIR"
    assert_contains 'FAIL: checksum mismatch' "$OUTPUT"
    reset_case; MOCK_DEB_PACKAGE=wrong-name expect_failure install --dry-run --package-dir "$PACKAGE_DIR"
    assert_contains 'FAIL: package identity' "$OUTPUT"
    reset_case; MOCK_APT_NONE=1 expect_failure install --dry-run --package-dir "$PACKAGE_DIR"
    assert_contains 'FAIL: no apt candidate' "$OUTPUT"
}
test_install_is_one_exact_apt_transaction() {
    reset_case; MUTATE_SOURCE="$PACKAGE_DIR/${PACKAGE_FILES[0]}" MOCK_BASELINE_ABSENT=cosmolith run_script install --package-dir "$PACKAGE_DIR" || { printf 'FAIL: frozen install transaction failed\n' >&2; FAILURES=$((FAILURES + 1)); }
    [[ $(grep -c '^apt-get install -y' "$COMMAND_LOG" || true) == 1 ]] || { printf 'FAIL: install was not one apt transaction\n' >&2; FAILURES=$((FAILURES + 1)); }
    local package
    for package in "${PACKAGE_FILES[@]}"; do assert_not_contains "$PACKAGE_DIR/$package" "$COMMAND_LOG"; done
    grep -Eq '^apt-get install -y .*/install-real-system\.[^/]*/packages/' "$COMMAND_LOG" || { printf 'FAIL: apt did not use private staged paths\n' >&2; FAILURES=$((FAILURES + 1)); }
    assert_contains 'sudo dpkg --audit' "$COMMAND_LOG"; assert_contains 'BASELINE:' "$OUTPUT"
    assert_contains 'sudo install -d -m 0755' "$COMMAND_LOG"
    [[ $(grep -c '^sudo install -m 0644' "$COMMAND_LOG" || true) == 7 ]] || { printf 'FAIL: baseline metadata is not installed readable\n' >&2; FAILURES=$((FAILURES + 1)); }
    [[ -f $STATE_ROOT/baseline-test/tuple-state.tsv && -f $STATE_ROOT/baseline-test/dpkg-selections.txt && -f $STATE_ROOT/baseline-test/installed-packages.tsv && -f $STATE_ROOT/baseline-test/apt-mark-manual.txt ]] || { printf 'FAIL: incomplete baseline\n' >&2; FAILURES=$((FAILURES + 1)); }
    cmp -s -- "$MANIFEST" "$STATE_ROOT/baseline-test/bundle-manifest.sha256" || { printf 'FAIL: baseline manifest differs\n' >&2; FAILURES=$((FAILURES + 1)); }
    (( $(wc -l <"$STATE_ROOT/baseline-test/tuple-state.tsv") == 7 )) || { printf 'FAIL: baseline tuple row count\n' >&2; FAILURES=$((FAILURES + 1)); }
    assert_contains $'regolith-session-cosmic\tinstalled\t1.0' "$STATE_ROOT/baseline-test/tuple-state.tsv"
    assert_contains $'cosmolith\tabsent\tABSENT' "$STATE_ROOT/baseline-test/tuple-state.tsv"
    assert_contains $'transitive-new\t2.0' "$STATE_ROOT/baseline-test/post-install-packages.tsv"
    assert_contains 'cosmolith' "$STATE_ROOT/baseline-test/introduced-packages.txt"
    assert_contains 'transitive-new' "$STATE_ROOT/baseline-test/introduced-packages.txt"
}
test_verify_statuses() {
    reset_case; prepare_system_files; local bad_state
    XDG_CURRENT_DESKTOP=COSMIC run_script verify
    assert_contains 'PASS: desktop entry' "$OUTPUT"; assert_contains 'PASS: regolith-cosmic.target active' "$OUTPUT"
    assert_contains 'PASS: regolith-gnome.target inactive' "$OUTPUT"; assert_contains 'PASS: regolith-init-inputd.service active' "$OUTPUT"
    MOCK_COSMIC_STATE=inactive XDG_CURRENT_DESKTOP=COSMIC expect_failure verify
    assert_contains 'FAIL: regolith-cosmic.target expected active' "$OUTPUT"
    for bad_state in failed activating unknown; do
        MOCK_COSMIC_STATE=active MOCK_GNOME_STATE=$bad_state XDG_CURRENT_DESKTOP=COSMIC expect_failure verify
        assert_contains "FAIL: regolith-gnome.target expected inactive, got $bad_state" "$OUTPUT"
    done
    MOCK_GRAPHICAL_STATE=inactive run_script verify
    assert_contains 'SKIP: runtime checks outside graphical session' "$OUTPUT"
}
test_rollback_scope() {
    reset_case; mkdir -p -- "$STATE_ROOT/manual-baseline"
    printf 'regolith-session-cosmic\tabsent\tABSENT\nregolith-session-common\tinstalled\t1.0\nregolith-inputd\tinstalled\t1.0\nregolith-displayd\tinstalled\t1.0\ncosmolith\tinstalled\t1.0\ncosmic-settings\tinstalled\t1.0\ncosmic-settings-daemon\tinstalled\t1.0\n' >"$STATE_ROOT/manual-baseline/tuple-state.tsv"
    cp -- "$MANIFEST" "$STATE_ROOT/manual-baseline/bundle-manifest.sha256"
    printf 'regolith-session-common\thold\n' >"$STATE_ROOT/manual-baseline/dpkg-selections.txt"
    printf 'pre-existing\t9.0\nregolith-session-common\t1.0\n' >"$STATE_ROOT/manual-baseline/installed-packages.tsv"
    printf 'pre-existing\n' >"$STATE_ROOT/manual-baseline/apt-mark-manual.txt"
    printf 'pre-existing\t9.0\nregolith-session-common\t1.0\nregolith-session-cosmic\t1.0\ntransitive-new\t2.0\n' >"$STATE_ROOT/manual-baseline/post-install-packages.tsv"
    printf 'regolith-session-cosmic\ntransitive-new\n' >"$STATE_ROOT/manual-baseline/introduced-packages.txt"
    run_script rollback "$STATE_ROOT/manual-baseline"
    assert_contains 'apt-get remove -y regolith-session-cosmic transitive-new' "$COMMAND_LOG"
    assert_not_contains 'apt-get remove -y regolith-session-common' "$COMMAND_LOG"
    assert_not_contains 'autoremove' "$COMMAND_LOG"
    assert_contains 'MANUAL: restore regolith-session-common to exact version 1.0' "$OUTPUT"
    printf '../bad\n' >"$STATE_ROOT/manual-baseline/introduced-packages.txt"; expect_failure rollback "$STATE_ROOT/manual-baseline"
    assert_contains 'FAIL: malformed baseline' "$OUTPUT"
    rm -- "$STATE_ROOT/manual-baseline/introduced-packages.txt"; expect_failure rollback "$STATE_ROOT/manual-baseline"
    assert_contains 'FAIL: baseline is missing' "$OUTPUT"
    reset_case; expect_failure rollback "$STATE_ROOT/missing"
    assert_contains 'FAIL: baseline is missing' "$OUTPUT"
}
test_manifest_contract
[[ -x $SCRIPT ]] || { printf 'FAIL: installer is absent or not executable: %s\n' "$SCRIPT" >&2; exit 1; }
test_os_and_metadata_guards
test_preflight_and_download
test_dry_run_is_non_mutating
test_install_is_one_exact_apt_transaction
test_verify_statuses
test_rollback_scope
(( FAILURES == 0 )) || { printf 'FAIL: %d contract assertion(s) failed\n' "$FAILURES" >&2; exit 1; }
printf 'PASS: install-real-system contract\n'
