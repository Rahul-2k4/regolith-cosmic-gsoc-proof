# Voulage version-composition fix

Date: 2026-08-16

## Result

The Voulage Debian wrapper was updated on the personal fork branch
`codex/voulage-version-compose-20260816` at commit
`d8337251d38d6288d03dbb977bcdaf351cddf0a1`.

The change keeps the existing package revision and composes exactly one
`1regolith-<codename>` suffix. Regression tests cover already-suffixed
Resolute and Trixie versions, unsuffixed versions, and Debian revisions such
as `0ubuntu1`, `+b1`, and `~exp1`.

The corrected package was built through Voulage's local unsigned build path:

`cosmic-osd_0.1.0-1-1regolith-resolute_amd64.deb`

SHA-256:

`dc843a8da3a587b1302b3b0cba3f85e0a4d18bdefccc42576f2627be78bf3a9f`

`dpkg-deb` and `debian/files` both report exactly one Resolute suffix. The
previous double-suffix form was not reproduced in the corrected output.

## Limits

This is an unsigned personal-fork build. Lintian still reports package
metadata findings, and no package was published to the Regolith archive. No
upstream PR was opened. This note proves the source and local artifact fix,
not release readiness or Ubuntu Resolute runtime behavior.
