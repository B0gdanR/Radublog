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

# Step 3: Build the Hugo site
Write-Host "Building Hugo site..." -ForegroundColor Yellow
hugo --cleanDestinationDir

# Step 4: Push source to GitHub master (your backup/version control)
Write-Host "Pushing source to GitHub master..." -ForegroundColor Yellow
git add .
git commit -m "Blog update $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin master

# Step 5: Push built site to GitHub hostinger branch (for your hosting)
Write-Host "Deploying to hostinger branch..." -ForegroundColor Yellow
git subtree push --prefix=public origin hostinger

Write-Host "Complete! Your blog is now live." -ForegroundColor Green