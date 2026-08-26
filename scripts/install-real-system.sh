#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
readonly SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
readonly DEFAULT_RELEASE_TAG=mentor-test-2026-08-18
readonly MANIFEST_FILE=$SCRIPT_DIR/../artifacts/mentor-test-2026-08-18.sha256
ACTION=${1:-}; [[ -n $ACTION ]] && shift || true
PACKAGE_DIR= DRY_RUN=0 RELEASE_TAG=$DEFAULT_RELEASE_TAG BASE_URL= BASE_URL_SET=0
ALLOW_UNSUPPORTED=0 BASELINE_ARG= TMP_WORK= BUNDLE_DIR=
OS_RELEASE_FILE=${OS_RELEASE_FILE:-/etc/os-release}
ROOT_PREFIX=${ROOT_PREFIX:-}
GNOME_TARGET_PATH=/usr/lib/systemd/user/regolith-gnome.target
GDM_HELPER_UNIT=sway-audio-idle-inhibit.service
GDM_HELPER_PACKAGE=sway-audio-idle-inhibit
GDM_HELPER_LINK=/etc/systemd/user/default.target.wants/sway-audio-idle-inhibit.service
REGOLITH_UNSTABLE_MARKER=archive.regolith-desktop.com/ubuntu/unstable
STATE_ROOT=${STATE_ROOT:-${ROOT_PREFIX}/var/lib/regolith-cosmic-gsoc}
NOW=${NOW:-$(date -u +%Y%m%dT%H%M%SZ)}
PACKAGE_FILES=(); PACKAGE_HASHES=(); PACKAGE_NAMES=()
cleanup() {
    [[ -z $TMP_WORK ]] || rm -rf -- "$TMP_WORK"
}
trap cleanup EXIT
fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}
usage() {
    printf 'Usage: %s {check|install|verify|prepare-gdm} [options]\n' "$0" >&2
    printf '       %s rollback BASELINE [options]\n' "$0" >&2
    exit 2
}
case $ACTION in
    check|install|verify|prepare-gdm) ;;
    rollback) (($#)) || usage; BASELINE_ARG=$1; shift ;;
    *) usage ;;
esac
while (($#)); do
    case $1 in
        --package-dir) (($# >= 2)) || usage; PACKAGE_DIR=$2; shift 2 ;;
        --dry-run) DRY_RUN=1; shift ;;
        --release-tag) (($# >= 2)) || usage; RELEASE_TAG=$2; shift 2 ;;
        --base-url) (($# >= 2)) || usage; BASE_URL=$2; BASE_URL_SET=1; shift 2 ;;
        --allow-unsupported) ALLOW_UNSUPPORTED=1; shift ;;
        *) usage ;;
    esac
done
if (( ! BASE_URL_SET )); then
    BASE_URL=https://github.com/Rahul-2k4/regolith-cosmic-gsoc-proof/releases/download/$RELEASE_TAG
fi
BASE_URL=${BASE_URL%/}
ensure_tmp() {
    if [[ -z $TMP_WORK ]]; then
        TMP_WORK=$(mktemp -d "/tmp/install-real-system.XXXXXX")
    fi
}
load_manifest() {
    [[ -f $MANIFEST_FILE ]] || fail "bundle manifest missing: $MANIFEST_FILE"
    local hash file extra prior
    while IFS=' ' read -r hash file extra; do
        [[ -n $hash && -n $file && -z ${extra:-} ]] || fail "malformed bundle manifest"
        [[ $hash =~ ^[0-9a-f]{64}$ ]] || fail "malformed bundle manifest hash: $hash"
        [[ $file != */* && $file == *_amd64.deb ]] || fail "malformed bundle manifest filename: $file"
        for prior in "${PACKAGE_FILES[@]}"; do
            [[ $prior != "$file" ]] || fail "duplicate bundle manifest filename: $file"
        done
        PACKAGE_HASHES+=("$hash")
        PACKAGE_FILES+=("$file")
        PACKAGE_NAMES+=("${file%%_*}")
    done <"$MANIFEST_FILE"
    ((${#PACKAGE_FILES[@]} == 7)) || fail "bundle manifest must contain exactly 7 packages"
}
read_os_release() {
    [[ -r $OS_RELEASE_FILE ]] || fail "OS release file is unreadable: $OS_RELEASE_FILE"
    OS_ID= OS_VERSION= OS_CODENAME=
    local key value
    while IFS='=' read -r key value; do
        value=${value#\"}
        value=${value%\"}
        case $key in
            ID) OS_ID=$value ;;
            VERSION_ID) OS_VERSION=$value ;;
            VERSION_CODENAME) OS_CODENAME=$value ;;
        esac
    done <"$OS_RELEASE_FILE"
}
check_host() {
    read_os_release
    local reason=
    [[ $(uname -s) == Linux ]] || reason="kernel $(uname -s), expected Linux"
    case $(uname -m) in
        x86_64|amd64) ;;
        *) reason="architecture $(uname -m), expected amd64" ;;
    esac
    [[ $(dpkg --print-architecture) == amd64 ]] || reason="dpkg architecture is not amd64"
    if ! { [[ $OS_ID == pop && $OS_VERSION == 24.04 ]] || [[ $OS_ID == ubuntu && $OS_CODENAME == resolute ]]; }; then
        reason="unsupported OS: ID=$OS_ID VERSION_ID=$OS_VERSION VERSION_CODENAME=$OS_CODENAME"
    fi
    if [[ -n $reason ]]; then
        (( ALLOW_UNSUPPORTED )) || fail "$reason"
        printf 'PASS: host compatibility override (%s)\n' "$reason"
    else
        printf 'PASS: host compatibility\n'
    fi
}
is_bundled() {
    local wanted=$1 name
    for name in "${PACKAGE_NAMES[@]}"; do
        [[ $wanted != "$name" ]] || return 0
    done
    return 1
}
stage_local_bundle() {
    [[ -d $PACKAGE_DIR ]] || fail "package directory missing: $PACKAGE_DIR"
    ensure_tmp; BUNDLE_DIR=$TMP_WORK/packages; mkdir -m 0700 -p -- "$BUNDLE_DIR"
    local path file wanted expected found=0
    shopt -s nullglob dotglob
    for path in "$PACKAGE_DIR"/*; do
        [[ -f $path && ! -L $path ]] || fail "package source must be a regular file: $path"
        file=${path##*/}; [[ $file == *.deb ]] || continue; expected=0
        for wanted in "${PACKAGE_FILES[@]}"; do [[ $file != "$wanted" ]] || expected=1; done
        (( expected )) || fail "package set differs from manifest: unexpected $file"
        cp -- "$path" "$BUNDLE_DIR/$file"; chmod 0644 "$BUNDLE_DIR/$file"; found=$((found + 1))
    done
    shopt -u nullglob dotglob
    (( found == 7 )) || fail "package set differs from manifest: found $found of 7 packages"
    for file in "${PACKAGE_FILES[@]}"; do [[ -f $BUNDLE_DIR/$file ]] || fail "package set differs from manifest: missing $file"; done
}
acquire_bundle() {
    if [[ -n $PACKAGE_DIR ]]; then
        stage_local_bundle; return 0
    fi
    if (( DRY_RUN )); then
        local file
        for file in "${PACKAGE_FILES[@]}"; do
            printf 'DRY-RUN: would download %s/%s\n' "$BASE_URL" "$file"
        done
        return 2
    fi
    ensure_tmp
    BUNDLE_DIR=$TMP_WORK/packages
    mkdir -m 0700 -p -- "$BUNDLE_DIR"
    local file
    for file in "${PACKAGE_FILES[@]}"; do
        curl -fL "$BASE_URL/$file" -o "$BUNDLE_DIR/$file"
        chmod 0644 "$BUNDLE_DIR/$file"
    done
}

validate_packages() {
    local index file path actual package version architecture stem expected_version
    for index in "${!PACKAGE_FILES[@]}"; do
        file=${PACKAGE_FILES[index]}
        path=$BUNDLE_DIR/$file
        actual=$(sha256sum "$path")
        actual=${actual%% *}
        [[ $actual == "${PACKAGE_HASHES[index]}" ]] || fail "checksum mismatch: $file"
        package=$(dpkg-deb -f "$path" Package)
        [[ $package == "${PACKAGE_NAMES[index]}" ]] || fail "package identity mismatch: $file contains $package"
        stem=${file%_amd64.deb}
        expected_version=${stem#*_}
        version=$(dpkg-deb -f "$path" Version)
        [[ $version == "$expected_version" ]] || fail "package version mismatch: $file contains $version"
        architecture=$(dpkg-deb -f "$path" Architecture)
        [[ $architecture == amd64 ]] || fail "package architecture mismatch: $file contains $architecture"
    done
}

trim() {
    REPLY=$1
    REPLY=${REPLY#"${REPLY%%[![:space:]]*}"}
    REPLY=${REPLY%"${REPLY##*[![:space:]]}"}
}

dependency_available() {
    local clause=$1 alternative dependency
    local alternatives=()
    IFS='|' read -r -a alternatives <<<"$clause"
    for alternative in "${alternatives[@]}"; do
        dependency=${alternative%%(*}
        dependency=${dependency%%[*}
        dependency=${dependency%%<*}
        trim "$dependency"
        dependency=${REPLY%%:*}
        [[ -n $dependency && $dependency != \$* ]] || continue
        is_bundled "$dependency" && return 0
        # Capture first, then match. Piping straight into `grep -q` let grep
        # exit on the first match while apt-cache was still writing, which
        # raised SIGPIPE and, under `pipefail`, turned a successful match into
        # a pipeline failure.
        local policy
        policy=$(apt-cache policy "$dependency" 2>/dev/null || true)
        if grep -Eq 'Candidate:[[:space:]]+[^()]' <<<"$policy"; then
            return 0
        fi
    done
    return 1
}
preflight_dependencies() {
    local file field depends clause
    local clauses=()
    for file in "${PACKAGE_FILES[@]}"; do
        for field in Pre-Depends Depends; do
            depends=$(dpkg-deb -f "$BUNDLE_DIR/$file" "$field" 2>/dev/null || true)
            [[ -n $depends ]] || continue
            IFS=',' read -r -a clauses <<<"$depends"
            for clause in "${clauses[@]}"; do
                dependency_available "$clause" || fail "no apt candidate for dependency: $clause"
            done
        done
    done
    printf 'PASS: dependency preflight\n'
}
prepare_gdm() {
    local policy candidate link_path target enabled active
    policy=$(apt-cache policy "$GDM_HELPER_PACKAGE" 2>/dev/null || true)
    candidate=$(awk '/^[[:space:]]*Candidate:/ {print $2; exit}' <<<"$policy")
    if [[ -z $candidate || $candidate == '(none)' || $policy != *"$REGOLITH_UNSTABLE_MARKER"* ]]; then
        fail "Regolith unstable apt candidate missing for $GDM_HELPER_UNIT"
    fi
    printf 'PASS: Regolith unstable apt candidate: %s\n' "$candidate"

    link_path=${ROOT_PREFIX}${GDM_HELPER_LINK}
    if [[ -L $link_path ]]; then
        target=$(readlink -- "$link_path")
        [[ $target == /usr/lib/systemd/user/$GDM_HELPER_UNIT ]] || fail "stale helper link points to unexpected target: $target"
    elif [[ -e $link_path ]]; then
        fail "stale helper path is not the expected symlink: $link_path"
    else
        printf 'PASS: stale helper link absent\n'
    fi

    if (( DRY_RUN )); then
        printf 'DRY-RUN: would disable --now %s\n' "$GDM_HELPER_UNIT"
        if [[ -L $link_path ]]; then
            printf 'DRY-RUN: would unlink %s\n' "$link_path"
            printf 'DRY-RUN: would run systemctl --user daemon-reload\n'
        fi
        printf 'DRY-RUN: would verify %s is disabled and inactive\n' "$GDM_HELPER_UNIT"
        return 0
    fi

    if ! systemctl --user disable --now "$GDM_HELPER_UNIT"; then
        fail "could not disable $GDM_HELPER_UNIT"
    fi
    if [[ -L $link_path ]]; then
        sudo unlink -- "$link_path"
        systemctl --user daemon-reload
    fi
    [[ ! -e $link_path && ! -L $link_path ]] || fail "stale helper link remains: $link_path"
    enabled=$(systemctl --user is-enabled "$GDM_HELPER_UNIT" 2>/dev/null || true)
    [[ $enabled == disabled ]] || fail "$GDM_HELPER_UNIT is not disabled (state: ${enabled:-unknown})"
    active=$(systemctl --user is-active "$GDM_HELPER_UNIT" 2>/dev/null || true)
    [[ $active == inactive ]] || fail "$GDM_HELPER_UNIT is still active (state: ${active:-unknown})"
    printf 'PASS: %s disabled and inactive\n' "$GDM_HELPER_UNIT"
}
prepare_apt_access() {
    local owner_uid apt_uid apt_gid file
    owner_uid=$(id -u 2>/dev/null) || fail 'could not resolve the invoking user for APT staging'
    apt_uid=$(id -u _apt 2>/dev/null) || fail 'APT sandbox user _apt is missing'
    apt_gid=$(id -g _apt 2>/dev/null) || fail 'APT sandbox primary group for _apt is missing'
    [[ $owner_uid =~ ^[0-9]+$ && $apt_uid =~ ^[0-9]+$ && $apt_gid =~ ^[0-9]+$ ]] || fail 'invalid APT sandbox identity'
    sudo chown "$owner_uid:$apt_gid" "$TMP_WORK" "$BUNDLE_DIR"
    sudo chmod 0710 "$TMP_WORK" "$BUNDLE_DIR"
    for file in "${PACKAGE_FILES[@]}"; do
        sudo chown "$owner_uid:$apt_gid" "$BUNDLE_DIR/$file"
        sudo chmod 0640 "$BUNDLE_DIR/$file"
    done
}
check_cosmic_comp_present() {
    local state
    state=$(dpkg-query -W -f='${db:Status-Status}\n' cosmic-comp 2>/dev/null || true)
    [[ $state == installed ]] || fail "cosmic-comp is not installed. This installer only patches specific override packages onto an existing Regolith COSMIC install — it does not perform a full 'apt install regolith-session-cosmic' from scratch, and cosmic-comp is a Recommends (not a hard Depends) of cosmic-session, so a --no-install-recommends base install can be missing it silently. Install the base COSMIC session first (see docs/INSTALL.md prerequisites), confirm cosmic-comp is present, then re-run this installer."
}
check_bundle() {
    local acquire_status=0
    acquire_bundle || acquire_status=$?
    if (( acquire_status == 2 )); then
        printf 'SKIP: package validation requires downloaded files\n'
        return 2
    fi
    (( acquire_status == 0 )) || return "$acquire_status"
    validate_packages
    preflight_dependencies
    check_cosmic_comp_present
    printf 'PASS: package set validated\n'
}
capture_baseline() {
    ensure_tmp; local stage=$TMP_WORK/baseline baseline=$STATE_ROOT/$NOW
    local name record status version extra metadata
    [[ ! -e $baseline ]] || fail "baseline already exists: $baseline"
    mkdir -p -- "$stage"; : >"$stage/tuple-state.tsv"
    for name in "${PACKAGE_NAMES[@]}"; do
        if record=$(dpkg-query -W -f='${db:Status-Status}\t${Version}\n' "$name" 2>/dev/null); then
            IFS=$'\t' read -r status version extra <<<"$record"
            [[ -n $status && -n $version && -z ${extra:-} ]] || fail "could not capture package state: $name"
            printf '%s\t%s\t%s\n' "$name" "$status" "$version" >>"$stage/tuple-state.tsv"
        else
            printf '%s\tabsent\tABSENT\n' "$name" >>"$stage/tuple-state.tsv"
        fi
    done
    dpkg --get-selections >"$stage/dpkg-selections.txt"
    cp -- "$MANIFEST_FILE" "$stage/bundle-manifest.sha256"
    dpkg-query -W -f='${binary:Package}\t${Version}\n' | LC_ALL=C sort -u >"$stage/installed-packages.tsv"
    if command -v apt-mark >/dev/null; then apt-mark showmanual | LC_ALL=C sort -u >"$stage/apt-mark-manual.txt"
    else printf 'UNAVAILABLE\n' >"$stage/apt-mark-manual.txt"; fi
    # These files contain package metadata only; readable modes let the invoking user rollback.
    sudo install -d -m 0755 "$STATE_ROOT" "$baseline"
    for metadata in tuple-state.tsv dpkg-selections.txt bundle-manifest.sha256 installed-packages.tsv apt-mark-manual.txt; do
        sudo install -m 0644 "$stage/$metadata" "$baseline/$metadata"
    done
    BASELINE_PATH=$baseline
    printf 'BASELINE: %s\n' "$baseline"
}
install_bundle() {
    local check_status=0 file stage metadata
    local paths=()
    check_bundle || check_status=$?
    if (( DRY_RUN )); then
        (( check_status == 0 || check_status == 2 )) || return "$check_status"
        printf 'DRY-RUN: would install exactly 7 packages\n'
        return 0
    fi
    (( check_status == 0 )) || return "$check_status"
    capture_baseline
    prepare_apt_access
    for file in "${PACKAGE_FILES[@]}"; do
        paths+=("$BUNDLE_DIR/$file")
    done
    sudo apt-get install -y --no-install-recommends "${paths[@]}"
    stage=$TMP_WORK/baseline
    dpkg-query -W -f='${binary:Package}\t${Version}\n' | LC_ALL=C sort -u >"$stage/post-install-packages.tsv"
    LC_ALL=C comm -13 <(cut -f1 "$stage/installed-packages.tsv") <(cut -f1 "$stage/post-install-packages.tsv") >"$stage/introduced-packages.txt"
    for metadata in post-install-packages.tsv introduced-packages.txt; do sudo install -m 0644 "$stage/$metadata" "$BASELINE_PATH/$metadata"; done
    sudo dpkg --audit
    printf 'PASS: installed exactly 7 packages\n'
}

verify_system() {
    local failures=0 label path state desktop unit expected
    while IFS='|' read -r label path; do
        if [[ -f ${ROOT_PREFIX}$path ]]; then printf 'PASS: %s: %s\n' "$label" "$path"
        else printf 'FAIL: %s missing: %s\n' "$label" "$path"; failures=$((failures + 1)); fi
    done <<'FILES'
desktop entry|/usr/share/wayland-sessions/regolith-cosmic.desktop
regolith-cosmic.target unit|/usr/lib/systemd/user/regolith-cosmic.target
regolith-init-inputd.service unit|/usr/lib/systemd/user/regolith-init-inputd.service
regolith-init-displayd.service unit|/usr/lib/systemd/user/regolith-init-displayd.service
FILES
    # regolith-gnome.target belongs to the GNOME path, not to this COSMIC-only
    # bundle, so its absence is a normal outcome rather than a failure. When it
    # is present the runtime loop below still asserts it stays inactive.
    if [[ -f ${ROOT_PREFIX}$GNOME_TARGET_PATH ]]; then
        printf 'PASS: regolith-gnome.target unit: %s\n' "$GNOME_TARGET_PATH"
    else
        printf 'PASS: regolith-gnome.target absent (GNOME path not installed)\n'
    fi
    state=$(systemctl --user is-active graphical-session.target 2>/dev/null || true)
    if [[ $state != active ]]; then
        printf 'SKIP: runtime checks outside graphical session\n'; for unit in graphical-session.target regolith-cosmic.target regolith-gnome.target regolith-init-inputd.service regolith-init-displayd.service; do printf 'SKIP: %s runtime outside graphical session\n' "$unit"; done
        return "$failures"
    fi
    printf 'PASS: graphical-session.target active\n'
    desktop=$(printf '%s' "${XDG_CURRENT_DESKTOP:-}" | tr '[:lower:]' '[:upper:]')
    if [[ $desktop != *COSMIC* ]]; then
        for unit in regolith-cosmic.target regolith-gnome.target regolith-init-inputd.service regolith-init-displayd.service; do printf 'SKIP: %s runtime for desktop %s\n' "$unit" "${XDG_CURRENT_DESKTOP:-unknown}"; done
        return "$failures"
    fi
    for unit in regolith-cosmic.target regolith-gnome.target regolith-init-inputd.service regolith-init-displayd.service; do
        if [[ $unit == regolith-gnome.target && ! -f ${ROOT_PREFIX}$GNOME_TARGET_PATH ]]; then
            printf 'SKIP: regolith-gnome.target runtime (unit not installed)\n'; continue
        fi
        expected=active; [[ $unit == regolith-gnome.target ]] && expected=inactive
        state=$(systemctl --user is-active "$unit" 2>/dev/null || true)
        if { [[ $expected == active && $state == active ]] || [[ $expected == inactive && $state == inactive ]]; }; then
            printf 'PASS: %s %s\n' "$unit" "$expected"
        else
            printf 'FAIL: %s expected %s, got %s\n' "$unit" "$expected" "${state:-unknown}"
            failures=$((failures + 1))
        fi
    done
    (( failures == 0 ))
}

rollback_baseline() {
    local baseline=$BASELINE_ARG name status version extra known seen='|' rows=0 metadata state index
    local removals=() existing_names=() existing_versions=()
    [[ -d $baseline ]] || baseline=$STATE_ROOT/$BASELINE_ARG
    [[ -d $baseline ]] || fail "baseline is missing or incomplete: $baseline"
    for metadata in tuple-state.tsv dpkg-selections.txt bundle-manifest.sha256 installed-packages.tsv apt-mark-manual.txt post-install-packages.tsv introduced-packages.txt; do
        [[ -f $baseline/$metadata ]] || fail "baseline is missing or incomplete: $baseline/$metadata"
    done
    [[ -s $baseline/dpkg-selections.txt ]] || fail "malformed baseline: empty dpkg selections"
    awk 'NF != 2 || $2 !~ /^(install|hold|deinstall|purge)$/ {exit 1}' "$baseline/dpkg-selections.txt" || fail "malformed baseline: invalid dpkg selections"
    cmp -s -- "$MANIFEST_FILE" "$baseline/bundle-manifest.sha256" || fail "malformed baseline: bundle manifest mismatch"
    for metadata in installed-packages.tsv post-install-packages.tsv; do
        awk -F '\t' 'NF != 2 || $1 !~ /^[a-z0-9][a-z0-9+.-]*(:[a-z0-9]+)?$/ || $2 == "" || seen[$1]++ {exit 1}' "$baseline/$metadata" || fail "malformed baseline: $metadata"
        LC_ALL=C sort -cu "$baseline/$metadata" || fail "malformed baseline: unsorted $metadata"
    done
    awk 'NF != 1 || ($1 != "UNAVAILABLE" && $1 !~ /^[a-z0-9][a-z0-9+.-]*(:[a-z0-9]+)?$/) || seen[$1]++ {exit 1} $1 == "UNAVAILABLE" {u++} END {if (u && NR != 1) exit 1}' "$baseline/apt-mark-manual.txt" || fail "malformed baseline: apt-mark manual list"
    awk 'NF != 1 || $1 !~ /^[a-z0-9][a-z0-9+.-]*(:[a-z0-9]+)?$/ || seen[$1]++ {exit 1}' "$baseline/introduced-packages.txt" || fail "malformed baseline: introduced packages"
    ensure_tmp; cut -f1 "$baseline/installed-packages.tsv" >"$TMP_WORK/before.names"; cut -f1 "$baseline/post-install-packages.tsv" >"$TMP_WORK/after.names"
    LC_ALL=C comm -13 "$TMP_WORK/before.names" "$TMP_WORK/after.names" >"$TMP_WORK/expected-introduced"
    cmp -s -- "$TMP_WORK/expected-introduced" "$baseline/introduced-packages.txt" || fail "malformed baseline: introduced package diff"
    while IFS=$'\t' read -r name status version extra; do
        [[ -n $name && -n $status && -n $version && -z ${extra:-} ]] || fail "malformed baseline: invalid tuple row"
        known=0; is_bundled "$name" && known=1
        (( known )) || fail "malformed baseline: unknown package $name"
        [[ $seen != *"|$name|"* ]] || fail "malformed baseline: duplicate package $name"
        seen+="$name|"; rows=$((rows + 1))
        if [[ $status == absent && $version == ABSENT ]]; then :
        elif [[ $status =~ ^(not-installed|config-files|half-installed|unpacked|half-configured|triggers-awaited|triggers-pending|installed)$ && $version != ABSENT ]]; then existing_names+=("$name"); existing_versions+=("$version")
        else fail "malformed baseline: inconsistent state for $name"; fi
    done <"$baseline/tuple-state.tsv"
    (( rows == 7 )) || fail "malformed baseline: expected 7 tuple rows"
    for index in "${!existing_names[@]}"; do
        printf 'MANUAL: restore %s to exact version %s (prior status recorded)\n' "${existing_names[index]}" "${existing_versions[index]}"
    done
    while IFS= read -r name; do
        state=$(dpkg-query -W -f='${db:Status-Status}\n' "$name" 2>/dev/null || true)
        [[ $state != installed ]] || removals+=("$name")
    done <"$baseline/introduced-packages.txt"
    printf 'MANUAL: restore dpkg selections and apt-mark manual state from %s\n' "$baseline"
    if (( DRY_RUN )); then printf 'DRY-RUN: would remove %d introduced packages\n' "${#removals[@]}"; return 0; fi
    if ((${#removals[@]})); then sudo apt-get remove -y "${removals[@]}"; sudo dpkg --audit
    else printf 'PASS: no introduced packages to remove\n'; fi
}

load_manifest
case $ACTION in
    check) check_host; check_bundle || [[ $? == 2 ]] ;;
    install) check_host; install_bundle ;;
    verify) verify_system ;;
    prepare-gdm) check_host; prepare_gdm ;;
    rollback) rollback_baseline ;;
esac
