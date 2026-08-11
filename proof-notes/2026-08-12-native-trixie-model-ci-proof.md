# Native Trixie COSMIC model CI proof

Date: 2026-08-12

The personal Voulage branch
`rahul/native-trixie-cosmic-20260812` contains the native Trixie model entries
for `cosmic-session` and `cosmic-settings-daemon`. The branch also contains a
non-publishing validation workflow.

GitHub Actions run:

https://github.com/Rahul-2k4/voulage/actions/runs/31527974664

The successful run verified:

- the Trixie JSON model parses;
- offline model checks pass for both COSMIC packages;
- `cosmic-session` resolves to
  `a14abe378a513c6c5499b52b0d4d1afe50a41644`;
- `cosmic-settings-daemon` resolves to
  `7c02682178d18b286a0e66a92ca9eb87b0e960e7`;
- both source URLs and immutable 40-character refs match the expected model;
- both refs resolve remotely from their source repositories.

This proves Trixie model integrity and source-ref availability only. The
workflow does not build, sign, upload, or publish Debian packages. Native
Trixie `.deb` artifact production and release acceptance remain open.
