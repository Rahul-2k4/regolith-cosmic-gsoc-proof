# Real disposable Trixie install - 2026-08-09

The exact package tuple installed successfully in a disposable Debian Trixie
container:

```text
cosmic-comp 0.1-1-1regolith-trixie
regolith-session-cosmic 1.2.0-1ubuntu1-1regolith-trixie
regolith-wm-config 4.11.11-1regolith-trixie
regolith-inputd 0.4.1-1-1regolith-trixie
regolith-displayd 0.3.4-1-1regolith-trixie
```

Results:

- `APT_INSTALL_RC=0`
- `CONTAINER_RC=0`
- `DPKG_AUDIT_EMPTY=1`
- `cosmic-comp` links `libdisplay-info.so.2`

This proves package installation in disposable Trixie userspace. It does not
prove native graphical login, hardware behavior, signing, lintian cleanliness,
or repository publication.
