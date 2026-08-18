# Mentor Real-System Installer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the mentor one safe script that installs and verifies the exact unsigned Regolith COSMIC test tuple on a real booted system.

**Architecture:** A Bash installer downloads or accepts seven SHA-256-pinned Debian packages, validates host and package metadata, records a pre-install baseline, installs through APT, and exposes separate verification and scoped rollback commands. The script never changes the default session, reboots, stops the display manager, or stores credentials.

**Tech Stack:** Bash, Debian package tools, APT, systemd user units, mocked shell contract tests.

---

### Task 1: Installer Contract

**Files:**
- Create: `artifacts/mentor-test-2026-08-18.sha256`
- Create: `tests/install-real-system-contract.sh`
- Create: `scripts/install-real-system.sh`

- [ ] Freeze one canonical seven-line manifest containing every package filename and SHA-256; make tests reject count or identity drift.
- [ ] Write tests for unsupported hosts, bad hashes, wrong package name/version/architecture, default GitHub URLs, dry-run safety, exact APT invocation, runtime verification, and rollback scope.
- [ ] Run the contract test and record RED while the installer is absent.
- [ ] Implement the smallest installer satisfying the contract.
- [ ] Capture one baseline row per tuple package with prior status and version or `ABSENT`, plus dpkg selections and the bundle manifest.
- [ ] Make rollback reject missing/malformed baselines, remove only packages recorded `ABSENT`, and report pre-existing packages for manual exact-version restoration.
- [ ] Run `bash -n` on both files, the contract test, and `git diff --check`.
- [ ] Commit the green implementation.

### Task 2: Public Handoff

**Files:**
- Modify: `docs/INSTALL.md`
- Create: `proof-notes/2026-08-18-mentor-real-system-installer.md`
- Modify: `README.md` only if a direct quick-start link is needed.

- [ ] Document one install command, verify command, rollback boundary, supported hosts, and unsigned status.
- [ ] Keep the mentor test list at five items or fewer.
- [ ] State that the package tuple is QEMU-proven and real-hardware validation remains pending mentor execution.
- [ ] Run link, syntax, and diff checks; commit.

### Task 3: Review And Release

- [ ] Run spec-compliance review and fix every missing or extra behavior.
- [ ] Run code-quality/security review and fix all critical or important findings.
- [ ] Re-run tests independently.
- [ ] Push the branch and publish the seven hash-matched packages as an unsigned GitHub prerelease.
- [ ] Verify all release assets against the checked-in manifest and test the install script's default URLs from GitHub.
- [ ] Update vault tracking and prepare the humanized mentor message.
