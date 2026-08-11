# Voulage displayd candidate model - 2026-08-12

The tested `regolith-displayd` candidate was added to an isolated Voulage
branch for packaging review. It is not merged into the frozen model or
upstream `regolith-linux/voulage`.

- Branch: [`rahul/voulage-displayd-audit-closure-20260812`](https://github.com/Rahul-2k4/voulage/tree/rahul/voulage-displayd-audit-closure-20260812)
- Commit: [`0b79525`](https://github.com/Rahul-2k4/voulage/commit/0b79525e5656877c0c21e5b549d381f9ce0b0de9)
- Displayd source: [`8fa2832`](https://github.com/Rahul-2k4/regolith-displayd/commit/8fa28320eabc6462848edc08937bc2062f7df1dd)
- Changed files: `stage/unstable/package-model.json` and
  `tests/regolith-session-source-pin.sh`.

## Verification

- JSON syntax: passed;
- focused model test: passed;
- shell syntax: passed;
- `git diff --check`: passed;
- the real build reached the displayd checkout, then stopped when `debuild`
  required interactive `sudo` for build dependencies.

No package artifact, QEMU installation, or reboot result is claimed from this
branch. The build-generated `pkgbuild/` directory was left untracked and was
not committed.
