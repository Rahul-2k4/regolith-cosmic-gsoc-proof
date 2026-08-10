# 2026-08-11 Branch durability sweep (Task A2)

## Scope

GSoC closure plan Task A2 on `surface-laptop` workspace
`~/Desktop/GSoC_2026/ccextractor/regolith`.

Repos: voulage, regolith-session, cosmolith, cosmic-idle,
regolith-inputd, regolith-displayd, regolith-wm-config.

Rules: no force push; priority set only (gone → checkout → ahead →
voulage/session `rahul/*`); defer other `codex/*`; cosmolith push to
`fork` (Rahul-2k4), not upstream sandptel.

## Before (enum)

| Repo | NO-UPSTREAM | UNSYNCED | gone | ahead |
|------|------------:|---------:|-----:|------:|
| voulage | 40 | 5 | 0 | 4 |
| regolith-session | 17 | 1 | 0 | 1 |
| cosmolith | 3 | 2 | 0 | 1 |
| cosmic-idle | 0 | 1 | 0 | 1 |
| regolith-inputd | 14 | 1 | 1 | 0 |
| regolith-displayd | 9 | 0 | 0 | 0 |
| regolith-wm-config | 3 | 0 | 0 | 0 |

Notable: inputd `rahul/inputd-event-hardening-reviewed-validation [gone]`;
cosmic-idle only had `origin` → pop-os (no writable fork yet).

## Actions

1. Forked `Rahul-2k4/cosmic-idle` and added remote `rahul`.
2. Pushed priority set to `rahul` (Regolith repos + cosmic-idle) and
   `fork` (cosmolith). 45 attempts, 0 failures, 0 force, 0 NFF renames.
3. Cosmolith `fix/startup-xkb-events-atomic`: local behind fork by 3
   after fetch — no push (not strictly ahead; not diverged with local-only
   commits).
4. Re-enumerated.

## After (enum)

| Repo | NO-UPSTREAM | UNSYNCED | gone | ahead |
|------|------------:|---------:|-----:|------:|
| voulage | 21 | 1 (main behind 2) | 0 | 0 |
| regolith-session | 3 | 0 | 0 | 0 |
| cosmolith | 3 | 2 (checkout+main behind) | 0 | 0 |
| cosmic-idle | 0 | 0 | 0 | 0 |
| regolith-inputd | 13 | 0 | 0 | 0 |
| regolith-displayd | 8 | 0 | 0 | 0 |
| regolith-wm-config | 3 | 0 | 0 | 0 |

All checked-out priority branches now have upstream except cosmolith
checkout, which remains `[behind 3]` on purpose.

## Deferred

- Remaining `codex/*` experiment branches (not checkout/gone/ahead).
- inputd/displayd/wm-config `rahul/*` (outside P4 voulage/session rule).
- Misc non-priority locals (`feature/`, `qualification/`, `sandeep-*`,
  `backup/`, `followup/`, `fix/rust-toolchain-*`, etc.).

## Proof claims (safe)

- QEMU/hardware: none (git durability only).
- Durability: priority work branches mirrored on Rahul-2k4 forks;
  `[gone]` cleared; no force used.
