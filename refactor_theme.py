
import os
import re

lib_dir = r"c:\Users\LENOVO\AndroidStudioProjects\moodify\lib"

def process_file(filepath):
    if "app_theme.dart" in filepath.replace("\\\\", "/"):
        return
        
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Step 1: Replace AppColors with context.colors
    content = re.sub(r"AppColors\.([a-zA-Z0-9_]+)", r"context.colors.\1", content)

    # Step 2: Remove isolated const keywords to prevent compiler errors from now-dynamic values.
    # The dart linter + fix will restore them where possible.
    # We match "const " but we make sure we do not destroy const constructors if they are entirely static,
    # Actually, removing all "const " is an imperfect sledgehammer but extremely effective.
    # A bit surgical: remove "const " if followed by uppercase (Widget constructor) or [ or {
    content = re.sub(r"\bconst\s+([A-Z\[\{])", r"\1", content)
    
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)

for root, dirs, files in os.walk(lib_dir):
    for filename in files:
        if filename.endswith(".dart"):
            process_file(os.path.join(root, filename))

