#!/usr/bin/env bash

set -euo pipefail

SSH_DIR="$HOME/.ssh"

echo "🔍 Searching for SSH keys in: $SSH_DIR"
echo

if [ ! -d "$SSH_DIR" ]; then
  echo "❌ No ~/.ssh directory found."
  exit 1
fi

found=false

for key in "$SSH_DIR"/*; do
  # Skip public keys and non-files
  [ -f "$key" ] || continue
  [[ "$key" == *.pub ]] && continue

  pub_key="${key}.pub"

  if [ -f "$pub_key" ]; then
    found=true

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Private Key : $(basename "$key")"
    echo "Public Key  : $(basename "$pub_key")"

    if ssh-keygen -l -f "$pub_key" >/dev/null 2>&1; then
      echo "Fingerprint : $(ssh-keygen -l -f "$pub_key")"
    fi

    comment=$(awk '{print $NF}' "$pub_key" 2>/dev/null || true)

    if [ -n "$comment" ]; then
      echo "Comment     : $comment"
    fi

    echo
  fi
done

if [ "$found" = false ]; then
  echo "⚠️  No SSH key pairs found in ~/.ssh"
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Configured SSH identities in ssh-agent:"
echo

if ssh-add -l >/dev/null 2>&1; then
  ssh-add -l
else
  echo "No identities loaded in ssh-agent."
fi