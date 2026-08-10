# Final closure verification sweep — 2026-08-11

**QEMU proof:** not re-run in this sweep. Prior QEMU notes remain the runtime
authority. This note records the Track E3 public-surface and test gates only.

## Public surface

| Check | Result |
|---|---|
| Default branch | `main` |
| Proof-note count (local pending packet) | **65** |
| `WORK_PRODUCT.md` | present |
| `docs/INSTALL.md` | present |
| `docs/KNOWN_LIMITATIONS.md` | present |
| `docs/BUILD_DEP_MATRIX.md` | present |
| `artifacts/README.md` | present |
| Parent public HEAD at sweep | `b8857d1` (cosmolith PR authorization update) |

## Artifact hashes

All three published `.deb` files match `artifacts/README.md`:

- `regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb` — OK
- `regolith-inputd_0.4.1-2-1regolith-resolute_amd64.deb` — OK (`759f87dc…`)
- `regolith-inputd_0.4.1-2-1regolith-resolute_reconciled-e641b43_amd64.deb` — OK (`37f678cf…`)

## Test gates (remote workspace)

| Tree | Commit | `cargo fmt --check` | Tests |
|---|---|---|---|
| `regolith-inputd` | `e641b43` | OK | 49 passed / 0 failed (`--all-features`) |
| `regolith-displayd` | `817becd` | OK | 48 + 25 passed / 0 failed |
| `cosmolith` | `f7543eb` | OK | 2 + 2 passed / 0 failed |
| `regolith-session` | `b12b837` | n/a | `tests/regolith-systemd-targets.sh` PASS |

## Link / figure / leak gates

- Relative `proof-notes|docs|artifacts` links: no dangling paths after README
  follow-up target pointed at the dedicated candidate-verifier note.
- Withdrawn percentage bands and unreachable head refs from Track B: none left as live claims in public markdown.
- Secret-pattern recheck: clean after renaming the vault filename citation that
  previously matched the remote-access keyword filter.

## Mentor / vault assembly

- Mentor message drafted, **not sent** — waiting for explicit go-ahead:
  vault `06_Mentor_Questions/2026-08-12-final-closure-message.md`
- Week 16 + proposal alignment updated in the vault by the E2 pass.

## Explicit non-claims

- No new hardware / full-laptop proof.
- No PRs were opened against the common Regolith session repositories. The
  mentor-approved COSMIC-specific cosmolith PRs #17, #18, and #19 are open and
  mergeable; they are not presented as merged.
- No signed Voulage publication.
