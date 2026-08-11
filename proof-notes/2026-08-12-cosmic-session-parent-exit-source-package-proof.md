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

## Boundary

This is source, test, release-build, and package-build evidence. The package
has not yet been installed into a fresh QEMU overlay, so the direct
`swaymsg exit` parent-process check remains open. The proposal headline stays
at `62-68%`, with `4/12` success criteria fully met.

## Next step

Install this exact package in a disposable QEMU overlay, perform a fresh
greetd-managed COSMIC login, issue a controlled Sway exit, and check that both
`cosmic-session` and its `dbus-run-session` parent have exited. Remove the
overlay after the test and preserve the qualification base image.
