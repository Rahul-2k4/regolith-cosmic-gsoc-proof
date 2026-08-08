#!/usr/bin/env bash
set -Eeuo pipefail

if (( $# != 1 )); then
    printf 'Usage: %s PACKAGE_DIRECTORY\n' "$0" >&2
    exit 2
fi

readonly package_dir=$1
readonly packages=(
    'regolith-session-cosmic_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb'
    'regolith-sway-root-config_4.11.11-1regolith-resolute_amd64.deb'
    'regolith-sway-ilia_4.11.11-1regolith-resolute_amd64.deb'
    'regolith-sway-default-style_4.11.11-1regolith-resolute_amd64.deb'
    'regolith-sway-cosmic-idle_4.11.11-1regolith-resolute_amd64.deb'
    'regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb'
    'regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb'
)
readonly hashes=(
    '332146a823b5041545284a5b99d995d402c9fb74437721eb513088d13ecba141'
    '1776e42639dd39cddd8a535e29fd5c7ba97285e97eec7f6130d381b871f45270'
    'cbbb5091138cb58263ffbdc830fe283500ff299ba05062753e00b5d7109d05db'
    '976c559d6c7fa00685ffe041dfe5fe96b23943e3c6541046c495718794e30775'
    '184e824af699560ecda025b33a626cf433b1e0337e6199000c92282d2dc953b2'
    '69a74a564b157b07ceb66701af0e4c7749c2717c9cc79ca09745b49d54d6e777'
    'c9c331faa889c32a160caed08386e70ef45c83273d8fe0c8e155b2185122c8a8'
)

[[ -d $package_dir ]] || { printf 'Package directory not found: %s\n' "$package_dir" >&2; exit 1; }
command -v sha256sum >/dev/null || { printf 'sha256sum is required\n' >&2; exit 1; }
command -v sudo >/dev/null || { printf 'sudo is required\n' >&2; exit 1; }

readonly expected_count=${#packages[@]}
actual_count=0
while IFS= read -r -d '' path; do
    actual_count=$((actual_count + 1))
    name=${path##*/}
    expected=false
    for package in "${packages[@]}"; do
        if [[ $name == "$package" ]]; then
            expected=true
            break
        fi
    done
    $expected || { printf 'Unexpected input: %s\n' "$name" >&2; exit 1; }
done < <(find -- "$package_dir" -mindepth 1 -maxdepth 1 -type f -print0)

(( actual_count == expected_count )) || {
    printf 'Expected exactly %d package files; found %d\n' "$expected_count" "$actual_count" >&2
    exit 1
}

for index in "${!packages[@]}"; do
    file=$package_dir/${packages[index]}
    [[ -f $file ]] || { printf 'Missing input: %s\n' "${packages[index]}" >&2; exit 1; }
    printf '%s  %s\n' "${hashes[index]}" "$file" | sha256sum --check --status --strict -
done

sudo dpkg -i -- "${packages[@]/#/$package_dir/}"
sudo dpkg --audit
