# Completion ceiling audit — what can still close locally vs. what's externally blocked

Date: 2026-08-20

## Why this exists

A `/goal` directive was set tonight: finish the whole proposal, as soon as
possible, before end of this week. This project hit the identical wall
once before (2026-08-16,
`kaal/shared/claude-memory/feedback_goal_hook_external_blockers.md`): a
"finish" condition can't be satisfied by more agent work once the
remainder depends on a mentor reply, a credential only the user holds,
physical hardware, or upstream maintainer action. Rather than loop
against that wall again, this note draws the line precisely: every
`Partial` requirement from `09_Final_Docs/2026-08-17-proposal-to-evidence-audit.md`,
categorized honestly.

## Per-requirement disposition

| # | Requirement | Locally actionable this week? | Why |
|---|---|---|---|
| 1 | `apt install regolith-session-cosmic` resolves on Trixie/Ubuntu 26.04 | **Partially done tonight** | Package-level closure proven live on real QEMU Ubuntu 26.04 Resolute (2026-08-18) — first time ever, stronger than this audit doc's 2026-08-17 snapshot. Remaining gap ("official archive publication or matching graphical Ubuntu guest") — the graphical guest half was reached 2026-08-19 (inputd fix); official archive publication is genuinely external (needs Regolith/Debian/Ubuntu maintainer infrastructure this project has no access to). |
| 2 | Zero GNOME session/bootstrap packages | **Locally actionable, in progress now** | Formal removal plan written tonight (`2026-08-20-gnome-survivor-removal-plan.md`); combined verification run dispatched to confirm the fix holds alongside the other two fixes from tonight. This can realistically reach `Met` this week. |
| 3 | Cold-login ordering gated by session identity | **Locally actionable, not started** | Needs a stronger clean-install-target replay. Bounded QEMU work, no external dependency. Real but unclaimed time cost. |
| 4 | Keyboard layout/variant reach Sway and persist | Already `Met` for tested QEMU scope per the 2026-08-17 audit | No further action needed for this scope. |
| 5 | Error types and session detection | **Partially external** | "Full upstream review/merge" needs a maintainer; "all failure paths" closure is bounded local work with no clear finish line defined anywhere — would need proposal-owner input on what "all" means before it's actionable. |
| 6 | Display validation matrix (resolution, multi-monitor, hotplug, mixed DPI, reboot persistence) | **Partially external — hardware-gated** | Single-output QEMU persistence already proven. Multi-monitor, hotplug, and mixed-DPI genuinely require physical hardware with multiple real displays — QEMU cannot honestly simulate hotplug/mixed-DPI in a way that counts as proof. This is the ceiling: **cannot close without real hardware**, which this session has no access to. |
| 7 | Lock path / possible `cosmic-idle` replacement | **Locally actionable, real feature work** | `swayidle`/`gtklock` fallback has proof. A native `cosmic-idle` replacement is real, unscoped feature work — needs its own scoping pass before it's clear how much of "this week" it would consume. |
| 6/7 (displayd wiring) | Routing `apply_monitors_config` to the real, verified apply-builder commit `c45ee725` | **Done tonight** | Hit a real architecture fork (calloop vs. hand-rolled bridge), escalated for a human decision, user chose `calloop`. Implemented via TDD, independently verified (91/91 tests pass in a fresh container, `cargo fmt --check` clean, not a regression vs. the unmodified base). PR opened: [Rahul-2k4/regolith-displayd#1](https://github.com/Rahul-2k4/regolith-displayd/pull/1). Unit-level only — no live QEMU/compositor verification yet; that would be the natural next step to move this further. See `05_Testing_Proof/2026-08-20-displayd-calloop-apply-wiring.md`. |
| 8 | COSMIC OSD hardened and verified | **Partially external** | Volume OSD has proof. "Multimedia-key injection" in QEMU is a real limitation of the test harness itself (QEMU has no clean way to inject real hardware media-key events that count as proof) — this specific sub-item is **QEMU-ceiling-blocked**, not just unstarted. |
| 9 | Session lifecycle: boot, logout, reboot, shutdown, no dangling units | **Partially external — real hardware, explicit project rule** | QEMU-scope boot/reboot/managed-logout already proven. "Full host shutdown" requires the actual laptop, and this project's own `CLAUDE.md` states real-hardware boot stays blocked until "a clean QEMU cold-login proof, a fallback session, and a rollback checklist" all exist — the first of those (clean QEMU cold-login) was arguably reached 2026-08-19. This is a real decision point for the user: attempting a real-hardware boot is not something to do autonomously without their explicit go-ahead given the risk (a broken real system, unlike a disposable QEMU overlay, isn't trivially resettable). |
| 10 | Voulage builds, vendoring, final packaging verification | **Externally blocked** | "Official archive publication, signing, and maintainer acceptance" needs Regolith's real signing infrastructure and key policy. No amount of local agent work closes this — it needs the mentor or upstream maintainers. |
| 11 | Documentation and upstream cleanup | **Externally blocked** | "COSMolith PRs remain open" — needs upstream review/merge from people who aren't this session. Documentation itself (proof notes, work-product) is already current and can be kept current, but "upstream cleanup" as stated cannot close without maintainer action. |

## The honest ceiling

**Requirements 10 and 11 cannot close this week, or any week, through more
agent work alone** — they need the mentor/upstream maintainers to act.
**Requirement 6's hardware sub-items (multi-monitor, hotplug, mixed DPI)
and requirement 9's "full host shutdown"** are gated on physical hardware
this session doesn't have standing access to attempt without explicit,
specific user authorization given the real (non-disposable) risk.
**Requirement 8's multimedia-key-injection sub-item is a genuine QEMU test
harness ceiling**, not a scoping or effort problem.

Everything else (requirements 1-3, 5's non-upstream parts, 7) has real,
bounded, locally-actionable headroom this week, and tonight's work already
moved 1 and 2 forward with live evidence, not documentation-only claims.

## What "finishing this week" honestly means, given this

The proposal as a whole cannot reach 12/12 `Met` through agent work alone
this week — three requirements have hard external gates (maintainer
signing, upstream merge, and either physical hardware or an explicit
user risk-acceptance decision). What CAN honestly happen this week:
maximize the locally-actionable items (2, and progress on 1, 3, 7) to
their real ceiling, keep the ledger honest throughout, and hand the user
a precise, final list of exactly what's left and who needs to act on each
externally-blocked item — mentor for signing/upstream, user for the
hardware-boot risk decision. That is the actual "finish" available here,
and it is what this session is working toward for the rest of tonight.
