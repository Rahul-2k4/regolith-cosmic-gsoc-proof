# Final GNOME target ownership transition proof

Date: 2026-08-12

## Source and package

- Repository: [`regolith-session`](https://github.com/Rahul-2k4/regolith-session)
- Branch: [`rahul/gnome-target-transition-replaces-20260811`](https://github.com/Rahul-2k4/regolith-session/tree/rahul/gnome-target-transition-replaces-20260811)
- Final commit: [`831596f`](https://github.com/Rahul-2k4/regolith-session/commit/831596f8f054a6904b0846b6a899912c6c13d465)
- No upstream PR was opened.

The final package metadata keeps unversioned `Replaces:
regolith-session-common, regolith-session-sway` and removes the unnecessary
target-package `Breaks` relation. This models the same-version file-ownership
handoff without breaking the legacy packages that depend on the new target
package.

Verification passed:

- all nine repository tests;
- all nine shell syntax checks;
- `git diff --check`;
- manual `dpkg-buildpackage -b -us -uc`, exit `0`;
- Voulage Resolute build for `831596f`, exit `0`;
- Lintian exit `0`, warnings only.

The final Voulage-built target package was
`regolith-session-gnome-targets_1.2.0-1ubuntu1-1regolith-resolute_all.deb`,
SHA-256
`22333275ad59bb2674ba058af22d3f776802ef1b4f1f2d4b33ad30a19a990a76`.

## Disposable QEMU transition

The proof used a disposable qcow2 overlay from the existing qualification
image. The base image was not modified.

- `dpkg -i` completed with `INSTALL_RC=0`.
- The session package family configured successfully; the old overwrite error
  did not recur.
- Both target files were assigned by `dpkg-query -S` to
  `regolith-session-gnome-targets`.
- `dpkg --audit` was empty after installation and after cold reboot.
- Guest SSH returned after reboot on attempt `1`.
- `/usr/bin/regolith-inputd` had the same hash before and after reboot:
  `9c656284dfe10ea10c9bb82eb0ffd8a198209fbed01ce493e7f20f83fc6e334e`.
- Cleanup verified that QEMU, the overlay, HMP socket, staging directory, and
  log were removed.

## Boundary

This is package ownership and cold-reboot evidence, not a graphical-login
claim. The post-reboot environment was outside a graphical user session, and
the tuple included existing inputd/displayd/wm-config artifacts. Hardware
display behavior, native COSMIC settings, signing, canonical publication, and
mentor acceptance remain open.
