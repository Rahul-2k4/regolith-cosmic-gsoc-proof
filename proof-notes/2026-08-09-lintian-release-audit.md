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
remain open. Signing is also not included in this proof bundle.
