# Keyboard `bindsym` injection boundary — 2026-08-11

## Purpose

Criterion 12 requires interactive evidence that an ordinary keyboard shortcut
reaches Sway and activates a `bindsym` in the COSMIC-backed Regolith session.
This note records the time-boxed QEMU attempt and its limit.

## Setup

- Disposable qualification QEMU guest.
- Disk snapshot created before the attempt: `pre-keyinject-20260811`.
- QEMU relaunched headless with an HMP monitor socket.
- Guest SSH became reachable, but no `cosmic-session` or `sway` process was
  present during the bounded wait.

## Attempt

The HMP command was:

```text
sendkey meta_l-ret
```

The before capture showed the guest greeter with the password field focused.
The after capture showed the same greeter with an “Incorrect password” message.
The framebuffer changed, but no Sway tree, spawned client, or `bindsym`
activation could be observed.

Screenshots:

- [Before injection](../artifacts/keyinject-20260811/before.png)
- [After injection](../artifacts/keyinject-20260811/after.png)

## Result

This is **not** criterion 12 proof. It demonstrates only that HMP key input
reached the greeter framebuffer. The VM was powered down through HMP after the
attempt. The criterion remains `Unproven`; no completion percentage changed.

Multimedia keys, physical keyboard behaviour, and the full tiling/workspace/
launcher matrix remain outside this attempt.
