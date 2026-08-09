# Voulage Debian changelog identity fix

Date: 2026-08-10

The isolated Voulage branch
`rahul/voulage-changelog-identity-fallback-20260810-v2` at commit
`db0ff7bca46e10fb69a57cbd795bea23a73c1a82` updates
`.github/scripts/ext-debian.sh` so generated Debian changelogs use the package
Maintainer metadata, with a documented Regolith fallback when metadata is
incomplete, instead of inheriting the builder hostname. It adds
`.github/scripts/test-ext-debian.sh` for the unset-identity path.

Verification:

- focused mocked `dch` regression: passed
- `bash -n` on both scripts: passed
- `git diff --check`: passed on the committed change
- a direct rerun of the focused test: passed

This is a Voulage source/test improvement only. No package rebuild, signing,
canonical publication, or QEMU installation was performed for this commit.
The remaining release work therefore stays open.
