# Proof: Voulage mainline COSMIC package-model land (Task C4)

Date: 2026-08-11  
Host: surface-laptop `~/Desktop/GSoC_2026/ccextractor/regolith/voulage`  
Remote pushed: `rahul` → https://github.com/Rahul-2k4/voulage.git (personal fork only)  
Upstream `origin` (regolith-linux/voulage): **not pushed**

## Recorded deviation (AGENTS.md)

`AGENTS.md` Technical Strategy item 1: keep a separate COSMIC source-of-truth
branch; do not merge into `main` until release-ready.

This task **deliberately** merges onto `main` of the **personal fork only**
(`Rahul-2k4/voulage`), so a reviewer who clones that fork sees the frozen
COSMIC-related package-model pins instead of floating `master`/`main` refs.
This is not an unnoticed rule violation: upstream `regolith-linux/voulage`
`main` was left untouched.

## Before (main after `fetch` + `merge --ff-only origin/main`)

- `HEAD`: `96f24e322c13e802d39fa38f38cc28a49987dcfc`
- `stage/package-model.json`: **5 lines**, **0** case-insensitive `cosmic` hits (stub)
- `stage/unstable/package-model.json`: present on mainline already, but inputd was
  floating (`ref: master`, `regolith-linux/regolith-inputd`)

## Merge source (Task C2)

- Branch: `rahul/inputd-repin-reconciled-20260811`
- Tip: `245e400679af74e583575f5aad4076ae0d5e6f71`
- Confirmed in `stage/unstable/package-model.json`:
  `regolith-inputd.ref` = `e641b434c76c70e9a21e492adea577607e096d03`

## Merge

```text
git merge --no-ff rahul/inputd-repin-reconciled-20260811 \
  -m "chore(model): land COSMIC package model entries on mainline"
```

- Merge commit: `1bbaa39b0a9a0ef5604a3e72c20ee87afafe42cc`
- Strategy: `ort`, clean (no conflicts)
- Also brought supporting tests/scripts from the C2 branch history
  (`.github/scripts/test-ext-*.sh`, `tests/regolith-session-source-pin.sh`, etc.)

Model delta vs previous main (package pins):

| package | ref | source |
|---|---|---|
| regolith-displayd | `817becd9…` | Rahul-2k4/regolith-displayd |
| regolith-inputd | `e641b434c76c70e9a21e492adea577607e096d03` | Rahul-2k4/regolith-inputd |
| regolith-session | `3523047b…` | Rahul-2k4/regolith-session |
| regolith-wm-config | `10225c05…` | Rahul-2k4/regolith-wm-config |

Note: literal `grep -ci cosmic` on these model files is **0**. The COSMIC
session work is represented as immutable pins to the personal forks above, not
as package keys containing the substring `cosmic`. Distro overlays
`stage/unstable/debian/trixie/package-model.json` and
`stage/unstable/ubuntu/resolute/package-model.json` remain small overlay files
(GitHub API sizes 634 / 312); the pin source of truth is
`stage/unstable/package-model.json`.

## Push

```text
git push rahul main
# 96f24e32..1bbaa39b  main -> main
```

Local `main` remains ahead of `origin/main` (upstream) by design.

## `gh api` verification (fork, not local path)

```text
default_branch=main
sha_main=1bbaa39b0a9a0ef5604a3e72c20ee87afafe42cc
debian/trixie          634
ubuntu/resolute        312
unstable_model_size=7573
stub_stage_package_model_size=80
cosmic_count_unstable_model=0

regolith-inputd:
  ref: e641b434c76c70e9a21e492adea577607e096d03
  source: https://github.com/Rahul-2k4/regolith-inputd.git
```

## Blockers / caveats

- None for merge/push/SHA gate.
- Plan step that counts `cosmic` substrings will read **0**; assert on the
  reconciled inputd SHA (`e641b434…`) instead — that gate **passed**.
