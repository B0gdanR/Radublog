
```
import os
import re
import shutil

# Paths adapted for your environment
posts_dir = r"C:\Users\Radu\Documents\Radublog\content\post"
attachments_dir = r"D:\Blog\Obsidian\Tutorials"  # You may need to find the exact attachments folder
static_images_dir = r"C:\Users\Radu\Documents\Radublog\static\images"

# Ensure the static/images directory exists
os.makedirs(static_images_dir, exist_ok=True)

# Step 1: Process each markdown file in the posts directory
for filename in os.listdir(posts_dir):
    if filename.endswith(".md"):
        filepath = os.path.join(posts_dir, filename)
        
        with open(filepath, "r", encoding="utf-8") as file:
            content = file.read()
        
        # Step 2: Find all image links - updated to handle multiple formats
        images = re.findall(r'\[\[([^]]*\.(png|jpg|jpeg|gif|webp))\]\]', content, re.IGNORECASE)
        
        # Step 3: Replace image links and ensure URLs are correctly formatted
        for image_match in images:
            image = image_match[0]  # Get the full filename
            # Prepare the Markdown-compatible link with %20 replacing spaces
            markdown_image = f"![Image Description](/images/{image.replace(' ', '%20')})"
            content = content.replace(f"[[{image}]]", markdown_image)
            
            # Step 4: Search for the image in Obsidian directory (recursively)
            image_found = False
            for root, dirs, files in os.walk(attachments_dir):
                if image in files:
                    image_source = os.path.join(root, image)
                    shutil.copy(image_source, static_images_dir)
                    print(f"Copied: {image}")
                    image_found = True
                    break
            
            if not image_found:
                print(f"Warning: Image not found: {image}")
        
        # Step 5: Write the updated content back to the markdown file
        with open(filepath, "w", encoding="utf-8") as file:
            file.write(content)

print("Markdown files processed and images copied successfully.")
```

Location on my PC:

C:\Users\Radu\Documents\Radublog

![[Pasted image 20250910094310.png]]