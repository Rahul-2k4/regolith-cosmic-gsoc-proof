# Displayd packaging proof - 2026-08-09

The isolated displayd packaging branch is
`codex/mission-displayd-packaging-lintian-20260809` at source commit
`39c3746cfc7cf0da5c456163e7009b3c3c0a1fdf`. It adds the two manual pages,
normalizes Debian metadata, and adds a source-level packaging regression test.

The corresponding personal-fork Voulage model branch is
`codex/voulage-displayd-model-39c3746-20260809`. The follow-up source branch
`c99495e` also fixes the historical changelog version and disables automatic
dbgsym generation. The corrected unsigned package has version
`0.3.4-1-1regolith-resolute` and SHA-256
`f733551be828ea4ff73043f71ebbd4a955b3d6a06ae3071190e761623a6df512`.

The binary and `.changes` Lintian results are clean. A corrected nightly
library test reports 12 passed tests. The earlier package was installed in the
disposable QEMU guest with the same hash, both manual pages present, and empty
`dpkg --audit`.

Signing remains pending, so this is package/build proof, not release
publication proof. No upstream PR or `main` merge is claimed.
