import os
import re
import shutil

# Your specific paths
posts_dir = r"C:\Users\Radu\Documents\Radublog\content\posts"
obsidian_attachments = r"D:\Blog\Obsidian\Tutorials\Personal\Images"
hugo_static_images = r"C:\Users\Radu\Documents\Radublog\static\images"

# Create images directory if it doesn't exist
os.makedirs(hugo_static_images, exist_ok=True)

print("Processing markdown files for images...")

# Process each markdown file
for filename in os.listdir(posts_dir):
    if filename.endswith(".md"):
        filepath = os.path.join(posts_dir, filename)
        
        with open(filepath, "r", encoding="utf-8") as file:
            content = file.read()
        
        # Find Obsidian-style image links: ![[image.jpg]]
        obsidian_images = re.findall(r'!\[\[([^\]]+\.(png|jpg|jpeg|gif|bmp|webp|svg))\]\]', content, re.IGNORECASE)
        
        if obsidian_images:
            print(f"\nProcessing {filename}...")
            
            for image_name, _ in obsidian_images:
                # Source: Obsidian attachments
                source_path = os.path.join(obsidian_attachments, image_name)
                
                # Destination: Hugo static/images
                dest_path = os.path.join(hugo_static_images, image_name)
                
                # Copy image if it exists
                if os.path.exists(source_path):
                    shutil.copy2(source_path, dest_path)
                    print(f"  ✓ Copied {image_name}")
                    
                    # Replace Obsidian syntax with Hugo syntax
                    old_syntax = f"![[{image_name}]]"
                    new_syntax = f"![{image_name}](/{image_name})"
                    content = content.replace(old_syntax, new_syntax)
                else:
                    print(f"  ✗ Image not found: {image_name}")
            
            # Write updated content back to file
            with open(filepath, "w", encoding="utf-8") as file:
                file.write(content)

print("\n✅ Image processing complete!")