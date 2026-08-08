#!/usr/bin/env bash
set -eu

: "${VOULAGE_DIR:?Set VOULAGE_DIR to a Voulage checkout}"
: "${BUILD_ROOT:?Set BUILD_ROOT to an empty parent directory}"

EXTENSION="$VOULAGE_DIR/.github/scripts/ext-debian.sh"
BUILDER="$VOULAGE_DIR/.github/scripts/local-build.sh"
mkdir -p "$BUILD_ROOT"

build_one() {
    name="$1"
    url="$2"
    ref="$3"
    root="$BUILD_ROOT/$name"
    rm -rf "$root"
    mkdir -p "$root"
    VOULAGE_SKIP_APT_BUILD_DEP=true "$BUILDER" \
        --extension "$EXTENSION" \
        --git-repo-path "$root" \
        --package-name "$name" \
        --package-url "$url" \
        --package-ref "$ref" \
        --distro ubuntu --codename resolute --stage unstable \
        --skip-apt-build-dep
}

build_one regolith-session \
    https://github.com/Rahul-2k4/regolith-session.git \
    rahul/cosmic-idle-owner-canonical-20260808
build_one regolith-wm-config \
    https://github.com/Rahul-2k4/regolith-wm-config.git \
    rahul/cosmic-idle-owner-wm-config-20260808
build_one regolith-inputd \
    https://github.com/Rahul-2k4/regolith-inputd.git \
    rahul/inputd-handler-startup-retry-fixed-20260802
build_one regolith-displayd \
    https://github.com/Rahul-2k4/regolith-displayd.git \
    rahul/cosmic-systemd-displayd-metadata
