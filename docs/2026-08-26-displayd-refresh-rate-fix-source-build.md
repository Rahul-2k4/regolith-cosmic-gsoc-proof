# displayd refresh-rate fix: source and package build

Date: 2026-08-26

The displayd COSMIC source branch now preserves an explicit refresh rate when
matching a saved mode. It also handles Wayland mode metadata regardless of
whether size or refresh arrives first. The change is on the personal fork at
[`codex/displayd-refresh-rate-fix-20260826`](https://github.com/Rahul-2k4/regolith-displayd/tree/codex/displayd-refresh-rate-fix-20260826),
commits `0df4443` and `8ea3f93`.

Verification on the Linux project host:

```text
CARGO_NET_OFFLINE=true cargo fmt --check             PASS
CARGO_NET_OFFLINE=true cargo test --locked --offline PASS (69 lib, 25 bin)
git diff --check                                      PASS
```

Voulage produced the unsigned Resolute package for the unstable stage:

```text
regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb
SHA-256: 2ecc5095e1e1b744ece24cad337f891dc7a5b3885273995594ca5a15b230d562
```

The Debian source archive includes `vendor.tar` in the Debian archive, so
the Rust build has an offline vendored input. Lintian still reports the
known missing-manpage and empty-debug-symbol warnings.

The QEMU runtime rerun is deliberately not claimed here: the VNC-backed
guest was launched after a rollback snapshot, but the validation host became
unreachable during boot before the monitor state could be collected. The
strict proposal ledger therefore remains 5/12, QEMU-only, and Criterion 7
remains `Partial` until the package is installed and the requested refresh
rate is verified after reboot.
