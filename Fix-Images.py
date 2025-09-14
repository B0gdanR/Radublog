import os
import re

posts_dir = r"C:\Users\Radu\Documents\Radublog\content\post"

for filename in os.listdir(posts_dir):
    if filename.endswith(".md"):
        filepath = os.path.join(posts_dir, filename)
        
        with open(filepath, "r", encoding="utf-8") as file:
            content = file.read()
        
        # Fix the broken image syntax - replace spaces with %20
        content = re.sub(r'!\[Image\]\(/images/([^)]*)\)', 
                        lambda m: f'![Image](/images/{m.group(1).replace(" ", "%20")})', 
                        content)
        
        with open(filepath, "w", encoding="utf-8") as file:
            file.write(content)
        print(f"Fixed: {filename}")