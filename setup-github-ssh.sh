#!/usr/bin/env bash

set -euo pipefail

echo "====================================="
echo "      GitHub SSH Key Setup"
echo "====================================="
echo

# Email validation
while true; do
    read -rp "Enter GitHub email: " EMAIL

    if [[ -z "$EMAIL" ]]; then
        echo "❌ Email cannot be empty."
        continue
    fi

    if [[ "$EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        break
    fi

    echo "❌ Invalid email format."
done

echo

# Key name validation
while true; do
    read -rp "Enter SSH key name (e.g. github-personal): " KEY_NAME

    if [[ -z "$KEY_NAME" ]]; then
        echo "❌ Key name cannot be empty."
        continue
    fi

    if [[ "$KEY_NAME" =~ [[:space:]] ]]; then
        echo "❌ Key name cannot contain spaces."
        continue
    fi

    SSH_KEY_PATH="$HOME/.ssh/$KEY_NAME"

    if [[ -f "$SSH_KEY_PATH" || -f "$SSH_KEY_PATH.pub" ]]; then
        echo "❌ SSH key '$KEY_NAME' already exists."
        echo "Please choose a different key name."
        continue
    fi

    break
done

echo
echo "Email      : $EMAIL"
echo "Key Name   : $KEY_NAME"
echo "Key Path   : $SSH_KEY_PATH"
echo

read -rp "Continue? (y/n): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

echo
echo "🔑 Generating SSH key..."

ssh-keygen \
    -t ed25519 \
    -C "$EMAIL" \
    -f "$SSH_KEY_PATH" \
    -N ""

echo "✅ SSH key generated"

echo
echo "🚀 Starting SSH agent..."

eval "$(ssh-agent -s)" >/dev/null

if [[ "$OSTYPE" == "darwin"* ]]; then
    ssh-add --apple-use-keychain "$SSH_KEY_PATH"
else
    ssh-add "$SSH_KEY_PATH"
fi

echo "✅ SSH key added to agent"

echo
echo "📝 Configuring SSH client..."

SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    {
        echo
        echo "Host github.com"
        echo "  HostName github.com"
        echo "  User git"
        echo "  AddKeysToAgent yes"
        echo "  UseKeychain yes"
        echo "  IdentityFile ~/.ssh/$KEY_NAME"
    } >> "$SSH_CONFIG"
    echo "✅ SSH config updated for github.com"
else
    echo "ℹ️  github.com config already exists in SSH config"
fi

echo
echo "📋 Copying public key to clipboard..."

PUBLIC_KEY=$(cat "$SSH_KEY_PATH.pub")

if command -v pbcopy >/dev/null 2>&1; then
    echo "$PUBLIC_KEY" | pbcopy
    echo "✅ Public key copied to clipboard"
elif command -v wl-copy >/dev/null 2>&1; then
    echo "$PUBLIC_KEY" | wl-copy
    echo "✅ Public key copied to clipboard"
elif command -v xclip >/dev/null 2>&1; then
    echo "$PUBLIC_KEY" | xclip -selection clipboard
    echo "✅ Public key copied to clipboard"
else
    echo "⚠️ Clipboard utility not found."
    echo
    echo "$PUBLIC_KEY"
fi

echo
echo "====================================="
echo " Next Steps"
echo "====================================="
echo
echo "1. Open: https://github.com/settings/keys"
echo "2. Click 'New SSH Key'"
echo "3. Paste the key from your clipboard"
echo "4. Save"
echo
echo "To test:"
echo "ssh -T git@github.com"
echo
echo "Private Key : $SSH_KEY_PATH"
echo "Public Key  : $SSH_KEY_PATH.pub"