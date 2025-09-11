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
