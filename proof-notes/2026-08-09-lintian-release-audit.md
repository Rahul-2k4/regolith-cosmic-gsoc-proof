# Lintian release audit - 2026-08-09

The exact current artifacts were checked separately as source and binary
packages. The main findings were:

- a builder-host changelog identity error on displayd and wm-config
- a real contradictory legacy recommendation in wm-config
- `no-manual-page` warnings on several installed binaries

Two packaging-only fixes are isolated and not merged upstream:

- Voulage branch `codex/voulage-release-audit-20260809` at `1e16b810`
- WM-config branch `codex/wm-config-release-audit-20260809` at `1122266a`

Post-fix artifacts have not yet been rebuilt, so lintian and release readiness
remain open. A bounded isolated rebuild of `regolith-wm-config` then
completed successfully at `4.11.11-1-1regolith-resolute` with SHA-256
`e6e54bab85a5ebf76581ac4dcb68c287feec938695a93b119d95e979019e5937`.

The two targeted errors disappeared, but broader existing lintian errors in
sibling packages remained. Displayd also rebuilt successfully at
`0.3.4-1-1regolith-trixie` with SHA-256
`5d8c43de1d3ca6aab8ba070f79cbd58e17caa6180050303295052c71fc242cb9`.
Its residual tags are `bad-distribution-in-changes-file`, two missing
manual-page warnings, and an empty dbgsym warning. Signing is not included in
this proof bundle.
