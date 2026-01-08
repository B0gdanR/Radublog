<#
.SYNOPSIS
    HalfOnCloud Blog Publishing Script
    Automates: Obsidian → Hugo → GitHub → Hostinger

.DESCRIPTION
    This script handles the complete blog publishing workflow:
    1. Copies posts from Obsidian to Hugo
    2. Converts Obsidian image links to Hugo format
    3. Copies images from Obsidian attachments to Hugo static folder
    4. Builds the Hugo site
    5. Commits and pushes to GitHub (master branch)
    6. Updates the hostinger branch for deployment

.NOTES
    Author: Radu Bogdan
    Blog: halfoncloud.com
    Last Updated: 2026-01-08
#>

#Requires -Version 5.1

# ============================================================================
# CONFIGURATION - Edit these paths to match your setup
# ============================================================================

$Config = @{
    # Hugo blog location
    HugoBlogPath       = "C:\Users\Radu\Documents\Radublog"
    
    # Obsidian paths
    ObsidianPostsPath  = "D:\Blog\Obsidian\Tutorials\Work\Site\Articles\Published\Cloud"
    ObsidianImagesPath = "D:\Blog\Obsidian\Tutorials\Personal\Images"
    
    # Hugo content paths (relative to HugoBlogPath)
    HugoPostsFolder    = "content\posts"
    HugoImagesFolder   = "static\images"
    
    # Git settings
    GitRemote          = "origin"
    MainBranch         = "master"
    HostingerBranch    = "hostinger"
}

# ============================================================================
# FUNCTIONS
# ============================================================================

function Write-Step {
    param([string]$Message)
    Write-Host "`n[$([DateTime]::Now.ToString('HH:mm:ss'))] " -NoNewline -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor White
    Write-Host ("-" * 60) -ForegroundColor DarkGray
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  → $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "  ✗ $Message" -ForegroundColor Red
}

function Convert-ObsidianToHugo {
    <#
    .SYNOPSIS
        Converts Obsidian markdown syntax to Hugo-compatible format
    #>
    param(
        [string]$Content,
        [string]$PostName
    )
    
    # Convert Obsidian image links: ![[image.png]] → ![](/images/image.png)
    # Also handles: ![[image.png|caption]] → ![caption](/images/image.png)
    $pattern = '!\[\[([^\]|]+)(?:\|([^\]]+))?\]\]'
    
    $converted = [regex]::Replace($Content, $pattern, {
        param($match)
        $imageName = $match.Groups[1].Value.Trim()
        $caption = $match.Groups[2].Value.Trim()
        
        if ($caption) {
            return "![$caption](/images/$imageName)"
        } else {
            return "![](/images/$imageName)"
        }
    })
    
    # Convert standard markdown images with relative paths to /images/
    # Matches: ![alt text](../path/to/image.png) or ![alt](path/image.png)
    # But NOT URLs starting with http
    $mdImagePattern = '!\[([^\]]*)\]\((?!http)([^)]+)\)'
    
    $converted = [regex]::Replace($converted, $mdImagePattern, {
        param($match)
        $altText = $match.Groups[1].Value.Trim()
        $imagePath = $match.Groups[2].Value.Trim()
        
        # Extract just the filename from any path
        $imageName = Split-Path $imagePath -Leaf
        
        return "![$altText](/images/$imageName)"
    })
    
    # Convert Obsidian internal links: [[Page Name]] → [Page Name](/posts/page-name/)
    $linkPattern = '\[\[([^\]|]+)(?:\|([^\]]+))?\]\]'
    $converted = [regex]::Replace($converted, $linkPattern, {
        param($match)
        $pageName = $match.Groups[1].Value.Trim()
        $displayText = $match.Groups[2].Value.Trim()
        
        if (-not $displayText) {
            $displayText = $pageName
        }
        
        # Convert to URL-friendly slug
        $slug = $pageName.ToLower() -replace '\s+', '-' -replace '[^a-z0-9-]', ''
        
        return "[$displayText](/posts/$slug/)"
    })
    
    return $converted
}

function Get-ImagesFromContent {
    <#
    .SYNOPSIS
        Extracts image filenames from Obsidian markdown content
    #>
    param([string]$Content)
    
    $images = @()
    
    # Match Obsidian image syntax: ![[image.png]] or ![[image.png|caption]]
    $pattern = '!\[\[([^\]|]+)(?:\|[^\]]+)?\]\]'
    $matches = [regex]::Matches($Content, $pattern)
    
    foreach ($match in $matches) {
        $images += $match.Groups[1].Value.Trim()
    }
    
    # Also match standard markdown images that reference local files
    $mdPattern = '!\[[^\]]*\]\((?!http)([^)]+)\)'
    $mdMatches = [regex]::Matches($Content, $mdPattern)
    
    foreach ($match in $mdMatches) {
        $imagePath = $match.Groups[1].Value.Trim()
        $images += Split-Path $imagePath -Leaf
    }
    
    return $images | Select-Object -Unique
}

function Ensure-HugoFrontmatter {
    <#
    .SYNOPSIS
        Ensures post has valid Hugo frontmatter, adds if missing
    #>
    param(
        [string]$Content,
        [string]$FileName
    )
    
    # Check if frontmatter exists (starts with ---)
    if ($Content -match '^---\s*\n') {
        return $Content
    }
    
    # Generate frontmatter from filename
    $title = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    $date = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
    
    $frontmatter = @"
---
title: "$title"
date: $date
draft: false
tags: []
---

"@
    
    return $frontmatter + $Content
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

$ErrorActionPreference = "Stop"
$startTime = Get-Date

Write-Host "`n" 
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║           HalfOnCloud Blog Publishing Script                 ║" -ForegroundColor Magenta
Write-Host "║                   halfoncloud.com                            ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta

# Change to Hugo blog directory
Set-Location $Config.HugoBlogPath
Write-Info "Working directory: $($Config.HugoBlogPath)"

# ============================================================================
# STEP 1: Copy and Convert Posts from Obsidian
# ============================================================================
Write-Step "STEP 1: Processing Obsidian Posts"

$hugoPostsPath = Join-Path $Config.HugoBlogPath $Config.HugoPostsFolder
$hugoImagesPath = Join-Path $Config.HugoBlogPath $Config.HugoImagesFolder

# Ensure directories exist
if (-not (Test-Path $hugoPostsPath)) {
    New-Item -ItemType Directory -Path $hugoPostsPath -Force | Out-Null
    Write-Info "Created posts directory: $hugoPostsPath"
}

if (-not (Test-Path $hugoImagesPath)) {
    New-Item -ItemType Directory -Path $hugoImagesPath -Force | Out-Null
    Write-Info "Created images directory: $hugoImagesPath"
}

# Get all markdown files from Obsidian
$obsidianPosts = Get-ChildItem -Path $Config.ObsidianPostsPath -Filter "*.md" -ErrorAction SilentlyContinue

if ($obsidianPosts.Count -eq 0) {
    Write-Info "No posts found in Obsidian folder"
} else {
    Write-Info "Found $($obsidianPosts.Count) post(s) in Obsidian"
    
    $allImages = @()
    
    foreach ($post in $obsidianPosts) {
        Write-Info "Processing: $($post.Name)"
        
        # Read content
        $content = Get-Content $post.FullName -Raw -Encoding UTF8
        
        # Extract images before conversion
        $images = Get-ImagesFromContent -Content $content
        $allImages += $images
        
        # Ensure frontmatter exists
        $content = Ensure-HugoFrontmatter -Content $content -FileName $post.Name
        
        # Convert Obsidian syntax to Hugo
        $convertedContent = Convert-ObsidianToHugo -Content $content -PostName $post.BaseName
        
        # Save to Hugo posts folder
        $destPath = Join-Path $hugoPostsPath $post.Name
        $convertedContent | Set-Content $destPath -Encoding UTF8 -NoNewline
        
        Write-Success "Copied: $($post.Name)"
        
        if ($images.Count -gt 0) {
            Write-Info "  Found $($images.Count) image(s): $($images -join ', ')"
        }
    }
    
    # Copy images
    if ($allImages.Count -gt 0) {
        Write-Step "STEP 1b: Copying Images"
        
        $uniqueImages = $allImages | Select-Object -Unique
        $copiedCount = 0
        
        foreach ($image in $uniqueImages) {
            # Try multiple possible image locations
            $possiblePaths = @(
                (Join-Path $Config.ObsidianImagesPath $image),
                (Join-Path $Config.ObsidianPostsPath $image),
                (Join-Path (Split-Path $Config.ObsidianPostsPath -Parent) "Images\$image"),
                (Join-Path (Split-Path $Config.ObsidianPostsPath -Parent) "Attachments\$image")
            )
            
            $found = $false
            foreach ($sourcePath in $possiblePaths) {
                if (Test-Path $sourcePath) {
                    $destImagePath = Join-Path $hugoImagesPath $image
                    Copy-Item $sourcePath $destImagePath -Force
                    Write-Success "Copied image: $image"
                    $copiedCount++
                    $found = $true
                    break
                }
            }
            
            if (-not $found) {
                Write-Error "Image not found: $image"
            }
        }
        
        Write-Info "Copied $copiedCount of $($uniqueImages.Count) images"
    }
}

# ============================================================================
# STEP 2: Build Hugo Site
# ============================================================================
Write-Step "STEP 2: Building Hugo Site"

# Clean and build
hugo --cleanDestinationDir --minify --baseURL "https://halfoncloud.com/"

if ($LASTEXITCODE -eq 0) {
    Write-Success "Hugo build completed successfully"
    
    # Count output files
    $publicFiles = Get-ChildItem -Path "public" -Recurse -File
    Write-Info "Generated $($publicFiles.Count) files in public/"
} else {
    Write-Error "Hugo build failed!"
    exit 1
}

# ============================================================================
# STEP 3: Git Commit and Push to Master
# ============================================================================
Write-Step "STEP 3: Committing to Git (master branch)"

# Check git status
$gitStatus = git status --porcelain

if ($gitStatus) {
    $commitMessage = "Blog update: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    
    git add .
    git commit -m $commitMessage
    
    Write-Info "Pushing to $($Config.GitRemote)/$($Config.MainBranch)..."
    git push $Config.GitRemote $Config.MainBranch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Pushed to master branch"
    } else {
        Write-Error "Failed to push to master"
    }
} else {
    Write-Info "No changes to commit"
}

# ============================================================================
# STEP 4: Update Hostinger Branch
# ============================================================================
Write-Step "STEP 4: Updating Hostinger Branch"

Write-Info "This step often fails with git subtree. Attempting anyway..."

try {
    # Delete remote hostinger branch
    Write-Info "Deleting old hostinger branch..."
    git push origin --delete hostinger 2>$null
    
    # Create new subtree split
    Write-Info "Creating subtree split..."
    git subtree split --prefix=public -b new-hostinger
    
    # Push to hostinger branch
    Write-Info "Pushing to hostinger branch..."
    git push origin new-hostinger:hostinger
    
    # Cleanup local branch
    git branch -D new-hostinger 2>$null
    
    Write-Success "Hostinger branch updated successfully!"
    
} catch {
    Write-Error "Hostinger branch update failed (this is common)"
    Write-Host ""
    Write-Host "  Run these commands manually:" -ForegroundColor Yellow
    Write-Host "  ─────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  git push origin :hostinger" -ForegroundColor White
    Write-Host "  git subtree split --prefix=public -b new-hostinger" -ForegroundColor White
    Write-Host "  git push origin new-hostinger:hostinger" -ForegroundColor White
    Write-Host "  git branch -D new-hostinger" -ForegroundColor White
    Write-Host ""
    Write-Host "  Or manually upload public\ folder to Hostinger" -ForegroundColor Yellow
}

# ============================================================================
# SUMMARY
# ============================================================================
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n"
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    Publishing Complete!                      ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Duration: $($duration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor Cyan
Write-Host "  Local:    http://localhost:1313" -ForegroundColor Cyan
Write-Host "  Live:     https://halfoncloud.com" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Yellow
Write-Host "  1. Check https://halfoncloud.com to verify deployment" -ForegroundColor White
Write-Host "  2. If site not updated, manually upload public\ to Hostinger" -ForegroundColor White
Write-Host ""