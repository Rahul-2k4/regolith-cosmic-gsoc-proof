# Voulage session repin and retained package build

Date: 2026-08-11
Status: model repin published; package build passed through the reviewed local-build exception

## Source-of-truth branch

- Voulage branch: [`rahul/voulage-audit-closure-20260812`](https://github.com/Rahul-2k4/voulage/tree/rahul/voulage-audit-closure-20260812)
- Final model commit: [`02d5d49`](https://github.com/Rahul-2k4/voulage/commit/02d5d49)
- `regolith-session` model ref: [`831596f`](https://github.com/Rahul-2k4/regolith-session/commit/831596f)
- `regolith-inputd` model ref: [`c658754`](https://github.com/Rahul-2k4/regolith-inputd/commit/c658754)

The 18 previously unpushed Voulage commits were published to the contributor
fork on this dedicated branch. The upstream `main` branch was left unchanged.

## Build paths

The canonical Voulage branch was invoked with the real `.github/scripts/local-build.sh`
path against `regolith-session` `831596f`. It reached source packaging but
stopped at the host `sudo apt build-dep` boundary because the non-interactive
host had no usable sudo credential. No package claim is based on that failed
attempt.

The reviewed Voulage fallback [`49f26e1`](https://github.com/Rahul-2k4/voulage/tree/rahul/local-build-skip-apt-build-dep)
was then used with the same source ref and the explicit local-build skip gate.
The build and package tests completed with `FALLBACK_LOCAL_BUILD_RC=0`.
Lintian emitted warnings only; no zero-warning claim is made.

## Retained package hashes

Version: `1.2.0-1ubuntu1-1-1regolith-resolute`

| Package | SHA-256 |
|---|---|
| `regolith-session-common` | `dfa3a8ac3e3bd859316831a88b9cc2b03fd3ace4e91af18e4cc7b88c1d2b0dd8` |
| `regolith-session-cosmic` | `be3516d17b6ac2aa11776a5cbb85bf66f7894532d06c639e053ae91ae20308a6` |
| `regolith-session-gnome-targets` | `cf7ed94712b84247c12de87a4de47ff4445073c917f5ab74a82ef3cc739dc478` |
| `regolith-session-sway` | `58c64f63ed83b8a7f467a8312614e59e9250e17cc70aaf49767ea10240213e56` |
| `regolith-session-flashback` | `a1ef11a68c37168ed9e887f76499aeff3c5b2472e8b07f2a65b8964cfc2f0671` |
| `regolith-session-flashback-ext` | `56fa37f6dd12662b4043a4688b39ca3bf51b01fb0b377bdc04d545678736844e` |

This note proves source checkout, Voulage build-path execution, package
creation, and hashes. It does not claim graphical login, hardware testing,
signing, or mentor acceptance.

The committed package files and independently recomputed hashes are listed in
the [public artifact manifest](../artifacts/README.md).
