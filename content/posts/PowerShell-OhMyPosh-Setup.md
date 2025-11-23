---
title: "PowerShell 7 + Oh My Posh Setup Guide"
date: "2025-10-30"
tags: ["PowerShell", "Oh-My-Posh", "Setup"]
categories: ["Technical Documentation"]
author: "Radu Bogdan"
description: "Complete guide to install and configure PowerShell 7 with Oh My Posh using Scoop"
---

## Prerequisites
Run PowerShell as Administrator for initial setup

## Step 1: Install or Upgrade PowerShell 7
```powershell
winget install Microsoft.PowerShell
```
**CRITICAL:** Close all PowerShell windows and reopen

## Step 2: Verify PowerShell Version
```powershell
$PSVersionTable.PSVersion
```
Should show 7.5.4 or higher

## Step 3: Install Scoop (Package Manager)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

## Step 4: Install Oh My Posh via Scoop
```powershell
scoop install oh-my-posh
```
**CRITICAL:** Close all PowerShell windows and reopen

## Step 5: Verify Oh My Posh Installation
```powershell
oh-my-posh --version
Get-ChildItem "$HOME\scoop\apps\oh-my-posh\current\themes" | Select-Object -First 5 Name
```

## Step 6: Install Nerd Font
```powershell
oh-my-posh font install meslo
```
**Configure terminal:** Right-click title bar → Properties → Font → Select "MesloLGM NF"

## Step 7: Create PowerShell Profile
```powershell
New-Item -ItemType File -Path $PROFILE -Force
```

## Step 8: Configure Profile
```powershell
notepad $PROFILE
```
Add this single line:
```powershell
oh-my-posh init pwsh --config "$HOME\scoop\apps\oh-my-posh\current\themes\quick-term.omp.json" | Invoke-Expression
```
Save and close

## Step 9: Reload Profile
```powershell
. $PROFILE
```

## Step 10: Verify Theme is Working
You should see a styled prompt with segments showing username, path, and execution time

## Optional: Add PSReadLine Configuration
```powershell
notepad $PROFILE
```
Add these lines below the oh-my-posh line:
```powershell
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
```

## Changing Themes Later

### List available themes:
```powershell
Get-ChildItem "$HOME\scoop\apps\oh-my-posh\current\themes" | ForEach-Object { $_.Name -replace '\.omp\.json$', '' }
```

### Change theme:
```powershell
notepad $PROFILE
```
Edit the theme name in the config path, then reload:
```powershell
. $PROFILE
```

## Critical Notes

1. **ALWAYS close and reopen PowerShell after installations** - environment variables require new process
2. **DO NOT use winget for Oh My Posh** - the WindowsApps package is broken and missing themes
3. Scoop installs to: `$HOME\scoop\apps\oh-my-posh\current`
4. Profile location: `$PROFILE` (typically `C:\Users\USERNAME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`)
5. If profile errors on startup, disable it: `Rename-Item $PROFILE "$PROFILE.bak"`

## Troubleshooting

### Check if oh-my-posh is in PATH:
```powershell
Get-Command oh-my-posh | Select-Object -ExpandProperty Source
```

### Verify themes exist:
```powershell
Test-Path "$HOME\scoop\apps\oh-my-posh\current\themes\quick-term.omp.json"
```

### View current profile:
```powershell
Get-Content $PROFILE
```

### Reinstall if needed:
```powershell
scoop uninstall oh-my-posh
scoop install oh-my-posh
```

### Disable profile temporarily:
```powershell
Rename-Item $PROFILE "$PROFILE.bak"
```

### Re-enable profile:
```powershell
Rename-Item "$PROFILE.bak" $PROFILE
```

## Key Lessons

1. Winget quality varies by package source - Microsoft Store apps are often incomplete
2. Always restart terminal sessions after installing tools that modify PATH or environment variables
3. Scoop is more reliable than winget for developer CLI tools
4. Keep profiles minimal - one line for theme initialization is sufficient
5. When troubleshooting, disable the profile first to prevent cascading errors
6. For enterprise environments, use Intune/SCCM to deploy these tools, not manual installations

## File Locations Reference

| Item | Location |
|------|----------|
| PowerShell Profile | `$PROFILE` or `C:\Users\USERNAME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |
| Oh My Posh Installation | `$HOME\scoop\apps\oh-my-posh\current` |
| Themes | `$HOME\scoop\apps\oh-my-posh\current\themes` |
| Scoop Installation | `$HOME\scoop` |

## Popular Themes to Try

- `quick-term` - Minimal, fast, shows essential info
- `paradox` - Segments with icons and colors
- `atomicBit` - Compact with git status
- `agnoster` - Classic powerline style
- `jandedobbeleer` - Author's personal theme

## Additional Resources

- Oh My Posh Documentation: https://ohmyposh.dev/docs
- Scoop Documentation: https://scoop.sh
- PowerShell Documentation: https://docs.microsoft.com/powershell
