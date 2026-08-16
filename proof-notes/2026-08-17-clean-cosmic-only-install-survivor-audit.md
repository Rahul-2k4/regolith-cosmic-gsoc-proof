# Clean COSMIC-only install and survivor audit

Date: 2026-08-17

This proof uses a fresh disposable Ubuntu 26.04 container and the retained
local package pool. The transaction installed only regolith-session-cosmic;
the GNOME target package was not explicitly installed.

## Result

    apt-get install -y --no-install-recommends regolith-session-cosmic
    INSTALL_RC=0
    dpkg --audit -> DPKG_AUDIT_RC=0

The installed-package check found no:

- gnome-session-bin
- gnome-settings-daemon
- gnome-settings-daemon-common
- mutter
- nautilus

The regolith-session-cosmic and regolith-session-common package payloads also
contained no gnome, regolith-gnome, or regolith-wayland session paths.

## Remaining survivors

The transaction still installed these GNOME-related packages:

- gnome-keyring 50.0-1
- gnome-themes-extra 3.28-5
- gnome-themes-extra-data 3.28-5
- network-manager-gnome 1.36.0-4ubuntu1

They are recorded as survivors, not silently counted as removed. A complete
per-package justification and removal plan is still required before the
proposal's package-audit criterion can be marked fully met.

## Boundary

This closes the clean COSMIC-only dependency transaction and the absence check
for the GNOME session/bootstrap packages. It does not prove a graphical
Ubuntu Resolute login, archive publication, or hardware behavior. Criterion 9
remains Partial until the surviving packages are justified with removal plans.
