# PowerShell Script for Hugo Blog Publishing

# Set variables for Obsidian to Hugo copy
$sourcePath = "D:\Blog\Obsidian\Tutorials\Work\Site\Posts"
$destinationPath = "C:\Users\Radu\Documents\Radublog\content\post"

# Set Github repo 
$myrepo = "https://github.com/B0gdanR/Radublog.git"

# Set error handling
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Change to the script's directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $ScriptDir

# Check for required commands
$requiredCommands = @('git', 'hugo')

# Check for Python command (python or python3)
if (Get-Command 'python' -ErrorAction SilentlyContinue) {
    $pythonCommand = 'python'
} elseif (Get-Command 'python3' -ErrorAction SilentlyContinue) {
    $pythonCommand = 'python3'
} else {
    Write-Error "Python is not installed or not in PATH."
    exit 1
}

foreach ($cmd in $requiredCommands) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "$cmd is not installed or not in PATH."
        exit 1
    }
}

# Step 1: Check if Git is initialized, and initialize if necessary
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init
    git remote add origin $myrepo
} else {
    Write-Host "Git repository already initialized." -ForegroundColor Green
    $remotes = git remote
    if (-not ($remotes -contains 'origin')) {
        Write-Host "Adding remote origin..." -ForegroundColor Yellow
        git remote add origin $myrepo
    }
}

# Step 2: Backup custom files before syncing
Write-Host "Backing up custom files..." -ForegroundColor Cyan

$customFiles = @(
    "static\css\custom.css",
    "themes\hugo-clarity\layouts\partials\image.html"
)

foreach ($file in $customFiles) {
    if (Test-Path $file) {
        Copy-Item $file "$file.backup" -Force
        Write-Host "Backed up: $file" -ForegroundColor Green
    }
}

# Step 3: Sync posts from Obsidian to Hugo content folder using Robocopy
Write-Host "Syncing posts from Obsidian..." -ForegroundColor Cyan

if (-not (Test-Path $sourcePath)) {
    Write-Error "Source path does not exist: $sourcePath"
    exit 1
}

if (-not (Test-Path $destinationPath)) {
    Write-Error "Destination path does not exist: $destinationPath"
    exit 1
}

# Use Robocopy to mirror the directories
$robocopyOptions = @('/MIR', '/Z', '/W:5', '/R:3', '/XD', '.obsidian')
$robocopyResult = robocopy $sourcePath $destinationPath @robocopyOptions

# Robocopy exit codes: 0-7 are success, 8+ are errors
if ($LASTEXITCODE -ge 8) {
    Write-Error "Robocopy failed with exit code $LASTEXITCODE"
    exit 1
} else {
    Write-Host "Robocopy completed successfully with exit code $LASTEXITCODE" -ForegroundColor Green
}

# Step 4: Restore custom files after syncing
Write-Host "Restoring custom files..." -ForegroundColor Cyan

foreach ($file in $customFiles) {
    if (Test-Path "$file.backup") {
        # Ensure directory exists before restoring
        $fileDir = Split-Path $file -Parent
        if ($fileDir -and -not (Test-Path $fileDir)) {
            New-Item -ItemType Directory -Path $fileDir -Force
        }
        
        Copy-Item "$file.backup" $file -Force
        Remove-Item "$file.backup" -Force
        Write-Host "Restored: $file" -ForegroundColor Green
    }
}

# Step 5: Create and execute Python script to handle image links
Write-Host "Processing image links in Markdown files..." -ForegroundColor Cyan

# Create the Python script content
$pythonScriptContent = @'
import os
import re
import shutil

# Paths
posts_dir = r"C:\Users\Radu\Documents\Radublog\content\post"
attachments_dir = r"D:\Blog\Obsidian\Tutorials\Personal\Images"
static_images_dir = r"C:\Users\Radu\Documents\Radublog\static\images"

# Ensure the static images directory exists
os.makedirs(static_images_dir, exist_ok=True)

# Step 1: Process each markdown file in the posts directory
for filename in os.listdir(posts_dir):
    if filename.endswith(".md"):
        filepath = os.path.join(posts_dir, filename)
        try:
            with open(filepath, "r", encoding="utf-8") as file:
                content = file.read()
        except UnicodeDecodeError:
            # Try with a different encoding if UTF-8 fails
            with open(filepath, "r", encoding="latin-1") as file:
                content = file.read()
        
        # Step 2: Find all image links in the format [[image.ext]]
        images = re.findall(r'\[\[([^]]*\.(png|jpg|jpeg|gif|webp))\]\]', content, re.IGNORECASE)
        
        # Step 3: Replace image links and ensure URLs are correctly formatted
        for image in images:
            image_name = image[0]  # Extract filename from tuple
            # Prepare the Markdown-compatible link with %20 replacing spaces
            markdown_image = f"![Image Description](/images/{image_name.replace(' ', '%20')})"
            content = content.replace(f"[[{image_name}]]", markdown_image)
            
            # Step 4: Copy the image to the Hugo static/images directory if it exists
            image_source = os.path.join(attachments_dir, image_name)
            if os.path.exists(image_source):
                try:
                    shutil.copy(image_source, static_images_dir)
                    print(f"Copied image: {image_name}")
                except Exception as e:
                    print(f"Failed to copy image {image_name}: {e}")
            else:
                print(f"Warning: Image not found: {image_source}")
        
        # Step 5: Write the updated content back to the markdown file
        try:
            with open(filepath, "w", encoding="utf-8") as file:
                file.write(content)
        except Exception as e:
            print(f"Failed to write file {filepath}: {e}")

print("Markdown files processed and images copied successfully.")
'@

# Write the Python script to a file
$pythonScriptContent | Out-File -FilePath "process_images.py" -Encoding UTF8

# Execute the Python script
try {
    & $pythonCommand process_images.py
    Write-Host "Image processing completed successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to process image links: $_"
    exit 1
}

# Step 6: Build the Hugo site
Write-Host "Building the Hugo site..." -ForegroundColor Cyan
try {
    hugo
    Write-Host "Hugo build completed successfully." -ForegroundColor Green
} catch {
    Write-Error "Hugo build failed: $_"
    exit 1
}

# Step 7: Add changes to Git
Write-Host "Staging changes for Git..." -ForegroundColor Cyan
$hasChanges = (git status --porcelain) -ne ""
if (-not $hasChanges) {
    Write-Host "No changes to stage." -ForegroundColor Yellow
} else {
    git add .
    Write-Host "Changes staged successfully." -ForegroundColor Green
}

# Step 8: Commit changes with a dynamic message
$commitMessage = "New Blog Post on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$hasStagedChanges = (git diff --cached --name-only) -ne ""
if (-not $hasStagedChanges) {
    Write-Host "No changes to commit." -ForegroundColor Yellow
} else {
    Write-Host "Committing changes..." -ForegroundColor Cyan
    try {
        git commit -m "$commitMessage"
        Write-Host "Changes committed successfully." -ForegroundColor Green
    } catch {
        Write-Error "Git commit failed: $_"
        exit 1
    }
}

# Step 9: Push all changes to the main branch
Write-Host "Deploying to GitHub Master..." -ForegroundColor Cyan
try {
    git push origin master
    Write-Host "Successfully pushed to master branch." -ForegroundColor Green
} catch {
    Write-Warning "Failed to push to Master branch: $_"
    Write-Host "Continuing with hostinger deployment..." -ForegroundColor Yellow
}

# Step 10: Push the public folder to the hostinger branch using subtree split and force push
Write-Host "Deploying to GitHub Hostinger..." -ForegroundColor Cyan

# Check if the temporary branch exists and delete it
$branchExists = git branch --list "hostinger-deploy"
if ($branchExists) {
    git branch -D hostinger-deploy
}

# Perform subtree split
try {
    git subtree split --prefix public -b hostinger-deploy
    Write-Host "Subtree split completed successfully." -ForegroundColor Green
} catch {
    Write-Error "Subtree split failed: $_"
    exit 1
}

# Push to hostinger branch with force
try {
    git push origin hostinger-deploy:hostinger --force
    Write-Host "Successfully deployed to hostinger branch." -ForegroundColor Green
} catch {
    Write-Error "Failed to push to hostinger branch: $_"
    git branch -D hostinger-deploy
    exit 1
}

# Delete the temporary branch
git branch -D hostinger-deploy

Write-Host "All done! Site synced, processed, committed, built, and deployed." -ForegroundColor Green

# Clean up temporary Python script
if (Test-Path "process_images.py") {
    Remove-Item "process_images.py" -Force
    Write-Host "Cleaned up temporary files." -ForegroundColor Green
}