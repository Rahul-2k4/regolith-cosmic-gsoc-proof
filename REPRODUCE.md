# Reproduce the Regolith on COSMIC work

This is the short path to install, rebuild and check the final GSoC 2026
packages. Everything here is unsigned and not in any Regolith archive.

Targets: Pop!_OS 24.04 (COSMIC), or Ubuntu 26.04 Resolute with Regolith
sources. COSMIC and Regolith apt sources must already work, and
`cosmic-comp` must be installed. See [docs/INSTALL.md](docs/INSTALL.md).

## Repos

| Repo | Branch | Commit | What it changes |
|---|---|---|---|
| regolith-inputd | `rahul/xkb-pair-packaging-20261017` | `1c986c8` | COSMIC input backend, keyboard layout and variant set as a pair (`+xkbpair1`) |
| cosmolith | `rahul/regolith-bindings-win-20261017` | `7328e3b` | Regolith key bindings win over 66 colliding COSMIC shortcuts (`+bindwin1`) |
| cosmic-settings-daemon | `rahul/osd-varlink-align-20261017` | `691b357` | Upstream `e7936f0` plus packaging (`+varlink1`) |
| voulage | `rahul/cosmic-model-pins-20261017` | `4d193dc` | Pins every package by commit SHA |

All branches are on the `Rahul-2k4` forks. The other pinned parts (for
example regolith-session, regolith-displayd, cosmic-settings, cosmic-osd,
cosmic-session) are listed in
`stage/unstable/ubuntu/resolute/package-model.json` on the voulage branch.

## Option A: install the prebuilt packages

Release `gsoc-final-2026-10-17` on `Rahul-2k4/regolith-cosmic-gsoc-proof`.

```sh
curl -fLO https://github.com/Rahul-2k4/regolith-cosmic-gsoc-proof/releases/download/gsoc-final-2026-10-17/regolith-cosmic-install-kit-20261017.tar.gz
tar xf regolith-cosmic-install-kit-20261017.tar.gz
cd regolith-cosmic-install-kit
sha256sum -c SHA256SUMS
sudo ./install.sh
```

The kit holds the three debs, `install.sh`, `rollback.sh`, `rollback/` and its
own `SHA256SUMS`. The single debs, vendor tars, video and a top-level
`SHA256SUMS` are also separate release assets.

Log out and pick the Regolith COSMIC session at the greeter.

Roll back from the same folder with `sudo ./rollback.sh`. It reinstalls the
older packages from `rollback/` with `dpkg -i`. `install.sh` also checks
`SHA256SUMS` first. Neither
restarts user services, so log out and in again after either one.

## Option B: rebuild one package from source

Needs Rust 1.93 and the usual Debian build tools. Add `-d` to
`dpkg-buildpackage` if the build dependencies come from rustup, not apt.

```sh
BASE=https://github.com/Rahul-2k4/regolith-cosmic-gsoc-proof/releases/download/gsoc-final-2026-10-17

# regolith-inputd
git clone https://github.com/Rahul-2k4/regolith-inputd && cd regolith-inputd
git checkout 1c986c8
curl -fLo vendor.tar "$BASE/regolith-inputd-vendor.tar"   # gitignored; holds .cargo/config.toml too
dpkg-buildpackage -us -uc -b -d
```

The build runs `make VOULAGE=1 CARGO_FEATURES=cosmic`. To regenerate the
tar: `cargo vendor vendor && tar -cf vendor.tar vendor`.

The other two work the same way: clone, check out `7328e3b` (cosmolith) or
`691b357` (cosmic-settings-daemon), put the matching `*-vendor.tar` in the
source root as `vendor.tar`, and run `dpkg-buildpackage -us -uc -b -d`.
The daemon's packaging builds offline from `vendor.tar`; its upstream
`make vendor` target is what creates one. These two tars hold only
`vendor/`, so the cargo source-replacement config still has to come from
`make vendor` (daemon) or `cargo vendor --locked --versioned-dirs`
(cosmolith), which needs the network once. I have not tested a fully
offline build of those two.

Install the result from the parent folder with
`sudo apt-get install ./<package>.deb`.

## Option C: full Voulage build from the pins branch

```sh
git clone https://github.com/Rahul-2k4/voulage && cd voulage
git checkout 4d193dc
.github/scripts/main.sh check --distro ubuntu --codename resolute --stage unstable
```

`check` passes for `ubuntu/resolute` and `debian/trixie`. To build a
package, use `.github/scripts/local-build.sh` as shown in
[docs/INSTALL.md](docs/INSTALL.md). Build one package per build root.

## Check it works

Run these inside the Regolith COSMIC session, the same commands as the
[demo video](artifacts/demo-thumb.png).

```sh
echo $XDG_CURRENT_DESKTOP      # Regolith-Wayland:COSMIC:sway
pgrep -a cosmic-session        # one running cosmic-session
pgrep -a gnome-session         # prints nothing
pgrep -af 'regolith-inputd|regolith-displayd|cosmolith|cosmic-settings-daemon'
dpkg-query -W regolith-inputd cosmolith cosmic-settings-daemon
```

Expected versions end in `+xkbpair1`, `+bindwin1` and `+varlink1`.

## Limits

- Criterion 3 (multi-display, hotplug, mixed DPI) needs hardware I do not
  have. Criterion 7 is partial: scale persists, but refresh rate cannot be
  tested on a panel that only offers 59.999 Hz.
- The packages are unsigned. Signing and archive publication (criterion 10)
  need a maintainer decision.
- Proof for criteria 4, 6, 8 and 12 comes from the physical Pop!_OS laptop
  with the packages installed. Criteria 1, 2, 5, 9 and 11 are mostly QEMU
  proof, also seen on the laptop session. There was no fresh login after
  the final install, apart from a check that the settings daemon autostarted.
