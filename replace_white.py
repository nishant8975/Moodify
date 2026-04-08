
import os
import re

lib_dir = r"c:\Users\LENOVO\AndroidStudioProjects\moodify\lib"

def process_file(filepath):
    if "app_theme.dart" in filepath.replace("\\\\", "/"):
        return
        
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    content = content.replace("Colors.white70", "context.colors.onSurface.withOpacity(0.7)")
    content = content.replace("Colors.white60", "context.colors.onSurface.withOpacity(0.6)")
    content = content.replace("Colors.white54", "context.colors.onSurface.withOpacity(0.54)")
    content = content.replace("Colors.white38", "context.colors.onSurface.withOpacity(0.38)")
    content = content.replace("Colors.white30", "context.colors.onSurface.withOpacity(0.3)")
    content = content.replace("Colors.white24", "context.colors.onSurface.withOpacity(0.24)")
    content = content.replace("Colors.white12", "context.colors.onSurface.withOpacity(0.12)")
    content = content.replace("Colors.white10", "context.colors.onSurface.withOpacity(0.1)")
    
    content = re.sub(r"Colors\.white\b", r"context.colors.onSurface", content)
    
    content = content.replace("Colors.black87", "context.colors.inverseSurface.withOpacity(0.87)")
    content = content.replace("Colors.black54", "context.colors.inverseSurface.withOpacity(0.54)")
    content = content.replace("Colors.black45", "context.colors.inverseSurface.withOpacity(0.45)")
    content = content.replace("Colors.black38", "context.colors.inverseSurface.withOpacity(0.38)")
    content = content.replace("Colors.black26", "context.colors.inverseSurface.withOpacity(0.26)")
    content = content.replace("Colors.black12", "context.colors.inverseSurface.withOpacity(0.12)")
    content = re.sub(r"Colors\.black\b", r"context.colors.inverseSurface", content)

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)

for root, dirs, files in os.walk(lib_dir):
    for filename in files:
        if filename.endswith(".dart"):
            process_file(os.path.join(root, filename))

