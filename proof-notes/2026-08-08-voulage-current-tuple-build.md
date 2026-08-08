# Current Voulage tuple build - 2026-08-08

The current source-of-truth model is `Rahul-2k4/voulage` branch
`rahul/voulage-model-repin-wm-config-resource-fallbacks-20260808` at:

```text
9794c18826d87981e783cdeabe392233b9218890
```

Project source refs:

```text
regolith-session  9c35074e5d0f7792326526b9df3d75aeb998599
regolith-wm-config 10225c056ee3ae15ab5745aba5a86ba611801ed5
regolith-inputd   e32d0497f67fea94fb98f803c406c704191b741c
regolith-displayd e8cc8e07e41e7b0b6dc2f1c9a7765876dfe0c46c
```

## Current package hashes

```text
regolith-session-cosmic_1.2.0-1ubuntu1-1regolith-resolute_amd64.deb
e1880fd9e76d5e129f8beff67e3ec68b6d231bc21a911764edcc8838dfbf7874

regolith-inputd_0.4.1-1-1regolith-resolute_amd64.deb
a3f3e65f2176843bb8d4f867f188f88223792bf265e78663c445468759fc7af9

regolith-displayd_0.3.4-1-1regolith-resolute_amd64.deb
4d332e13e9da4a1a986a94b730dd737e9d845d40d21b7c06db080a087c22123a

regolith-wm-config_4.11.11-1regolith-resolute_amd64.deb
10253e582056999b20cc94c67c6d76609f2d87f414d5bb07e48b4bb343f4219c

regolith-sway-root-config_4.11.11-1regolith-resolute_amd64.deb
32159c4e18eb03aaac3b98c50aa312e97fb7bdff78612103580154b0bc767ddc

regolith-sway-ilia_4.11.11-1regolith-resolute_amd64.deb
08deaf3af24649efbfc70a4e0401139285255d02c3c42a08297a5a2eb7cb1d4a

regolith-sway-cosmic-idle_4.11.11-1regolith-resolute_amd64.deb
5ec415da9a57afbd881bf0f0e60fdea8f0abb1d7fb441428d42579e9f48bf47e

regolith-sway-default-style_4.11.11-1regolith-resolute_amd64.deb
07c62a48d44f1f7b1cc7e4846c1fcd4158fa87c3769d9a73066b8ef898bcdd15
```

Displayd vendoring and its offline test matrix pass with the nightly Cargo
toolchain required by Cargo.lock v4. The artifacts are unsigned. Lintian
reports the builder-host changelog email and two `no-manual-page` warnings;
these are release-quality findings, not runtime claims.

The current-hash packages still require a fresh QEMU installation/runtime
matrix. This note does not claim native `cosmic-comp`, hardware, rollback, or
release signing.
