
+++
title = "Complete Oh My Posh PowerShell Tutorial"
date = "2025-09-14T01:00:00+03:00"
draft = false
tags = ["PowerShell"]
categories = ["General"]
author = "Radu Bogdan"
description = "Complete Oh My Posh PowerShell Tutorial"
thumbnail = "images/ballpoint-pen.jpg"
+++
### Step 1: Install PowerShell 7

```
winget install Microsoft.PowerShell
```

Note: Close and Reopen PowerShell 7 as Administrator

### Step 2: Install Oh My Posh

```
winget install JanDeDobbeleer.OhMyPosh -s winget
```

Note: Close and Reopen PowerShell 7 as Administrator

### Step 3: Install Nerd Font

*oh-my-posh font install meslo*

Note: From the PowerShell Console: Right-click title bar → Properties → Font → Select "MesloLGM NF"

### Step 4: Create PowerShell Profile

```powershell
$profileDir = Split-Path -Path $PROFILE -Parent
New-Item -ItemType Directory -Path $profileDir -Force
New-Item -ItemType File -Path $PROFILE -Force

```

### Step 5: Find and Set Themes Path

```powershell
$possiblePaths = @(
    "$env:LOCALAPPDATA\Programs\oh-my-posh\themes",
    "$env:USERPROFILE\AppData\Local\Programs\oh-my-posh\themes",
    "C:\Program Files\oh-my-posh\themes"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $env:POSH_THEMES_PATH = $path
        break
    }
}

```


### Step 6: Configure Profile with Paradox Theme


```powershell

$profileContent = @"
if (`$env:POSH_THEMES_PATH) {
    oh-my-posh init pwsh --config "`$env:POSH_THEMES_PATH\paradox.omp.json" | Invoke-Expression
} else {
    `$themePaths = @(
        "`$env:LOCALAPPDATA\Programs\oh-my-posh\themes\paradox.omp.json",
        "`$env:USERPROFILE\AppData\Local\Programs\oh-my-posh\themes\paradox.omp.json",
        "C:\Program Files\oh-my-posh\themes\paradox.omp.json"
    )
    
    foreach (`$themePath in `$themePaths) {
        if (Test-Path `$themePath) {
            oh-my-posh init pwsh --config "`$themePath" | Invoke-Expression
            break
        }
    }
}

function Switch-PoshTheme {
    param([string]`$ThemeName)
    if (`$env:POSH_THEMES_PATH) {
        `$configPath = "`$env:POSH_THEMES_PATH\`$ThemeName.omp.json"
        if (Test-Path `$configPath) {
            oh-my-posh init pwsh --config `$configPath | Invoke-Expression
        }
    }
}

function Get-PoshThemes {
    if (`$env:POSH_THEMES_PATH) {
        Get-ChildItem "`$env:POSH_THEMES_PATH\*.omp.json" | ForEach-Object {
            `$_.Name -replace '\.omp\.json$', ''
        }
    }
}
"@

Set-Content -Path $PROFILE -Value $profileContent

```
### Step 7: Activate Profile

*. $PROFILE*

### Step 8: Verification Commands


```powershell
oh-my-posh --version
$PROFILE
$env:POSH_THEMES_PATH
Get-PoshThemes
Switch-PoshTheme 'atomicBit'
Switch-PoshTheme 'paradox'
```
### Step 9: Edit your profile

*notepad $PROFILE*

Note: Change the theme line from paradox.omp.json to quick-term.omp.json:

![[Pasted image 20250914165215.png]]

### Step 10: Reload profile

*. $PROFILE*

![[Pasted image 20250914165500.png]]

