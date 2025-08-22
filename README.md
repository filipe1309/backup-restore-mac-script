# backup-restore-mac-script

## Usage

### Backup

```sh
./backup_mac.sh
```

🚀 How it works
- Backs up all critical folders and configs.
- Exports Homebrew package list for easy reinstall.
- Collects apps list.
- Compresses everything into Backup_Mac_YYYYMMDD_HHMMSS.tar.gz.
- You can copy this single file to an external disk, cloud, or USB.

### Restore

```sh
./restore_mac.sh ~/Backup_Mac_20250822_141500.tar.gz
```

> [!NOTE]
> This restores files and configs, not macOS system apps.  
> Homebrew packages are reinstalled if brew is available.  
> iTerm2 & VSCode configs go back into the right place.  
