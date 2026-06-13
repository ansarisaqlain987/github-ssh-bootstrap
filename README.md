# GitHub SSH Key Setup

A set of bash scripts to streamline SSH key management for GitHub.

## Scripts

### setup-github-ssh.sh

This script automates the process of creating and configuring an SSH key for GitHub. It prompts the user for an email address and a key name, validates the inputs, and then performs the following steps:

- Generates an Ed25519 SSH key pair in `~/.ssh/`
- Starts the SSH agent and adds the new private key using the `--apple-use-keychain` flag on macOS (or standard `ssh-add` on Linux)
- Copies the public key to the clipboard using `pbcopy`, `wl-copy`, or `xclip` depending on what is available
- Displays next steps: open GitHub SSH key settings, paste the key, and test the connection with `ssh -T git@github.com`

### list-local-ssh-keys.sh

This script scans the `~/.ssh/` directory and lists all SSH private keys alongside their corresponding public keys. For each key pair it displays:

- The private and public key filenames
- The key fingerprint (via `ssh-keygen -l`)
- The comment stored in the public key (usually an email or label)

At the end, it also shows the identities currently loaded in the running SSH agent via `ssh-add -l`.

## How To Run

Both scripts are bash scripts and require no external dependencies beyond standard OpenSSH tools.

```bash
# Generate and configure a new GitHub SSH key
bash setup-github-ssh.sh

# List all local SSH keys and agent-loaded identities
bash list-local-ssh-keys.sh
```

Alternatively, you can make them executable first:

```bash
chmod +x setup-github-ssh.sh list-local-ssh-keys.sh
./setup-github-ssh.sh
./list-local-ssh-keys.sh
```
