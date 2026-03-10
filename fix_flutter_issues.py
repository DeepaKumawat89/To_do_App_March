import re
import os

files_to_check = [
    "lib/screens/add_edit_task_screen.dart",
    "lib/screens/home_screen.dart",
    "lib/screens/login_screen.dart",
    "lib/screens/profile_screen.dart",
    "lib/screens/signup_screen.dart",
    "lib/screens/splash_screen.dart",
    "lib/utils/app_theme.dart",
    "lib/widgets/custom_widgets.dart"
]

def fix_opacity(content):
    def replacer(match):
        opacity = float(match.group(1))
        alpha = int(255 * opacity)
        return f".withAlpha({alpha})"
    return re.sub(r'\.withOpacity\(([0-9.]+)\)', replacer, content)

def fix_consts(content):
    # we target known patterns: const EdgeInsets, const TextStyle, const SizedBox, const [, const BoxShadow, const BoxConstraints
    content = content.replace("const EdgeInsets", "EdgeInsets")
    content = content.replace("const TextStyle", "TextStyle")
    content = content.replace("const SizedBox", "SizedBox")
    content = content.replace("const [", "[")
    content = content.replace("const BoxShadow", "BoxShadow")
    content = content.replace("const BoxConstraints", "BoxConstraints")
    content = content.replace("const BorderRadius", "BorderRadius")
    content = content.replace("const Color(", "Color(")
    return content

for filepath in files_to_check:
    if not os.path.exists(filepath):
        continue
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Apply general fixes
    content = fix_opacity(content)
    # The analyze tool specifically shows const_eval_extension_method
    # The simplest fix is just to drop consts related to layouts if they contain .sp/.w/.h/.r
    # We will do a generic replacement for layout concepts that have screenutil usages.
    if "flutter_screenutil" in content or "const" in content:
        # A bit safer: only remove const if it's right before a layout widget or collection
        lines = content.split('\n')
        # We need to refine based on the exact compile error lines, but let's just do it broadly for the specific lines.
        # Wait, blindly removing all `const Color(` is bad.
        pass

# Let's use the explicit analyze.txt to target exact lines!
analyze_file = "analyze.txt"

if os.path.exists(analyze_file):
    with open(analyze_file, 'r', encoding='utf-8') as f:
        analyze_content = f.read()
        
    pattern = r'(info|error) - .*? - ([^:]+\.dart):(\d+):\d+ - (const_eval_extension_method|deprecated_member_use|use_build_context_synchronously)'
    matches = re.findall(pattern, analyze_content)
    
    file_fixes = {}
    for level, filepath, line, rule in matches:
        filepath = filepath.replace('\\', '/')
        if filepath not in file_fixes:
            file_fixes[filepath] = {"const": set(), "opacity": set(), "context": set()}
        
        line = int(line)
        if rule == "const_eval_extension_method":
            file_fixes[filepath]["const"].add(line)
        elif rule == "deprecated_member_use":
            file_fixes[filepath]["opacity"].add(line)
        elif rule == "use_build_context_synchronously":
            file_fixes[filepath]["context"].add(line)
            
    for filepath, fixes in file_fixes.items():
        if not os.path.exists(filepath):
            continue
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        for l in fixes["opacity"]:
            idx = l - 1
            if "withOpacity" in lines[idx]:
                lines[idx] = fix_opacity(lines[idx])
            elif "activeColor" in lines[idx]:
                lines[idx] = lines[idx].replace("activeColor", "activeThumbColor")
                
        for l in fixes["const"]:
            idx = l - 1
            # remove "const " starting from this line and moving up until we find it
            for i in range(idx, max(-1, idx-10), -1):
                if "const " in lines[i]:
                    lines[i] = lines[i].replace("const ", "")
                    break

        for l in fixes["context"]:
            idx = l - 1
            if "if (success && mounted)" in lines[idx] or "if (mounted)" in lines[idx]:
                # it's a false positive or we need to separate the mounted check
                if "if (success && mounted)" in lines[idx]:
                    lines[idx] = lines[idx].replace("if (success && mounted)", "if (!mounted) return;\nif (success)")
            else:
                lines[idx] = "if (!context.mounted) return;\n" + lines[idx]
                
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(lines)
