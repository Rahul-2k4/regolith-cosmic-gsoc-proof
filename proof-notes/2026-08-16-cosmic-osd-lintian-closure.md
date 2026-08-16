# cosmic-osd metadata and Lintian closure

Date: 2026-08-16

## Result

The reviewed personal-fork branch
[`rahul/cosmic-osd-lintian-metadata`](https://github.com/Rahul-2k4/cosmic-osd/tree/rahul/cosmic-osd-lintian-metadata)
at commit
[`63afc394`](https://github.com/Rahul-2k4/cosmic-osd/commit/63afc3943f8641c7a9bbd147fd4b2a2b61c9b63f)
was rebuilt through the local unsigned Voulage Debian path for Ubuntu
Resolute.

The generated package is:

`cosmic-osd_0.1.0-1-1regolith-resolute_amd64.deb`

Package metadata reports:

- Package: `cosmic-osd`
- Version: `0.1.0-1-1regolith-resolute`
- Architecture: `amd64`
- SHA-256:
  `a5b827b387758731e010d076a7efd7e043289cc320d71601e533ea61ad228e2d`

The generated `debian/files` entries contain one Resolute suffix. A duplicate
suffix scan passed, and `lintian` exited `0` for the generated package.

## Scope and limits

This note proves the reviewed source metadata and unsigned local package build.
It does not claim signed publication, acceptance into the Regolith archive, or
a complete Ubuntu Resolute graphical-session test. No upstream repository was
modified by this build.
