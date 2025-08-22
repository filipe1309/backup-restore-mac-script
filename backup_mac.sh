#!/bin/bash

# ================================
# Mac Backup Script (with tar.gz)
# ================================

# Where to store the backup
BACKUP_DIR="$HOME/Backup_Mac_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Creating backup at: $BACKUP_DIR"

# 2. SSH keys
if [ -d "$HOME/.ssh" ]; then
  echo "➡️ Backing up SSH keys..."
  rsync -avh "$HOME/.ssh" "$BACKUP_DIR/"
fi

# 3. Git config & Zsh/Bash profiles
echo "➡️ Backing up dotfiles..."
cp -f "$HOME/.gitconfig" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc" "$BACKUP_DIR/" 2>/dev/null

# 4. VSCode settings (if used)
if [ -d "$HOME/Library/Application Support/Code/User" ]; then
  echo "➡️ Backing up VSCode settings..."
  rsync -avh "$HOME/Library/Application Support/Code/User" "$BACKUP_DIR/vscode_settings"
fi

# 5. Homebrew installed packages
if command -v brew >/dev/null 2>&1; then
  echo "➡️ Saving Homebrew package list..."
  brew list --formula > "$BACKUP_DIR/brew-formulae.txt"
  brew list --cask > "$BACKUP_DIR/brew-casks.txt"
fi

# 6. Applications list (App Store + Others)
echo "➡️ Saving applications list..."
system_profiler SPApplicationsDataType > "$BACKUP_DIR/applications_list.txt"

# 7. iTerm2 or Terminal preferences
if [ -f "$HOME/Library/Preferences/com.googlecode.iterm2.plist" ]; then
  echo "➡️ Backing up iTerm2 preferences..."
  cp "$HOME/Library/Preferences/com.googlecode.iterm2.plist" "$BACKUP_DIR/"
fi

# ================================
# Compress Backup
# ================================
echo "📦 Compressing backup into tar.gz..."
ARCHIVE_NAME="$BACKUP_DIR.tar.gz"
tar -czf "$ARCHIVE_NAME" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"

# Optionally remove uncompressed folder (uncomment if you only want the .tar.gz)
# rm -rf "$BACKUP_DIR"

echo "✅ Backup completed!"
echo "Backup archive: $ARCHIVE_NAME"

