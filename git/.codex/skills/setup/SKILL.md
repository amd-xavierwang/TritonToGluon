---
name: setup
description: Set up git, SSH config (port 443), global user identity, and generate an ed25519 SSH key on a Linux system.
metadata:
  short-description: One-shot Linux git + SSH environment setup
---

# Git Setup

Prepare a fresh Linux environment for git operations over SSH (port 443).

## Inputs
- None required. The script is self-contained and idempotent.

## Outputs
- git installed (if missing).
- `~/.ssh/config` entry for `github.com` using port 443.
- git global `user.name` and `user.email` configured.
- ed25519 SSH key generated at `~/.ssh/id_ed25519` (if no key exists).
- Public key printed to stdout so the user can add it to GitHub.

## Quick start
```bash
bash git/.codex/skills/setup/scripts/git-setup.sh
```

## Behavior
1. **Git installation** — checks for `git` on `$PATH`. If missing, installs via `apt-get` (Debian/Ubuntu) or `dnf`/`yum` (RHEL/Fedora).
2. **SSH directory** — locates or creates `~/.ssh` with mode 700.
3. **SSH config** — appends a `Host github.com` block that routes traffic through port 443 (`ssh.github.com`), but only if no such block already exists.
4. **Git identity** — sets `user.name` and `user.email` globally when they are not already configured.
5. **SSH key generation** — runs `ssh-keygen -t ed25519` with the configured email if `~/.ssh/id_ed25519` does not exist. Uses an empty passphrase and the default path.
6. **Print public key** — displays `~/.ssh/id_ed25519.pub` so the user can register it with GitHub.

All steps are idempotent — re-running the script on an already-configured system is a no-op.
