# Voulage displayd wrapper build proof - 2026-08-15

## Source and wrapper

- Voulage personal branch: [`rahul/voulage-displayd-lock-v4-wrapper-20260815`](https://github.com/Rahul-2k4/voulage/tree/rahul/voulage-displayd-lock-v4-wrapper-20260815)
- Wrapper commit: [`c47fe136`](https://github.com/Rahul-2k4/voulage/commit/c47fe13634a7d6743a5a8f27435747dddd519726)
- Displayd source branch: [`rahul/displayd-vendor-explicit-nightly-20260812`](https://github.com/Rahul-2k4/regolith-displayd/tree/rahul/displayd-vendor-explicit-nightly-20260812)
- Displayd source commit: [`b79a499`](https://github.com/Rahul-2k4/regolith-displayd/commit/b79a499383a74fc6f7ae7503b0eb062a601f6fca)

The wrapper detects Cargo.lock version 4 for `regolith-displayd`, selects the
installed nightly Cargo, passes its directory through `debuild
--prepend-path`, and supplies `-Znext-lockfile-bump` to the vendoring step.
Other packages keep the existing path.

## Build result

The real local Voulage wrapper completed both source and binary package phases.
Vendoring passed, Debian source packaging passed, and the binary package was
produced:

```text
regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb
SHA-256: 89c8b5edc0ebc6387d91b766af5e0680abd016b8ed8a30fe4936c1f31c63157e
```

The package metadata reports version `0.3.4-1-1regolith-resolute`, architecture
`amd64`, and the expected `regolith-displayd` dependencies. The generated
vendored source and Cargo configuration passed the same build; the exact
package hash above is the retained artifact used for the combined QEMU proof.

## Boundaries

This is a personal-fork, unsigned local Voulage build. The package was
installed in a disposable QEMU overlay and exercised in the combined runtime
proof. It was not uploaded to Regolith's archive. Canonical publication,
release signing, and mentor review remain open. See the [combined QEMU proof](2026-08-15-combined-displayd-package-qemu-proof.md).
