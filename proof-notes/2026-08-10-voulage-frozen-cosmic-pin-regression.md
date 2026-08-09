# Voulage frozen COSMIC source-pin regression

Commit: `abbf6562dd670637d9c7fa70284befc5dba01fd6`
Branch: `codex/voulage-cosmic-pin-regression-20260810`

The Voulage regression test now checks the source URL and immutable 40-character
commit ref for each frozen COSMIC package source: `regolith-session`,
`regolith-inputd`, and `regolith-displayd`.

Verification on the branch:

```text
bash -n tests/regolith-session-source-pin.sh       PASS
bash tests/regolith-session-source-pin.sh         PASS
bash .github/scripts/test-ext-git.sh              PASS
git diff --check                                  PASS
```

This protects the reproducibility boundary for the frozen model. It does not
claim a package build, signing, publication, target-distro boot, or upstream
merge.
