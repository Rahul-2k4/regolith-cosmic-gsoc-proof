# Clean Voulage rebuild - 2026-08-09

This note records the reproducibility result for the frozen Regolith COSMIC
package tuple. It is proof of clean checkout and local package generation, not
release publication or final proposal completion.

## Voulage checkout fix

The isolated builder branch
[`rahul/closure-voulage-pinned-ref-20260809`](https://github.com/Rahul-2k4/voulage/tree/rahul/closure-voulage-pinned-ref-20260809)
supports branch, tag, and full-commit-SHA inputs. Its checkout test passed.
The portability fix is commit `7436101f7ddeddd113f0931ff1ae5b92b53d7bda`.

## Clean-built artifacts

Each package was built from the exact source commit listed below with vendored
dependencies and a successful Voulage local build:

| Package | Source commit | Version | SHA-256 |
|---|---|---|---|
| `regolith-inputd` | `e32d0497f67fea94fb98f803c406c704191b741c` | `0.4.1-1-1regolith-resolute` | `2dddd1a1e7a7851d4be41569b764c663ad43f9ffeab7bb295ae3ceb20878e3e9` |
| `regolith-displayd` | `e8cc8e07e41e7b0b6dc2f1c9a7765876dfe0c46c` | `0.3.4-1-1regolith-resolute` | `5364ff08efc1bc0507534abe956eaecaaba086a94ac39049053c36f1c7cabf91` |
| `regolith-session-cosmic` | `fc03e97578e342cf5109b1cf0f41b406009f5bfd` | `1.2.0-1ubuntu1-1regolith-resolute` | `6c23d48be8cb5ca04bc87469ca75cc71ff4ac60e1e05e12ae4ebd89e623b730c` |
| `regolith-wm-config` | `10225c056ee3ae15ab5745aba5a86ba611801ed5` | `4.11.11-1-1regolith-resolute` | `5631df471d19308af9bf78c3cd7391070967e750cafba00d58248b9e54c9031f` |

## Builder boundary

Displayd's version-4 Cargo lockfile and dependency MSRV require the nightly
Cargo toolchain, matching nightly rustc, and Cargo's explicit
`-Znext-lockfile-bump` flag for vendoring/building. No source lockfile was
rewritten for this proof.

Lintian is not clean yet: the packages retain documented manual-page,
debug-symbol, metadata, and dependency findings. The artifacts are unsigned.
The next proof step is installation of these new hashes in disposable QEMU,
followed by the final session, GNOME coexistence, display, input, idle, OSD,
rollback, and failed-unit checks.
