# Inputd reverse-sync tests - 2026-08-09

The personal-fork branch
`rahul/inputd-empty-source-fallback-20260808` contains test-only commits
`07cbc315` and `c8fc1049`.

Coverage includes:

- settings-to-Sway guard restoration
- Sway-to-settings guard restoration
- `apply_all_sync` enabled path
- `apply_all_sync` disabled path

Verification passed for the branch:

- default tests: 22 passed on the first full run
- all-feature tests: 46 passed on the first full run
- COSMIC-feature tests: 46 passed on the first full run
- GNOME-feature tests: 22 passed on the first full run
- focused follow-up and full command rerun passed
- `cargo fmt --check`, `cargo check --all-features`, and `git diff --check`
  passed

These are source-level tests. The installed package remains pinned to the
earlier binary source commit because the follow-up changes tests only.
