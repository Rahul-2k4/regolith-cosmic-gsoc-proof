# COSMIC package GNOME-dependency regression test - 2026-08-11

The personal-fork branch
[`rahul/regolith-session-package-audit-20260811`](https://github.com/Rahul-2k4/regolith-session/tree/rahul/regolith-session-package-audit-20260811)
is based on the current session source transition commit and adds the
test-only commit
[`a5db193`](https://github.com/Rahul-2k4/regolith-session/commit/a5db1934b3f603defc5706d3a8c0376b6d96352d).

The existing systemd/package test now parses the Debian control stanzas and:

- rejects direct `gnome-session-bin` and `gnome-settings-daemon` dependencies
  in `regolith-session-cosmic`;
- keeps those dependencies required in the legacy Sway path;
- keeps `gnome-session-bin` required in the Flashback path.

Verified on the worker branch:

- `bash -n tests/regolith-systemd-targets.sh`;
- `bash tests/regolith-systemd-targets.sh` -> `systemd target metadata: PASS`;
- `git diff --check`.

No production packaging file changed and no upstream PR was opened. This is a
source regression gate, not a complete transitive APT audit.
