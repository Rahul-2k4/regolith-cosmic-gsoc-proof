# Inputd keyboard reverse-sync boundary

Date: 2026-08-11

The personal-fork branch
[`rahul/inputd-mouse-reverse-sync-20260811`](https://github.com/Rahul-2k4/regolith-inputd/tree/rahul/inputd-mouse-reverse-sync-20260811)
now ends at commit
[`94222ce`](https://github.com/Rahul-2k4/regolith-inputd/commit/94222ce).

The pinned `swayipc 3.0.1` `Input` model does not expose keyboard repeat
delay/rate fields. The implementation therefore keeps keyboard reverse-sync as
a safe no-op rather than guessing at undocumented fields or writing incomplete
COSMIC configuration. A typed adapter and focused tests record that boundary,
preserve the keyboard/input-source split, and leave the existing forward
layout/variant path unchanged.

Verification on the Linux build host:

- focused COSMIC keyboard tests: `8 passed, 0 failed`;
- all-feature suite: `58 passed, 0 failed`;
- `cargo fmt --check`: exit `0`;
- `git diff --check`: pass.

This is source and test evidence. It does not claim live keyboard reverse-sync,
physical keyboard behavior, or a change to the proposal completion headline.
The missing repeat fields are now an explicit API boundary for mentor review.
