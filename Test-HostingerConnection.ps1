# Simple test to verify if Hostinger Git automation works
# This creates a test file and pushes only to hostinger branch

$ErrorActionPreference = "Stop"
Set-Location "C:\Users\Radu\Documents\Radublog"

Write-Host "🧪 Testing Hostinger Git Connection" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Create a simple test file in public folder
$testFileName = "hostinger-test-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
$testContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Hostinger Git Test</title>
</head>
<body>
    <h1>🧪 Git Automation Test</h1>
    <p>If you see this file, Hostinger Git automation is working!</p>
    <p>Test created: $(Get-Date)</p>
</body>
</html>
"@

Write-Host "📄 Creating test file: $testFileName" -ForegroundColor Yellow
$testContent | Out-File -FilePath "public\$testFileName" -Encoding UTF8

# Add and commit the test file to master
Write-Host "💾 Committing test file to master..." -ForegroundColor Yellow
git add .
git commit -m "🧪 Test Hostinger Git automation - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

# Push to hostinger branch using subtree split
Write-Host "🚀 Pushing test to hostinger branch..." -ForegroundColor Yellow

# Clean up any existing temp branch
$branchExists = git branch --list "test-hostinger"
if ($branchExists) {
    git branch -D test-hostinger
}

# Create subtree split and push to hostinger
git subtree split --prefix public -b test-hostinger
git push origin test-hostinger:hostinger --force
git branch -D test-hostinger

Write-Host "✅ Test file pushed to GitHub hostinger branch!" -ForegroundColor Green
Write-Host "" -ForegroundColor White
Write-Host "🔍 NOW CHECK THESE:" -ForegroundColor Magenta
Write-Host "1. GitHub webhook deliveries (should show new entry)" -ForegroundColor White
Write-Host "2. Hostinger File Manager (look for $testFileName)" -ForegroundColor White  
Write-Host "3. Your website: https://yourdomain.com/$testFileName" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "⏱️ Wait 2-3 minutes for auto-deployment..." -ForegroundColor Yellow

# Give user time to check
Read-Host "Press Enter when you've checked Hostinger File Manager..."

# Clean up - remove test file and push again
Write-Host "🧹 Cleaning up test file..." -ForegroundColor Yellow
Remove-Item "public\$testFileName" -Force
git add .
git commit -m "🧹 Remove test file"

# Push cleanup to hostinger branch
git subtree split --prefix public -b cleanup-test
git push origin cleanup-test:hostinger --force  
git branch -D cleanup-test

Write-Host "✅ Test completed and cleaned up!" -ForegroundColor Green