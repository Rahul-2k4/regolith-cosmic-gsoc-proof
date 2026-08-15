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
SHA-256: a790ef10df1f8f06f8f5953bb3a5da092d32b5ca62f92167298beee6ee6c6766
```

The package metadata reports version `0.3.4-1-1regolith-resolute`, architecture
`amd64`, and the expected `regolith-displayd` dependencies. The generated
vendored source and Cargo configuration were also retained and hashed:

```text
vendor.tar: 00814c07ec2d7ee88dc6ead9e167f2a95e14a5b5d8bb205b365250ec5df78685
.cargo/config: 77e9219c27274120197571fd165cbe4121963b5ad3bc0b20b383c86ef0ce6c2b
```

## Boundaries

This is a personal-fork, unsigned local Voulage build. The package was not
uploaded to Regolith's archive and was not installed in QEMU in this run.
Canonical publication, release signing, mentor review, and runtime validation
remain open.
