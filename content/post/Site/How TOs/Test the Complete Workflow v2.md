## Deploy Your Hugo Site to Hostinger

### 1. Stop your local Hugo server

Press Ctrl+C in your PowerShell window to stop hugo server

### 2. Build production site

cd "C:\Users\Radu\Documents\Radublog"
**hugo --minify**

### 3. Access Hostinger File Manager

- Log into your Hostinger control panel
- Open File Manager
- Navigate to public_html folder (NOT the public folder)

### 4. Clear existing files

- Select all files/folders inside public_html
- Delete everything

### 5. Upload your site

- Go to your local folder: *C:\Users\Radu\Documents\Radublog\public\*
- Select ALL files and folders inside this public folder
- Upload them directly into **public_html** (so index.html is directly in public_html)

### 6. Wait and test

Wait 2-3 minutes for files to process
Visit https://halfoncloud.com/
Your customized site should now be live


## Clarify the exact workflow commands:

### 1) Local Testing/Development:


**hugo server -D --disableFastRender**

- Use this when you want to preview changes locally
- The -D flag includes draft posts (posts with draft: true)
- This runs continuously until you stop it with Ctrl+C
- Files are served from memory, not written to disk

### 2) Production Build for Publishing:

**hugo --minify**

- Use this ONLY when you have changes ready to publish
- This writes final files to your public folder
- These are the files you upload to Hostinger

### Workflow Clarification:

You don't need to run hugo --minify every single time you test locally. The typical workflow is:

1. Make changes to your content/templates
2. Test locally with hugo server -D --disableFastRender
3. When satisfied with changes, run hugo --minify
4. Upload the updated public folder contents to Hostinger

**One correction**: If you don't want to see draft posts in your local testing, use **hugo server --disableFastRender** (without the -D flag).

