import os
import re

# Test file
test_file = r"C:\Users\Radu\Documents\Radublog\content\post\This is my Second blog post.md"
source_dir = r"D:\Blog\Obsidian\Tutorials\Personal\Images"

print("Testing file:", test_file)
print("Source dir exists:", os.path.exists(source_dir))

with open(test_file, "r", encoding="utf-8") as file:
    content = file.read()

print("File content preview:")
print(content[:200])

# Test the regex
images = re.findall(r'\[\[([^]]*\.(png|jpg|jpeg|gif|webp))\]\]', content, re.IGNORECASE)
print("Found images:", images)

# Check if specific image exists
test_image = "CM_LAB_Part2_0181.jpg"
image_path = os.path.join(source_dir, test_image)
print(f"Image {test_image} exists:", os.path.exists(image_path))
