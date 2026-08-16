# Signed closure reproduction-input audit

Date: 2026-08-16

The signed local-repository install documented in the August 15 proof remains
valid: a fresh Ubuntu 26.04 container installed `regolith-session-cosmic`
twice from a signed local repository without trust bypasses.

The current public packet does not replay that run by itself. It contains the
public signing metadata and selected package artifacts, but not the complete
package pool or a repository-generation script for the full closure. The
retained Linux bundles are smaller unsigned bundles, so they cannot be used to
claim a fresh full-closure install.

This note deliberately keeps the boundary clear:

- the August 15 install is historical, valid proof;
- the current packet does not provide a byte-for-byte replay of that run;
- no new full-closure or publication claim is made here;
- a fresh replay requires restoring or rebuilding the complete package pool.

This does not change criterion 10's status. It remains **Partial** because the
work is not published to Regolith's canonical archive or accepted for release.
