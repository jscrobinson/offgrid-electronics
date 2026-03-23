#!/usr/bin/env python3
"""Verify the HTML build output is complete and valid."""
import sys
from pathlib import Path

BUILD_DIR = Path("build/html")
DOCS_DIR = Path("docs")


def main():
    errors = []

    # Check build directory exists
    if not BUILD_DIR.exists():
        print("FAIL: build/html/ does not exist. Run 'make html' first.")
        sys.exit(1)

    # Check index.html exists
    index = BUILD_DIR / "index.html"
    if not index.exists():
        errors.append("build/html/index.html is missing")
    elif index.stat().st_size < 1000:
        errors.append(f"build/html/index.html is too small ({index.stat().st_size} bytes)")

    # Check search index exists
    search_index = BUILD_DIR / "search-index.json"
    if not search_index.exists():
        errors.append("build/html/search-index.json is missing")

    search_js = BUILD_DIR / "search.js"
    if not search_js.exists():
        errors.append("build/html/search.js is missing")

    # Check every markdown file has a corresponding HTML file
    md_files = sorted(DOCS_DIR.rglob("*.md"))
    missing_html = []
    for md in md_files:
        relative = md.relative_to(DOCS_DIR)
        html_path = BUILD_DIR / relative.with_suffix(".html")
        if not html_path.exists():
            missing_html.append(str(relative))

    if missing_html:
        errors.append(
            f"{len(missing_html)} markdown files have no HTML counterpart:\n"
            + "\n".join(f"    - {m}" for m in missing_html[:10])
            + (f"\n    ... and {len(missing_html) - 10} more" if len(missing_html) > 10 else "")
        )

    # Check HTML files aren't empty
    html_files = sorted(BUILD_DIR.rglob("*.html"))
    empty_html = [str(h) for h in html_files if h.stat().st_size < 500]
    if empty_html:
        errors.append(
            f"{len(empty_html)} HTML files appear empty (<500 bytes):\n"
            + "\n".join(f"    - {e}" for e in empty_html[:5])
        )

    # Check HTML files contain expected structure
    sample_file = BUILD_DIR / "hardware" / "lora" / "lilygo-tbeam-v1.2.html"
    if sample_file.exists():
        content = sample_file.read_text(encoding="utf-8", errors="replace")
        for expected in ["<!DOCTYPE html>", "<nav", "sidebar", "</html>"]:
            if expected not in content:
                errors.append(f"Sample HTML missing expected element: {expected}")

    if errors:
        print(f"FAIL: {len(errors)} error(s) in HTML build:")
        for e in errors:
            print(f"  - {e}")
        sys.exit(1)

    print(f"OK: HTML build verified — {len(html_files)} HTML files, index + search present.")


if __name__ == "__main__":
    main()
