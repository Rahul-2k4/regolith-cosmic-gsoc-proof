# `cosmic-session` parent-exit source and package proof

## Scope

This note records a small upstream `cosmic-session` candidate for the parent
session lifecycle boundary observed in the Regolith COSMIC QEMU proof. It is on
a personal branch and is not maintainer acceptance.

## Source

- Base: `a14abe378a513c6c5499b52b0d4d1afe50a41644`.
- Branch: [`rahul/cosmic-session-exit-cleanup-20260812`](https://github.com/Rahul-2k4/cosmic-session/tree/rahul/cosmic-session-exit-cleanup-20260812).
- Commit: [`fc9589d`](https://github.com/Rahul-2k4/cosmic-session/commit/fc9589d).
- Changed file: `src/comp.rs` only.

## Change

The compositor exit callback now notifies the session-side IPC loop. The loop
selects between IPC input and compositor exit, so it can terminate when the
compositor exits instead of waiting indefinitely on the IPC read. The focused
async test signals readiness from the polled IPC branch and checks for a clean
task result after the exit notification.

## Verification

On the Surface Linux host with Rust 1.93.0:

- `git diff --check`: passed.
- `cargo fmt --check`: passed; the repository's existing nightly-format option
  warnings were the only formatter output.
- `cargo test compositor_exit_terminates_session_loop`: passed.
- `cargo test`: passed; one unit test ran.
- `cargo build --release`: passed.
- `dpkg-buildpackage -us -uc -b -d`: passed.
- Built package: `cosmic-session_1.0.0_amd64.deb`.
- Package SHA-256:
  `54ecc4a1c8ded1213166d879d0e2fff7bccf74aa095b0591397e7b9ac9930ff4`.
- Lintian produced no findings for the binary package.

## QEMU runtime result

The exact package was installed in a copy-on-write overlay with the reviewed
Regolith session tuple. The guest rebooted, greetd started a real COSMIC/Sway
session, and the target-owned inputd/displayd services were active. After a
controlled `swaymsg exit`, the transport returned the expected IPC disconnect
while Sway shut down; the post-exit check reported `PARENT_EXIT_PASS`. Neither
`cosmic-session` nor `dbus-run-session` remained.

The overlay, staging directory, HMP socket, and QEMU process were removed. The
canonical qualification image remained unchanged.

## Remaining boundary

This closes the direct compositor-exit parent-process sub-gate for the tested
QEMU package tuple. It does not close complete display-manager logout and
shutdown behavior, native hardware, signing, publication, or mentor
acceptance. The proposal headline stays at `62-68%`, with `4/12` success
criteria fully met until the broader criteria are reviewed together.
