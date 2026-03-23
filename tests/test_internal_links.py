#!/usr/bin/env python3
"""Check for broken internal links between markdown docs."""
import re
import sys
from pathlib import Path

DOCS_DIR = Path("docs")
MD_LINK = re.compile(r'\[([^\]]*)\]\(([^)]+)\)')


def main():
    broken = []
    checked = 0

    for md_file in sorted(DOCS_DIR.rglob("*.md")):
        content = md_file.read_text(encoding="utf-8", errors="replace")
        for match in MD_LINK.finditer(content):
            text, target = match.group(1), match.group(2)

            # Skip external links, anchors, and non-md links
            if target.startswith(("http://", "https://", "#", "mailto:")):
                continue
            if not target.endswith(".md") and "#" not in target:
                continue

            # Strip anchor
            target_path = target.split("#")[0]
            if not target_path:
                continue

            # Resolve relative to the file's directory
            resolved = (md_file.parent / target_path).resolve()
            checked += 1

            if not resolved.exists():
                broken.append({
                    "file": str(md_file),
                    "link": target,
                    "text": text,
                    "resolved": str(resolved),
                })

    if broken:
        print(f"FAIL: {len(broken)} broken internal link(s) found:")
        for b in broken:
            print(f"  {b['file']}: [{b['text']}]({b['link']})")
            print(f"    -> {b['resolved']}")
        sys.exit(1)

    print(f"OK: {checked} internal links checked, none broken.")


if __name__ == "__main__":
    main()
