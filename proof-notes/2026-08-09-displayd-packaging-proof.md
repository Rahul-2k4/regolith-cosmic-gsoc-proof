# Displayd packaging proof - 2026-08-09

The isolated displayd packaging branch is
`codex/mission-displayd-packaging-lintian-20260809` at source commit
`39c3746cfc7cf0da5c456163e7009b3c3c0a1fdf`. It adds the two manual pages,
normalizes Debian metadata, and adds a source-level packaging regression test.

The corresponding personal-fork Voulage model branch is
`codex/voulage-displayd-model-39c3746-20260809` at
`dc9bc6c8ec5ab90f590dafd983732e9dab8f06e7`. The unsigned package has version
`0.3.4-1-1regolith-resolute` and SHA-256
`f9dedba0a53e50c3f5122ac6cd95a4e0882ae71cd11e8e127bd69d11f5ebe245`.

The binary Lintian result is clean. A corrected nightly library test reports
12 passed tests. The package was installed in the disposable QEMU guest with
the same hash, both manual pages present, and empty `dpkg --audit`.

Signing remains pending. The source changes file retains two warnings, so this
is package/build proof, not release publication proof. No upstream PR or
`main` merge is claimed.
