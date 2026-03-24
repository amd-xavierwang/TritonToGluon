Git Agent Guide

- Goal: set up and manage the git environment on Linux systems, including installation, SSH configuration, identity, and key generation.
- Skills: `setup` (one-shot git + SSH environment setup).
- Notes:
  - All skills are idempotent — safe to re-run on an already-configured system.
  - SSH is configured to use port 443 (`ssh.github.com`) since port 22 may be blocked.
  - After key generation, remind the user to register the public key with GitHub.
