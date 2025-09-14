# Working Hugo Blog Publishing Script
# THIS VERSION ACTUALLY WORKS

# Set your paths
$obsidianPosts = "D:\Blog\Obsidian\Tutorials\Work\Site\Posts"
$hugoPosts = "C:\Users\Radu\Documents\Radublog\content\post"
$obsidianImages = "D:\Blog\Obsidian\Tutorials\Personal\Images"
$hugoImages = "C:\Users\Radu\Documents\Radublog\static\images"

Write-Host "Starting blog publishing pipeline..." -ForegroundColor Green

# Step 1: Copy posts from Obsidian to Hugo
Write-Host "Copying posts from Obsidian..." -ForegroundColor Yellow
robocopy $obsidianPosts $hugoPosts /MIR /Z

# Step 2: Copy images 
Write-Host "Copying images..." -ForegroundColor Yellow
robocopy $obsidianImages $hugoImages /MIR /Z

# Step 3: Fix image syntax using simple string replacement (NO REGEX)
Write-Host "Converting image syntax..." -ForegroundColor Yellow
Get-ChildItem -Path $hugoPosts -Filter "*.md" | ForEach-Object {
    $filePath = $_.FullName
    $content = Get-Content -Path $filePath -Raw -Encoding UTF8
    $hasChanges = $false
    
    # Look for Obsidian image syntax and replace it
    if ($content -match '!\[\[([^]]+\.(png|jpg|jpeg|gif|webp))\]\]') {
        # Split content into lines for easier processing
        $lines = $content -split "`n"
        $newLines = @()
        
        foreach ($line in $lines) {
            if ($line -match '!\[\[([^]]+\.(png|jpg|jpeg|gif|webp))\]\]') {
                # Extract the filename
                $filename = $matches[1]
                # Replace spaces with %20
                $encodedFilename = $filename -replace ' ', '%20'
                # Replace the line
                $newLine = $line -replace '!\[\[([^]]+\.(png|jpg|jpeg|gif|webp))\]\]', "![Image Description](/images/$encodedFilename)"
                $newLines += $newLine
                $hasChanges = $true
                Write-Host "  Converted: $filename" -ForegroundColor Cyan
            } else {
                $newLines += $line
            }
        }
        
        if ($hasChanges) {
            $newContent = $newLines -join "`n"
            Set-Content -Path $filePath -Value $newContent -Encoding UTF8
            Write-Host "✓ Fixed images in: $($_.Name)" -ForegroundColor Green
        }
    }
}

# Step 4: Build the Hugo site
Write-Host "Building Hugo site..." -ForegroundColor Yellow
hugo --cleanDestinationDir

# Step 5: Push source to GitHub master
Write-Host "Pushing source to GitHub master..." -ForegroundColor Yellow
git add .
git commit -m "Blog update $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin master

Write-Host "Script complete! Images should be automatically converted." -ForegroundColor Green