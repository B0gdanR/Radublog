import os
import re

posts_dir = r"C:\Users\Radu\Documents\Radublog\content\post"

for filename in os.listdir(posts_dir):
    if filename.endswith(".md"):
        filepath = os.path.join(posts_dir, filename)
        print(f"Processing: {filename}")
        
        with open(filepath, "r", encoding="utf-8") as file:
            content = file.read()
        
        # Debug: Show what we're looking for
        obsidian_images = re.findall(r'!\[\[([^]]+\.(?:png|jpg|jpeg|gif|webp))\]\]', content, re.IGNORECASE)
        if obsidian_images:
            print(f"Found images: {obsidian_images}")
        
        # Replace Obsidian image syntax with Hugo markdown
        original_content = content
        content = re.sub(r'!\[\[([^]]+\.(?:png|jpg|jpeg|gif|webp))\]\]', 
                        r'![Image](/images/\1)', content, flags=re.IGNORECASE)
        
        if content != original_content:
            with open(filepath, "w", encoding="utf-8") as file:
                file.write(content)
            print(f"✓ Updated images in: {filename}")
        else:
            print(f"- No changes needed in: {filename}")