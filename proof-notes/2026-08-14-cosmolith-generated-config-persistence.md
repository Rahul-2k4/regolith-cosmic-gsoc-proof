# Cosmolith generated-config.d persistence: source/unit proof, QEMU login blocked

Date: 2026-08-14

## What was implemented

The proposal committed cosmolith to persisting generated Sway input
configuration to
`~/.config/regolith3/sway/cosmic-settings/generated-config.d/`. This path was
previously unimplemented — a direct source grep for `generated-config`
returned zero hits before this work started. TDD was followed: the gap was
confirmed red first, then a keyed-write mechanism was added so repeated Sway
IPC directives cosmolith already sends are persisted to
`generated-config.d/input.conf`, so a cosmolith restart recovers last-known
state even before `cosmic-config` itself restarts.

4 new tests were added, confirmed red before the implementation and green
after. `cargo fmt --check` is clean on the change. The branch is
`rahul/generated-config-persistence-20260814` on the personal fork
(`Rahul-2k4/cosmolith`), based on `pkg/cosmolith-voulage-20260809` at
`70bb1bd`, tip `4134034c`. Pushed and independently verified with
`git ls-remote`.

## Keyboard layout/variant follow-up

The same proposal sentence also covers keyboard layout/variant persistence,
which feeds criterion 4. This was traced, not re-implemented: it already
flows through the same generic `generated-config.d` mechanism added above,
confirmed with 2 additional targeted tests. This is a verification of
existing behavior, not a new fix, and is not presented as one.

## QEMU boundary

A live QEMU proof was attempted: write a directive, restart, confirm
`swaymsg -t get_inputs` shows the setting re-applied. The known-good disk
image was confirmed to boot correctly under this session's tooling (HMP
screendump evidence, guest clock matching wall-clock), but the run could not
proceed past the login step — the guest account password is not stored
anywhere in this repository, by design, and was not bypassed or guessed.
Live QEMU proof for this feature remains open until either a password is
supplied for a live run or key-based guest authentication is set up.

## Boundary

This is source/unit-test evidence only. It does not change criterion 4's
`Not met as written` status — that criterion specifically names the
`cosmic-settings` GUI panel path, a different and still-broken code path
from cosmolith's own IPC-directive persistence — and it does not change
criterion 7's `Partial` status, since reboot-survival proof has not been run
for this mechanism. The strict headline and the 4-of-12 count are unchanged
by this entry.
