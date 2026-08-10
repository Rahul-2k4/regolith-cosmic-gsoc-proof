# inputd Voulage model repin (C2) — 2026-08-11

Track C Task C2: repin Voulage unstable model to the C1 reconciled inputd
source and rebuild the Resolute package on a retained build root.

## Pin

| Field | Value |
|---|---|
| Old ref | `e32d0497f67fea94fb98f803c406c704191b741c` |
| New ref | `e641b434c76c70e9a21e492adea577607e096d03` |
| Source | `https://github.com/Rahul-2k4/regolith-inputd.git` |
| Model file | `stage/unstable/package-model.json` (top-level only) |
| Voulage branch | `rahul/inputd-repin-reconciled-20260811` |
| Voulage commit | `245e400679af74e583575f5aad4076ae0d5e6f71` |
| Remote | `rahul` (`Rahul-2k4/voulage`) |

Inputd branch built: `rahul/inputd-touchpad-lintian-reconciled-20260811`
(tip matches the new pin SHA).

## Build

- Driver: copied `reproduce-voulage-branch-tuple.sh` (inputd-only).
- Builder: `rahul/local-build-skip-apt-build-dep` worktree `.github/scripts/local-build.sh`
  (current checkout rejects `--skip-apt-build-dep`; Mac script required that flag).
- `BUILD_ROOT`: `~/Desktop/GSoC_2026/ccextractor/regolith/proof-packets/2026-08-11/build`
  (seeded with `.github` so `ext-git.sh` resolves; not disposable `/tmp`).
- Log: `proof-packets/2026-08-11/inputd-repin-build.log`
- `BUILD_RC=0` (cleanup sudo noise after publish did not fail the build).

## Artifact

| Item | Value |
|---|---|
| Package | `regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb` |
| Laptop path | `.../build/regolith-inputd/pkgpublish/ubuntu/resolute/unstable/` |
| Mac path | `regolith-cosmic-gsoc-proof/artifacts/` |
| SHA-256 | `37f678cf76f371c08a23c971b1dd87a41f61f2c75cb27329e83b5239e7843a4e` |
| `strings … \| grep -c natural_scroll` | `6` (non-zero) |

QEMU proof not claimed here. This note covers model pin + package rebuild only.

## Script fixes required on copy

1. Dropped non-inputd `build_one` calls; pinned reconciled branch.
2. Pointed `VOULAGE_DIR` at skip-apt worktree so `--skip-apt-build-dep` is valid.
3. Seeded retained `BUILD_ROOT/$name` with `.github` — empty dir fails
   (`ext-git.sh` missing under `--git-repo-path`).
