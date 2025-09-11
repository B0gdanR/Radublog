import os
import re
import shutil

# Paths
posts_dir = r"C:\Users\Radu\Documents\Radublog\content\post"
attachments_dir = r"D:\Blog\Obsidian\Tutorials\Personal\Images"
static_images_dir = r"C:\Users\Radu\Documents\Radublog\static\images"

print("=== DEBUGGING IMAGE PROCESSING ===")
print(f"Posts dir exists: {os.path.exists(posts_dir)}")
print(f"Attachments dir exists: {os.path.exists(attachments_dir)}")
print(f"Static images dir exists: {os.path.exists(static_images_dir)}")

# Ensure the static images directory exists
os.makedirs(static_images_dir, exist_ok=True)

# Process the specific file
filename = "This is my Second blog post.md"
filepath = os.path.join(posts_dir, filename)

print(f"\nProcessing: {filename}")
print(f"File exists: {os.path.exists(filepath)}")

with open(filepath, "r", encoding="utf-8") as file:
    content = file.read()

print(f"Original content length: {len(content)}")

# Find images
images = re.findall(r'\[\[([^]]*\.(png|jpg|jpeg|gif|webp))\]\]', content, re.IGNORECASE)
print(f"Found images: {images}")

for image in images:
    image_name = image[0]  # Extract filename from tuple
    print(f"\nProcessing image: {image_name}")
    
    # Check source
    image_source = os.path.join(attachments_dir, image_name)
    print(f"Source exists: {os.path.exists(image_source)}")
    
    # Prepare markdown link
    markdown_image = f"![Image Description](/images/{image_name.replace(' ', '%20')})"
    print(f"New markdown: {markdown_image}")
    
    # Replace in content
    old_link = f"[[{image_name}]]"
    print(f"Replacing: {old_link}")
    content = content.replace(old_link, markdown_image)
    
    # Copy image
    if os.path.exists(image_source):
        try:
            shutil.copy(image_source, static_images_dir)
            print(f"✅ Copied {image_name}")
        except Exception as e:
            print(f"❌ Copy failed: {e}")
    else:
        print(f"❌ Source image not found: {image_source}")

print(f"\nFinal content length: {len(content)}")
print("Content preview after changes:")
print(content[400:600])

# Write back
with open(filepath, "w", encoding="utf-8") as file:
    file.write(content)

print("✅ File updated")
