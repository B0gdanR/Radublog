# Obsidian to Hugo Sync Script
param(
    [string]$ObsidianPath = "D:\Blog\Obsidian\Tutorials",
    [string]$HugoContentPath = "C:\Users\Radu\Documents\Radublog\content",
    [switch]$DryRun,
    [switch]$AutoCommit
)

Write-Host "Obsidian to Hugo Sync" -ForegroundColor Green
Write-Host "Source: $ObsidianPath" -ForegroundColor Cyan
Write-Host "Destination: $HugoContentPath" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $ObsidianPath)) {
    Write-Host "ERROR: Obsidian path not found: $ObsidianPath" -ForegroundColor Red
    exit 1
}

# Find all markdown files in Obsidian
$obsidianFiles = Get-ChildItem -Path $ObsidianPath -Filter "*.md" -Recurse
$publishedCount = 0

foreach ($file in $obsidianFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    
    # Check if file has Hugo front matter (starts with ---)
    if ($content -match "^---[\s\S]*?---") {
        # Determine destination - posts go to content/post/
        $destPath = Join-Path $HugoContentPath "post" $file.Name
        
        if ($DryRun) {
            Write-Host "  [DRY RUN] Would sync: $($file.Name)" -ForegroundColor Yellow
        } else {
            Write-Host "  ✅ Syncing: $($file.Name)" -ForegroundColor Green
            
            # Ensure destination directory exists
            $destDir = Split-Path $destPath -Parent
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            
            Copy-Item $file.FullName $destPath -Force
            $publishedCount++
        }
    } else {
        Write-Host "  ⚠️  Skipping: $($file.Name) (no Hugo front matter)" -ForegroundColor Gray
    }
}

if (-not $DryRun) {
    Write-Host ""
    Write-Host "✅ Sync completed! Published $publishedCount files." -ForegroundColor Green
    
    if ($AutoCommit) {
        Write-Host ""
        Write-Host "Committing to Git..." -ForegroundColor Yellow
        
        Set-Location "C:\Users\Radu\Documents\Radublog"
        git add .
        
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        git commit -m "Update blog content from Obsidian - $timestamp"
        
        Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
        git push
        
        Write-Host "✅ Changes pushed! Hostinger will auto-deploy." -ForegroundColor Green
    }
}
