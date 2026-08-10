# Build-dependency and license matrix

Provenance for the availability columns below. Queries ran inside Docker
images already present on the build host. Host apt was **not** used.

| Target column | Image | Captured guest identity |
|---|---|---|
| Debian Trixie | `debian:trixie` | `GUEST: Debian GNU/Linux 13 (trixie)` |
| Ubuntu 26.04 | `ubuntu:26.04` | `GUEST: Ubuntu 26.04 LTS` |

Method: `docker run --rm <image> sh -c 'apt-get update -qq; … apt-cache policy …'`
and read each package's `Candidate:` line. Capture date: 2026-08-10.

Build-Depends rows come from `debian/control` under the local `cosmic-epoch`
checkout on the build host (paths `cosmic-epoch/<component>/debian/control`).

## Limitation (read first)

Container `apt-cache policy` proves availability and version, not that a
full `debian/rules` / `dpkg-buildpackage` build succeeds on that distro. No
target-distro build or graphical session boot was performed for this matrix.

## Component Build-Depends

| Component | Build-Depends (from `debian/control`) | `debian/copyright` | Pinning notes |
|---|---|---|---|
| `cosmic-session` | `debhelper (>= 11)`, `debhelper-compat (= 11)`, `cargo`, `just` | yes | compat pinned to 11 |
| `cosmic-idle` | `debhelper (>= 11)`, `debhelper-compat (= 11)`, `cargo`, `just`, `libxkbcommon-dev`, `libwayland-dev`, `pkg-config` | **no** | compat pinned to 11 |
| `cosmic-bg` | `debhelper (>= 11)`, `debhelper-compat (= 11)`, `just`, `rust-all`, `libwayland-dev`, `libxkbcommon-dev`, `mold`, `nasm`, `pkgconf` | yes | uses `rust-all` / `pkgconf` rather than bare `cargo`/`pkg-config` |
| `cosmic-settings-daemon` | `debhelper (>= 11)`, `debhelper-compat (= 11)`, `cargo`, `libudev-dev`, `libinput-dev`, `libssl-dev`, `libxkbcommon-dev`, `pulseaudio-utils`, `pkg-config` | **no** | compat pinned to 11 |
| `cosmic-osd` | `debhelper (>= 11)`, `debhelper-compat (= 11)`, `cargo`, `cosmic-randr`, `just`, `libinput-dev`, `libudev-dev`, `libxkbcommon-dev`, `libwayland-dev`, `pkg-config` | yes | build-depends on packaged `cosmic-randr` |
| `cosmic-settings` | `debhelper-compat (=13)`, `cmake`, `fonts-open-sans`, `just`, `libclang-dev`, `libexpat1-dev`, `libfontconfig-dev`, `libfreetype-dev`, `libinput-dev`, `libpipewire-0.3-dev`, `libudev-dev`, `libwayland-dev`, `libxkbcommon-dev`, `mold`, `pkg-config`, `rust-all` | yes | compat pinned to 13; heaviest dep set |
| `cosmic-randr` | `cargo`, `debhelper-compat (=13)`, `just`, `libwayland-dev`, `pkgconf`, `rustc` | yes | compat pinned to 13 |

## Shared dependency availability (Docker candidates)

How verified: Docker guest `apt-cache policy` Candidate lines on the named
images (see provenance header). Values below are candidate versions only.

| Package | Debian Trixie candidate | Ubuntu 26.04 candidate |
|---|---|---|
| `libpulse-dev` | `17.0+dfsg1-2+b1` | `1:17.0+dfsg1-2ubuntu4` |
| `libudev-dev` | `257.13-1~deb13u1` | `259.5-0ubuntu3.4` |
| `libdisplay-info-dev` | `0.2.0-2` | `0.3.0-1` |
| `libinput-dev` | `1.28.1-1+deb13u1` | `1.31.1-1ubuntu1.1` |
| `libseat-dev` | `0.9.1-1` | `0.9.2-2` |
| `libxkbcommon-dev` | `1.7.0-2` | `1.13.1-1` |
| `wayland-protocols` | `1.44-1` | `1.47-1` |
| `just` | `1.40.0-1+b1` | `1.45.0-1` |
| `cargo` | `1.85.0+dfsg3-1` | `1.93.1ubuntu1` |
| `rustc` | `1.85.0+dfsg3-1` | `1.93.1ubuntu1` |
| `pkg-config` | `1.8.1-4` | `2.5.1-4` |
| `libwayland-dev` | `1.23.1-3` | `1.24.0-2` |
| `rust-all` | `1.85.0+dfsg3-1` | `1.93.1ubuntu1` |
| `mold` | `2.37.1+dfsg-1` | `2.40.4+dfsg-2.1ubuntu1` |
| `nasm` | `2.16.03-1` | `3.01-1` |
| `pkgconf` | `1.8.1-4` | `2.5.1-4` |
| `libssl-dev` | `3.5.6-1~deb13u2` | `3.5.5-1ubuntu3.3` |
| `pulseaudio-utils` | `17.0+dfsg1-2+b1` | `1:17.0+dfsg1-2ubuntu4` |
| `cmake` | `3.31.6-2` | `4.2.3-2ubuntu2` |
| `libclang-dev` | `1:19.0-63` | `1:21.1.6-71` |
| `libexpat1-dev` | `2.8.2-1~deb13u1` | `2.7.4-1` |
| `libfontconfig-dev` | `2.15.0-2.3` | `2.17.1-3ubuntu1` |
| `libfreetype-dev` | `2.13.3+dfsg-1+deb13u1` | `2.14.2+dfsg-1ubuntu0.1` |
| `libpipewire-0.3-dev` | `1.4.2-1` | `1.6.2-1ubuntu1.1` |
| `fonts-open-sans` | `1.11-2` | `1.11-2build1` |
| `debhelper` | `13.24.2` | `13.31ubuntu1` |

All listed packages had a non-`(none)` Candidate on both guests. Version
skew between Trixie and Ubuntu 26.04 is expected (notably Rust `1.85` vs
`1.93`, cmake `3.31` vs `4.2`). That skew alone does not prove or disprove a
successful package build.

## License / provenance column notes

| Has `debian/copyright` | Missing `debian/copyright` |
|---|---|
| `cosmic-session`, `cosmic-bg`, `cosmic-osd`, `cosmic-settings`, `cosmic-randr` | `cosmic-idle`, `cosmic-settings-daemon` |

Missing copyright files are a packaging-completeness gap for those two
components; they are not a claim about upstream license terms.

## What this matrix does not cover

- Runtime `Depends:` of the binary packages (only Build-Depends were gathered).
- The Regolith-side packages (`regolith-session`, `regolith-inputd`,
  `regolith-displayd`, `cosmolith`) — out of scope for this cosmic-epoch matrix.
- Building or booting a graphical session on Trixie or Ubuntu 26.04.
