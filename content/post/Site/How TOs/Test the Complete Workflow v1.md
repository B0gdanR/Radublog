

**Step 1**: Sync from Obsidian

cd C:\Users\Radu\Documents\Radublog
.\sync-obsidian.ps1


**Step 2**: Build and commit
##### Build the updated site
hugo --minify
##### Commit and push to GitHub
git add .
git commit -m "Add second blog post about SCCM"
git push

**Step 3**: Test the webhook
Since you set up the GitHub webhook, pushing should trigger **Hostinger** to pull the latest changes. However, this will only update the source files on the server, not the built website.

**Step 4**: Deploy the built site
You'll still need to upload the new public folder contents to *public_html* to see the second post live.

This workflow tests:

Obsidian → Hugo sync ✅
Git automation ✅
Hugo building ✅

Note: The only manual step remaining is uploading the built files

