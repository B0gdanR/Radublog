# Simple Hugo Blog Publishing Script
# Obsidian → Hugo → GitHub → Website

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

# Step 3: Convert Obsidian image syntax to Hugo format
Write-Host "Converting image syntax..." -ForegroundColor Yellow
Get-ChildItem -Path $hugoPosts -Filter "*.md" | ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw
    
    # Simple, safe regex replacement
    $newContent = $content -replace '!\[\[([^]]+\.(?:png|jpg|jpeg|gif))\]\]', '![Image Description](/images/$1)'
    
    # Only proceed if we actually found matches
    if ($content -ne $newContent) {
        # Replace spaces with %20 in the converted paths only
        $newContent = $newContent -replace '(/images/)([^)]*)', {
            param($match)
            $path = $match.Groups[1].Value
            $filename = $match.Groups[2].Value -replace ' ', '%20'
            "$path$filename"
        }
        
        Set-Content -Path $_.FullName -Value $newContent -Encoding UTF8
        Write-Host "Fixed images in: $($_.Name)" -ForegroundColor Green
    }
}

# Step 4: Build the Hugo site
Write-Host "Building Hugo site..." -ForegroundColor Yellow
hugo --cleanDestinationDir

# Step 5: Push source to GitHub master (your backup/version control)
Write-Host "Pushing source to GitHub master..." -ForegroundColor Yellow
git add .
git commit -m "Blog update $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin master

# Step 6: Push built site to GitHub hostinger branch (for your hosting)
Write-Host "Deploying to hostinger branch..." -ForegroundColor Yellow
git subtree push --prefix=public origin hostinger

Write-Host "Complete! Your blog is now live." -ForegroundColor Green