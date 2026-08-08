#!/usr/bin/env bash
set -Eeuo pipefail

if (( $# != 1 )); then
    printf 'Usage: %s PACKAGE_DIRECTORY\n' "$0" >&2
    exit 2
fi

readonly package_dir=$1
readonly packages=(
    'regolith-session-cosmic_1.2.0-1ubuntu1-1-1regolith-resolute_amd64.deb'
    'regolith-sway-root-config_4.11.11-1-1regolith-resolute_amd64.deb'
    'regolith-sway-ilia_4.11.11-1-1regolith-resolute_amd64.deb'
    'regolith-sway-default-style_4.11.11-1-1regolith-resolute_amd64.deb'
    'regolith-sway-cosmic-idle_4.11.11-1-1regolith-resolute_amd64.deb'
    'regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb'
    'regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb'
)
readonly hashes=(
    'bdd8dd763c28145b6439fda592b35813429a20b96af4ce6dd2e1bec9e5d2c095'
    'b6f79493deac28d50795b7e2e5f7b9804f5e4f786111890fb9aac602013a3e12'
    '4220b4edbbd69910563b758b4f9cc6e13613aa88efbf066e2189aa3e1348a433'
    '69cf8ef1a5c525ecab6665ce3180d455e3c420ca3b74a266bbfddf63b0b893a3'
    'a322a48b802f47a221588c542155469da3d348ae373e02c4c68547231d7494a5'
    '16506d0d0ade08ed566a7b04db093cfc508add9e626f1b735f5d190d744c8535'
    '0444483c883bff81cbfe16793ca32afbddd8442f9978fab32e7ed31c680668cd'
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
