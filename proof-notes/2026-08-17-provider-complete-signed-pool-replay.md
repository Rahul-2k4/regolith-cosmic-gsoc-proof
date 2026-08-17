# Provider-complete signed-pool replay

Date: 2026-08-17
Status: PASS for the disposable Ubuntu 26.04 package-install gate

## Active session package

The tested `cosmic-session` artifact was built through Voulage from the
direct no-`cosmic-workspaces` lineage:

- Source branch: `codex/cosmic-session-workspaces-description-20260817`
- Source commit: `69ada76a65d4dc487f5bae663941a58e9704023f`
- Voulage model commit: `5006cd1bfa8dabdb0763b95e1d9bae4877ae7f96`
- Package: `cosmic-session_1.0.0-1-1regolith-resolute_amd64.deb`
- SHA-256: `2cf46524cbc26e7095205aaedab82c79b31ffe6c6ceb5ff06201d88ea29d5e5e`

`cosmic-workspaces` is absent from the package `Depends` field and package
contents. Binary and source Lintian both returned `0`; warnings remain for
manual-page and source metadata hygiene.

## Disposable signed-pool replay

A disposable copy of the signed Resolute pool was rebuilt and re-signed. The
pool contained 45 indexed entries. It included the retained Voulage artifacts
needed to close the dependency graph, the archive portal-config package, and
Ubuntu Resolute packages for `swayidle`, `gtklock`, `wl-clipboard`, and
`xwayland`.

The replay ran in a fresh Ubuntu 26.04 container with normal recommends
enabled:

```text
APT_UPDATE_RC=0
APT_INSTALL_RC=0
INSTALL_REPLAY_RC=0
regolith-session-cosmic 1.2.0-1ubuntu1-1-1regolith-resolute install ok installed
dpkg --audit: empty
```

APT metadata was accepted without `NO_PUBKEY`, `BADSIG`, or `EXPKEYSIG`
errors. The repository index used relative `Filename: pool/...` entries so
the read-only container mount resolved package files correctly.

## Boundary

This proves the corrected package can be installed from a complete disposable
signed pool on Ubuntu 26.04. It does not prove publication to Regolith's
official archive, use of Regolith's signing identity, maintainer acceptance,
or a native hardware session.
