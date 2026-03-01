#!/usr/bin/env python3
"""Generate README.md from directory structure of markdown files."""

import os
import re
import urllib.parse
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
SKIP_DIRS = {".git", ".github", ".vscode", "packages", "node_modules"}
SKIP_FILES = {"README.md", "LICENSE"}


def url_encode_path(path: str) -> str:
    parts = path.split("/")
    return "/".join(urllib.parse.quote(p) for p in parts)


def display_name(filepath: Path) -> str:
    return filepath.stem


def make_anchor(name: str) -> str:
    anchor = name.lower()
    anchor = re.sub(r"[^\w\s가-힣-]", "", anchor)
    anchor = re.sub(r"\s+", "-", anchor.strip())
    return anchor


def scan_tree(root: Path):
    categories = {}
    for entry in sorted(root.iterdir(), key=lambda e: e.name.lower()):
        if entry.name in SKIP_DIRS or not entry.is_dir():
            continue
        cat = {"files": [], "subcats": {}}
        for item in sorted(entry.iterdir(), key=lambda e: e.name.lower()):
            if item.is_file() and item.suffix == ".md" and item.name not in SKIP_FILES:
                cat["files"].append(item)
            elif item.is_dir() and item.name not in SKIP_DIRS:
                subfiles = sorted(
                    [f for f in item.iterdir() if f.is_file() and f.suffix == ".md" and f.name not in SKIP_FILES],
                    key=lambda e: e.name.lower(),
                )
                if subfiles:
                    cat["subcats"][item.name] = subfiles
        if cat["files"] or cat["subcats"]:
            categories[entry.name] = cat
    return categories


def generate_readme(categories: dict) -> str:
    lines = [
        "# devwiki",
        "",
        "개발에 관련된 메모를 적어둡니다.",
        "",
        "---",
        "",
        "<!-- sitemap start -->",
        "",
        "## Categories",
        "",
    ]
    for cat_name, cat_data in categories.items():
        lines.append(f"* [{cat_name}](#{make_anchor(cat_name)})")
        for sub_name in cat_data["subcats"]:
            lines.append(f"  * [{sub_name}](#{make_anchor(sub_name)})")
    lines.append("")
    lines.append("---")
    for cat_name, cat_data in categories.items():
        lines.append("")
        lines.append(f"### {cat_name}")
        lines.append("")
        for f in cat_data["files"]:
            rel = f.relative_to(REPO_ROOT)
            name = display_name(f)
            lines.append(f"- [{name}]({url_encode_path(str(rel))})")
        for sub_name, sub_files in cat_data["subcats"].items():
            lines.append("")
            lines.append(f"#### {sub_name}")
            lines.append("")
            for f in sub_files:
                rel = f.relative_to(REPO_ROOT)
                name = display_name(f)
                lines.append(f"- [{name}]({url_encode_path(str(rel))})")
    lines.append("")
    lines.append("<!-- sitemap end -->")
    lines.append("")
    return "\n".join(lines)


def main():
    categories = scan_tree(REPO_ROOT)
    readme = generate_readme(categories)
    (REPO_ROOT / "README.md").write_text(readme, encoding="utf-8")
    print(f"README.md generated with {len(categories)} categories.")


if __name__ == "__main__":
    main()
