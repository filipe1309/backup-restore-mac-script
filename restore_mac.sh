#!/bin/bash

# ================================
# Mac Restore Script
# ================================

if [ $# -lt 1 ]; then
  echo "Usage: $0 <backup_archive.tar.gz>"
  exit 1
fi

ARCHIVE_PATH="$1"

if [ ! -f "$ARCHIVE_PATH" ]; then
  echo "❌ Backup archive not found: $ARCHIVE_PATH"
  exit 1
fi

# Extract backup
RESTORE_DIR="$HOME/Restore_Temp_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESTORE_DIR"

echo "📦 Extracting backup to: $RESTORE_DIR"
tar -xzf "$ARCHIVE_PATH" -C "$RESTORE_DIR"

# Backup directory inside tar
BACKUP_DIR=$(find "$RESTORE_DIR" -maxdepth 1 -type d -name "Backup_Mac_*" | head -n 1)
if [ -z "$BACKUP_DIR" ]; then
  echo "❌ Could not find backup directory inside archive."
  exit 1
fi

echo "➡️ Restoring from: $BACKUP_DIR"

# 2. Restore SSH keys
if [ -d "$BACKUP_DIR/.ssh" ]; then
  echo "➡️ Restoring SSH keys..."
  rsync -avh "$BACKUP_DIR/.ssh" "$HOME/"
  chmod 700 "$HOME/.ssh"
  chmod 600 "$HOME/.ssh"/*
fi

# 3. Restore dotfiles
for file in .gitconfig .zshrc .bash_profile .bashrc; do
  if [ -f "$BACKUP_DIR/$file" ]; then
    echo "➡️ Restoring $file"
    cp -f "$BACKUP_DIR/$file" "$HOME/$file"
  fi
done

# 4. Restore VSCode settings
if [ -d "$BACKUP_DIR/vscode_settings" ]; then
  echo "➡️ Restoring VSCode settings..."
  mkdir -p "$HOME/Library/Application Support/Code/User"
  rsync -avh "$BACKUP_DIR/vscode_settings/" "$HOME/Library/Application Support/Code/User/"
fi

# 5. Restore iTerm2 preferences
if [ -f "$BACKUP_DIR/com.googlecode.iterm2.plist" ]; then
  echo "➡️ Restoring iTerm2 preferences..."
  cp "$BACKUP_DIR/com.googlecode.iterm2.plist" "$HOME/Library/Preferences/"
fi

# 6. Brew reinstall (optional)
if [ -f "$BACKUP_DIR/brew-formulae.txt" ] || [ -f "$BACKUP_DIR/brew-casks.txt" ]; then
  if command -v brew >/dev/null 2>&1; then
    echo "➡️ Reinstalling Homebrew packages..."
    if [ -f "$BACKUP_DIR/brew-formulae.txt" ]; then
      xargs brew install < "$BACKUP_DIR/brew-formulae.txt"
    fi
    if [ -f "$BACKUP_DIR/brew-casks.txt" ]; then
      xargs brew install --cask < "$BACKUP_DIR/brew-casks.txt"
    fi
  else
    echo "⚠️ Homebrew not installed. Install it first: https://brew.sh"
  fi
fi

echo "✅ Restore completed!"

