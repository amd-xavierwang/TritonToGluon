#!/usr/bin/env bash
set -euo pipefail

# ── 1. Install git if missing ───────────────────────────────────────────────
if command -v git >/dev/null 2>&1; then
  echo "[git-setup] git is already installed: $(git --version)"
else
  echo "[git-setup] git not found — installing..."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq && sudo apt-get install -y -qq git
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y git
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y git
  else
    echo "[git-setup] Error: no supported package manager found (apt-get, dnf, yum)." >&2
    exit 1
  fi
  echo "[git-setup] git installed: $(git --version)"
fi

# ── 2. Ensure ~/.ssh exists ─────────────────────────────────────────────────
SSH_DIR="$HOME/.ssh"
if [[ -d "$SSH_DIR" ]]; then
  echo "[git-setup] SSH directory found: $SSH_DIR"
else
  mkdir -p "$SSH_DIR"
  chmod 700 "$SSH_DIR"
  echo "[git-setup] Created SSH directory: $SSH_DIR"
fi

# ── 3. Configure SSH to use port 443 for GitHub ─────────────────────────────
SSH_CONFIG="$SSH_DIR/config"
if [[ -f "$SSH_CONFIG" ]] && grep -q "^Host github.com" "$SSH_CONFIG"; then
  echo "[git-setup] SSH config for github.com already exists — skipping."
else
  {
    # Add a blank line separator if the file already has content.
    [[ -s "$SSH_CONFIG" ]] && echo ""
    cat <<'EOF'
Host github.com
  Hostname ssh.github.com
  Port 443
  User git
EOF
  } >> "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
  echo "[git-setup] Added github.com SSH config (port 443) to $SSH_CONFIG"
fi

# ── 4. Set git global identity if not already configured ─────────────────────
GIT_NAME="xavier wang"
GIT_EMAIL="xavier.wang@amd.com"

CURRENT_NAME="$(git config --global user.name 2>/dev/null || true)"
if [[ -z "$CURRENT_NAME" ]]; then
  git config --global user.name "$GIT_NAME"
  echo "[git-setup] Set git user.name = $GIT_NAME"
else
  echo "[git-setup] git user.name already set: $CURRENT_NAME"
fi

CURRENT_EMAIL="$(git config --global user.email 2>/dev/null || true)"
if [[ -z "$CURRENT_EMAIL" ]]; then
  git config --global user.email "$GIT_EMAIL"
  echo "[git-setup] Set git user.email = $GIT_EMAIL"
else
  echo "[git-setup] git user.email already set: $CURRENT_EMAIL"
fi

# ── 5. Generate SSH key if none exists ───────────────────────────────────────
KEY_PATH="$SSH_DIR/id_ed25519"
if [[ -f "$KEY_PATH" ]]; then
  echo "[git-setup] SSH key already exists: $KEY_PATH — skipping generation."
else
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$KEY_PATH" -N ""
  echo "[git-setup] Generated SSH key: $KEY_PATH"
fi

# ── 6. Print public key ─────────────────────────────────────────────────────
echo ""
echo "======== Public key (add this to GitHub) ========"
cat "${KEY_PATH}.pub"
echo "================================================="
