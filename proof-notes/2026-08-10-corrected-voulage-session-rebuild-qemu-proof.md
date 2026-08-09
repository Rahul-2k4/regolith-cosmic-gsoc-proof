# Corrected Voulage session rebuild and QEMU proof

Date: 2026-08-10

## Build

The disposable build used Voulage commit
`db0ff7bca46e10fb69a57cbd795bea23a73c1a82`, including the changelog identity
fallback, and session source ref
`3523047b7c2f7a2ca4e3d1fd800c10c342ca7a19`.

The focused source-pin test passed before the build. Voulage produced:

```text
regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb
SHA-256: 6e35ef61d639183efb407bdbf184257e1bcab50b1235b8d76e38db5f87a0c3c9
Package: regolith-session-cosmic
Version: 1.2.0-1ubuntu1-1regolith-resolute
Architecture: amd64
```

The package build ran `regolith-systemd-targets.sh` successfully. Lintian
reported one warning for the COSMIC launcher lacking a manual page. No signing
or canonical publication was performed.

## QEMU runtime

The exact package hash was checked after transfer to the disposable QEMU guest.
It was installed over the existing package and reached a visible COSMIC login.
The guest then reported the expected package version, empty `dpkg --audit`,
active `regolith-cosmic.target`, active inputd/displayd helpers, and running
`cosmic-session`, the Regolith COSMIC wrapper, Sway, inputd, and displayd.

The installed `/usr/lib/regolith/regolith-session-cosmic-runtime` hash during
the exact-package run was
`d5e6b50cb79b075b5694d76be86adc4a2ab8e770b42edb1c3cac108d489976a1`.

## Rollback

The retained baseline package was restored from the existing proof packet:

```text
SHA-256: ec71adc91778129feb9c31d23be7dd147d8b3d3713b0eb00d44b39316e8caea3
```

After rollback, the guest again reported the expected package version, empty
`dpkg --audit`, active COSMIC target, active inputd/displayd helpers, and the
same running session shape.

This proves the corrected Voulage build and an isolated QEMU install/login
path. It does not prove hardware, native `cosmic-comp`, signing, publication,
or final maintainer acceptance.
