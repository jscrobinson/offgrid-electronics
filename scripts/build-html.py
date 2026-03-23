#!/usr/bin/env python3
"""
build-html.py — Convert docs/*.md to a static HTML documentation site.

No external dependencies — stdlib only.
Outputs to build/html/ with full navigation, search, and offline support.
"""

import os
import re
import json
import html
import shutil
import sys
from pathlib import Path
from collections import OrderedDict

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
PROJECT_ROOT = Path(__file__).resolve().parent.parent
DOCS_DIR = PROJECT_ROOT / "docs"
BUILD_DIR = PROJECT_ROOT / "build" / "html"
SEARCH_INDEX_FILE = BUILD_DIR / "search-index.json"

COLORS = {
    "bg": "#1a1a2e",
    "bg_card": "#16213e",
    "bg_sidebar": "#111827",
    "bg_code": "#0a0a1a",
    "text": "#e0e0e0",
    "text_dim": "#888",
    "accent": "#00d4ff",
    "accent2": "#7fdbca",
    "border": "#333",
    "link": "#00d4ff",
    "tip_bg": "#1a2a1a",
    "tip_border": "#4caf50",
    "warn_bg": "#2a2a1a",
    "warn_border": "#ff9800",
}

# Section display names for sidebar grouping (directory name -> display name)
SECTION_NAMES = {
    "hardware": "Hardware",
    "lora": "LoRa Devices",
    "esp32": "ESP32",
    "arduino": "Arduino",
    "raspberry-pi": "Raspberry Pi",
    "displays": "Displays",
    "peripherals": "Peripherals",
    "electronics": "Electronics",
    "power": "Power Systems",
    "radio": "Radio",
    "sdr": "Software Defined Radio",
    "mesh-networking": "Mesh Networking",
    "protocols": "Communication Protocols",
    "programming": "Programming",
    "networking": "Networking",
    "survival": "Survival / Field",
}

# ---------------------------------------------------------------------------
# Markdown Parser
# ---------------------------------------------------------------------------

def escape(text):
    """HTML-escape text but preserve already-processed HTML."""
    return html.escape(text, quote=False)


class MarkdownParser:
    """Minimal Markdown to HTML converter — stdlib only."""

    def __init__(self, current_file_rel=None):
        """current_file_rel: path relative to docs dir, e.g. 'hardware/lora/overview.md'"""
        self.current_file_rel = current_file_rel or ""
        self.toc = []  # list of (level, id, text) for h2/h3

    def _rewrite_link(self, href):
        """Rewrite .md links to .html, preserving relative paths."""
        if href.startswith(("http://", "https://", "mailto:", "#")):
            return href
        # Handle .md -> .html
        if href.endswith(".md"):
            href = href[:-3] + ".html"
        elif ".md#" in href:
            href = href.replace(".md#", ".html#")
        return href

    def _make_id(self, text):
        """Generate an anchor id from header text."""
        slug = text.lower().strip()
        slug = re.sub(r'[^\w\s-]', '', slug)
        slug = re.sub(r'[\s]+', '-', slug)
        slug = re.sub(r'-+', '-', slug).strip('-')
        return slug

    def _parse_inline(self, text):
        """Process inline markdown: bold, italic, code, links, images."""
        # Inline code first (to protect contents)
        parts = []
        code_split = re.split(r'(`[^`]+`)', text)
        for i, segment in enumerate(code_split):
            if i % 2 == 1:
                # This is inline code
                inner = segment[1:-1]
                parts.append(f'<code>{escape(inner)}</code>')
            else:
                parts.append(self._parse_inline_no_code(segment))
        return ''.join(parts)

    def _parse_inline_no_code(self, text):
        """Inline markdown without code spans."""
        # Images: ![alt](src)
        text = re.sub(
            r'!\[([^\]]*)\]\(([^)]+)\)',
            lambda m: f'<img src="{escape(m.group(2))}" alt="{escape(m.group(1))}" style="max-width:100%">',
            text
        )
        # Links: [text](url)
        text = re.sub(
            r'\[([^\]]+)\]\(([^)]+)\)',
            lambda m: f'<a href="{self._rewrite_link(m.group(2))}">{m.group(1)}</a>',
            text
        )
        # Bold+Italic: ***text*** or ___text___
        text = re.sub(r'\*\*\*(.+?)\*\*\*', r'<strong><em>\1</em></strong>', text)
        text = re.sub(r'___(.+?)___', r'<strong><em>\1</em></strong>', text)
        # Bold: **text** or __text__
        text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
        text = re.sub(r'__(.+?)__', r'<strong>\1</strong>', text)
        # Italic: *text* or _text_ (but not inside words for underscore)
        text = re.sub(r'\*(.+?)\*', r'<em>\1</em>', text)
        text = re.sub(r'(?<!\w)_(.+?)_(?!\w)', r'<em>\1</em>', text)
        return text

    def parse(self, md_text):
        """Convert markdown text to HTML. Returns (html_str, toc_list)."""
        self.toc = []
        lines = md_text.split('\n')
        out = []
        i = 0
        n = len(lines)

        while i < n:
            line = lines[i]

            # Fenced code blocks
            m = re.match(r'^```(\w*)', line)
            if m:
                lang = m.group(1)
                code_lines = []
                i += 1
                while i < n and not lines[i].startswith('```'):
                    code_lines.append(lines[i])
                    i += 1
                i += 1  # skip closing ```
                lang_attr = f' class="language-{lang}"' if lang else ''
                code_html = escape('\n'.join(code_lines))
                out.append(f'<pre><code{lang_attr}>{code_html}</code></pre>')
                continue

            # Horizontal rule
            if re.match(r'^---+\s*$', line) or re.match(r'^\*\*\*+\s*$', line):
                out.append('<hr>')
                i += 1
                continue

            # Headers
            m = re.match(r'^(#{1,6})\s+(.+)$', line)
            if m:
                level = len(m.group(1))
                text = m.group(2).strip()
                anchor = self._make_id(text)
                inline_html = self._parse_inline(text)
                if level in (2, 3):
                    self.toc.append((level, anchor, text))
                out.append(f'<h{level} id="{anchor}">{inline_html}</h{level}>')
                i += 1
                continue

            # Table
            if '|' in line and i + 1 < n and re.match(r'^[\s|:-]+$', lines[i + 1]):
                table_lines = []
                while i < n and '|' in lines[i]:
                    table_lines.append(lines[i])
                    i += 1
                out.append(self._parse_table(table_lines))
                continue

            # Blockquote
            if line.startswith('>'):
                bq_lines = []
                while i < n and (lines[i].startswith('>') or (lines[i].strip() and bq_lines)):
                    if lines[i].startswith('>'):
                        bq_lines.append(re.sub(r'^>\s?', '', lines[i]))
                    else:
                        # continuation line
                        if lines[i].strip():
                            bq_lines.append(lines[i])
                        else:
                            break
                    i += 1
                inner = self._parse_inline('\n'.join(bq_lines))
                out.append(f'<blockquote><p>{inner}</p></blockquote>')
                continue

            # Unordered list
            if re.match(r'^(\s*)[*+-]\s', line):
                list_html, i = self._parse_list(lines, i, ordered=False)
                out.append(list_html)
                continue

            # Ordered list
            if re.match(r'^(\s*)\d+\.\s', line):
                list_html, i = self._parse_list(lines, i, ordered=True)
                out.append(list_html)
                continue

            # Blank line
            if not line.strip():
                i += 1
                continue

            # Paragraph — gather consecutive non-blank, non-special lines
            para_lines = []
            while i < n and lines[i].strip():
                l = lines[i]
                # Check if the next line starts something special
                if (re.match(r'^#{1,6}\s', l) or
                    re.match(r'^```', l) or
                    re.match(r'^---+\s*$', l) or
                    re.match(r'^\*\*\*+\s*$', l) or
                    re.match(r'^>\s', l) or
                    (re.match(r'^(\s*)[*+-]\s', l) and not para_lines) or
                    (re.match(r'^(\s*)\d+\.\s', l) and not para_lines)):
                    if not para_lines:
                        # This special line will be handled in the next iteration
                        break
                    break
                para_lines.append(l)
                i += 1
            if para_lines:
                inner = self._parse_inline('<br>\n'.join(para_lines))
                out.append(f'<p>{inner}</p>')
            else:
                i += 1

        return '\n'.join(out), self.toc

    def _parse_table(self, table_lines):
        """Parse a markdown table into HTML."""
        if len(table_lines) < 2:
            return ''
        # Header row
        headers = [c.strip() for c in table_lines[0].strip().strip('|').split('|')]
        # Alignment row (line 1)
        align_cells = [c.strip() for c in table_lines[1].strip().strip('|').split('|')]
        aligns = []
        for cell in align_cells:
            if cell.startswith(':') and cell.endswith(':'):
                aligns.append('center')
            elif cell.endswith(':'):
                aligns.append('right')
            elif cell.startswith(':'):
                aligns.append('left')
            else:
                aligns.append('')

        html_parts = ['<div class="table-wrap"><table>', '<thead><tr>']
        for j, h in enumerate(headers):
            align = f' style="text-align:{aligns[j]}"' if j < len(aligns) and aligns[j] else ''
            html_parts.append(f'<th{align}>{self._parse_inline(h)}</th>')
        html_parts.append('</tr></thead><tbody>')

        for row_line in table_lines[2:]:
            cells = [c.strip() for c in row_line.strip().strip('|').split('|')]
            html_parts.append('<tr>')
            for j, cell in enumerate(cells):
                align = f' style="text-align:{aligns[j]}"' if j < len(aligns) and aligns[j] else ''
                html_parts.append(f'<td{align}>{self._parse_inline(cell)}</td>')
            html_parts.append('</tr>')

        html_parts.append('</tbody></table></div>')
        return ''.join(html_parts)

    def _parse_list(self, lines, i, ordered=False):
        """Parse a list (ordered or unordered), handling nesting."""
        n = len(lines)
        tag = 'ol' if ordered else 'ul'
        items = []
        # Determine base indent
        if ordered:
            m = re.match(r'^(\s*)\d+\.\s', lines[i])
        else:
            m = re.match(r'^(\s*)[*+-]\s', lines[i])
        base_indent = len(m.group(1)) if m else 0

        while i < n:
            line = lines[i]
            if not line.strip():
                # Blank line might end the list or separate items
                # Check if next non-blank line continues the list
                j = i + 1
                while j < n and not lines[j].strip():
                    j += 1
                if j < n:
                    next_line = lines[j]
                    if ordered:
                        nm = re.match(r'^(\s*)\d+\.\s', next_line)
                    else:
                        nm = re.match(r'^(\s*)[*+-]\s', next_line)
                    if nm and len(nm.group(1)) >= base_indent:
                        i = j
                        continue
                break

            # Check for list item at this level
            if ordered:
                m = re.match(r'^(\s*)\d+\.\s(.*)$', line)
            else:
                m = re.match(r'^(\s*)[*+-]\s(.*)$', line)

            if m:
                indent = len(m.group(1))
                if indent < base_indent:
                    break
                if indent > base_indent:
                    # Nested list
                    sub_html, i = self._parse_list(lines, i, ordered=bool(re.match(r'^\s*\d+\.', line)))
                    if items:
                        items[-1] += sub_html
                    else:
                        items.append(sub_html)
                    continue
                # Same level item
                items.append(self._parse_inline(m.group(2)))
                i += 1
            else:
                # Continuation line or different element
                break

        result = f'<{tag}>'
        for item in items:
            result += f'<li>{item}</li>'
        result += f'</{tag}>'
        return result, i


# ---------------------------------------------------------------------------
# Navigation Tree
# ---------------------------------------------------------------------------

def build_nav_tree(md_files):
    """Build a nested dict representing the docs/ directory structure.

    Returns list of (section_name, children) where children are either
    (file_rel_path, title) or (subsection_name, sub_children).
    """
    tree = OrderedDict()

    for rel_path in sorted(md_files.keys()):
        parts = Path(rel_path).parts
        if len(parts) == 1:
            # Root-level file like index.md
            continue
        current = tree
        for part in parts[:-1]:
            if part not in current:
                current[part] = OrderedDict()
            current = current[part]
        filename = parts[-1]
        title = md_files[rel_path].get("title", filename.replace(".md", "").replace("-", " ").title())
        current[filename] = (rel_path, title)

    return tree


def render_nav_html(tree, current_page_rel, depth=0):
    """Render nav tree to HTML for sidebar."""
    html_parts = []
    for key, value in tree.items():
        if isinstance(value, tuple):
            # Leaf: (rel_path, title)
            rel_path, title = value
            html_path = rel_path.replace('.md', '.html')
            active = ' class="active"' if rel_path == current_page_rel else ''
            html_parts.append(f'<li><a href="{{{{ROOT}}}}/{html_path}"{active}>{escape(title)}</a></li>')
        elif isinstance(value, OrderedDict):
            # Directory
            display = SECTION_NAMES.get(key, key.replace("-", " ").title())
            html_parts.append(f'<li class="nav-section"><details{"" if depth > 0 else " open"}>')
            html_parts.append(f'<summary>{escape(display)}</summary>')
            html_parts.append('<ul>')
            html_parts.append(render_nav_html(value, current_page_rel, depth + 1))
            html_parts.append('</ul></details></li>')
    return '\n'.join(html_parts)


def get_flat_page_list(md_files):
    """Return ordered list of (rel_path, title) for prev/next navigation."""
    pages = []
    # index first
    for rp in sorted(md_files.keys()):
        if rp == "index.md":
            pages.append((rp, md_files[rp].get("title", "Home")))
    for rp in sorted(md_files.keys()):
        if rp != "index.md":
            pages.append((rp, md_files[rp].get("title", rp)))
    return pages


# ---------------------------------------------------------------------------
# HTML Template
# ---------------------------------------------------------------------------

CSS = """
* { margin: 0; padding: 0; box-sizing: border-box; }
html { scroll-behavior: smooth; }
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    line-height: 1.7; color: %(text)s; background: %(bg)s;
    display: flex; min-height: 100vh;
}
a { color: %(link)s; text-decoration: none; }
a:hover { text-decoration: underline; }

/* Sidebar */
.sidebar {
    width: 280px; min-width: 280px; background: %(bg_sidebar)s;
    border-right: 1px solid %(border)s; padding: 20px 0;
    overflow-y: auto; position: fixed; top: 0; bottom: 0; left: 0;
    z-index: 100;
}
.sidebar-header { padding: 0 20px 15px; border-bottom: 1px solid %(border)s; margin-bottom: 10px; }
.sidebar-header h2 { color: %(accent)s; font-size: 1.1em; }
.sidebar-header a { color: %(accent)s; }
.sidebar-header p { color: %(text_dim)s; font-size: 0.8em; }
.sidebar nav ul { list-style: none; padding-left: 0; }
.sidebar nav > ul > li { margin: 0; }
.sidebar nav ul li a {
    display: block; padding: 4px 20px; color: %(text)s; font-size: 0.88em;
    border-left: 3px solid transparent; transition: all 0.15s;
}
.sidebar nav ul li a:hover { background: rgba(0,212,255,0.08); text-decoration: none; border-left-color: %(accent)s; }
.sidebar nav ul li a.active { background: rgba(0,212,255,0.12); border-left-color: %(accent)s; color: %(accent)s; font-weight: 600; }
.sidebar nav details summary {
    display: block; padding: 6px 20px; color: %(accent2)s; font-weight: 600;
    font-size: 0.85em; text-transform: uppercase; letter-spacing: 0.5px;
    cursor: pointer; user-select: none; list-style: none;
}
.sidebar nav details summary::-webkit-details-marker { display: none; }
.sidebar nav details summary::before { content: "\\25B6 "; font-size: 0.65em; margin-right: 4px; display: inline-block; transition: transform 0.15s; }
.sidebar nav details[open] > summary::before { transform: rotate(90deg); }
.sidebar nav details > ul { padding-left: 10px; }

/* Search box in sidebar */
.sidebar-search { padding: 10px 20px; }
.sidebar-search input {
    width: 100%%; padding: 7px 10px; background: %(bg_code)s; border: 1px solid %(border)s;
    border-radius: 4px; color: %(text)s; font-size: 0.88em; outline: none;
}
.sidebar-search input:focus { border-color: %(accent)s; }
.search-results {
    max-height: 300px; overflow-y: auto; padding: 0 20px;
}
.search-results a {
    display: block; padding: 5px 0; font-size: 0.85em; border-bottom: 1px solid %(border)s;
}
.search-results .sr-path { color: %(text_dim)s; font-size: 0.75em; }

/* Main content */
.main { margin-left: 280px; flex: 1; min-width: 0; display: flex; flex-direction: column; }
.content-wrap { display: flex; flex: 1; max-width: 1200px; width: 100%%; }
.content { flex: 1; padding: 20px 40px 60px; min-width: 0; max-width: 860px; }

/* Breadcrumbs */
.breadcrumb { padding: 12px 40px; border-bottom: 1px solid %(border)s; font-size: 0.85em; color: %(text_dim)s; }
.breadcrumb a { color: %(text_dim)s; }
.breadcrumb a:hover { color: %(accent)s; }
.breadcrumb span { margin: 0 6px; }

/* Page TOC (right sidebar) */
.page-toc {
    width: 220px; min-width: 220px; padding: 20px 15px; position: sticky; top: 0;
    align-self: flex-start; max-height: 100vh; overflow-y: auto;
    font-size: 0.82em; border-left: 1px solid %(border)s;
}
.page-toc h4 { color: %(accent2)s; text-transform: uppercase; font-size: 0.8em; letter-spacing: 0.5px; margin-bottom: 8px; }
.page-toc ul { list-style: none; }
.page-toc li { padding: 2px 0; }
.page-toc li.toc-h3 { padding-left: 12px; }
.page-toc a { color: %(text_dim)s; }
.page-toc a:hover { color: %(accent)s; }

/* Typography */
.content h1 { color: %(accent)s; font-size: 2em; margin: 0 0 15px; border-bottom: 2px solid %(border)s; padding-bottom: 8px; }
.content h2 { color: %(accent)s; font-size: 1.5em; margin: 35px 0 15px; border-bottom: 1px solid %(border)s; padding-bottom: 5px; }
.content h3 { color: %(accent2)s; font-size: 1.2em; margin: 25px 0 10px; }
.content h4 { color: %(accent2)s; font-size: 1.05em; margin: 20px 0 8px; }
.content h5, .content h6 { color: %(text_dim)s; margin: 15px 0 8px; }
.content p { margin: 10px 0; }
.content strong { color: #fff; }
.content code {
    background: %(bg_code)s; padding: 2px 6px; border-radius: 3px; font-size: 0.9em;
    font-family: "Cascadia Code", "Fira Code", "Consolas", monospace;
}
.content pre {
    background: %(bg_code)s; border: 1px solid %(border)s; border-radius: 6px;
    padding: 15px; margin: 15px 0; overflow-x: auto; font-size: 0.88em;
}
.content pre code { background: none; padding: 0; border-radius: 0; font-size: 1em; }
.content blockquote {
    border-left: 4px solid %(accent)s; padding: 10px 20px; margin: 15px 0;
    background: rgba(0,212,255,0.04); color: %(text_dim)s; font-style: italic;
}
.content hr { border: none; border-top: 1px solid %(border)s; margin: 25px 0; }
.content ul, .content ol { margin: 10px 0 10px 25px; }
.content li { margin: 4px 0; }
.content img { max-width: 100%%; border-radius: 4px; margin: 10px 0; }

/* Tables */
.table-wrap { overflow-x: auto; margin: 15px 0; }
.content table { border-collapse: collapse; width: 100%%; font-size: 0.92em; }
.content th, .content td { padding: 8px 12px; border: 1px solid %(border)s; text-align: left; }
.content th { background: %(bg_sidebar)s; color: %(accent2)s; font-weight: 600; }
.content tr:nth-child(even) { background: rgba(255,255,255,0.02); }

/* Prev/Next */
.prev-next { display: flex; justify-content: space-between; margin: 40px 0 20px; padding-top: 20px; border-top: 1px solid %(border)s; }
.prev-next a {
    padding: 8px 16px; background: %(bg_card)s; border: 1px solid %(border)s;
    border-radius: 6px; font-size: 0.9em; max-width: 45%%; transition: border-color 0.2s;
}
.prev-next a:hover { border-color: %(accent)s; text-decoration: none; }
.prev-next .label { display: block; font-size: 0.75em; color: %(text_dim)s; text-transform: uppercase; }

/* Mobile toggle */
.sidebar-toggle {
    display: none; position: fixed; top: 10px; left: 10px; z-index: 200;
    background: %(bg_card)s; border: 1px solid %(border)s; color: %(text)s;
    padding: 8px 12px; border-radius: 4px; cursor: pointer; font-size: 1.2em;
}

/* Responsive */
@media (max-width: 1100px) {
    .page-toc { display: none; }
}
@media (max-width: 768px) {
    .sidebar { transform: translateX(-100%%); transition: transform 0.25s; }
    .sidebar.open { transform: translateX(0); }
    .sidebar-toggle { display: block; }
    .main { margin-left: 0; }
    .content { padding: 20px 15px 40px; }
    .breadcrumb { padding: 12px 15px; }
}

/* Print */
@media print {
    .sidebar, .sidebar-toggle, .page-toc, .prev-next, .sidebar-search, .search-results { display: none !important; }
    .main { margin-left: 0; }
    body { background: #fff; color: #000; }
    .content h1, .content h2, .content h3 { color: #000; }
    .content a { color: #000; text-decoration: underline; }
    .content pre, .content code { background: #f0f0f0; border-color: #ccc; }
    .content th { background: #ddd; color: #000; }
}
""" % COLORS


def get_template():
    return """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{TITLE}} — Tech Survival USB</title>
    <style>
{{CSS}}
    </style>
</head>
<body>
    <button class="sidebar-toggle" onclick="document.querySelector('.sidebar').classList.toggle('open')" aria-label="Toggle navigation">&#9776;</button>
    <aside class="sidebar">
        <div class="sidebar-header">
            <h2><a href="{{ROOT}}/index.html">Tech Survival USB</a></h2>
            <p>Offline Documentation</p>
        </div>
        <div class="sidebar-search">
            <input type="text" id="search-input" placeholder="Search docs..." autocomplete="off">
        </div>
        <div class="search-results" id="search-results"></div>
        <nav>
            <ul>
                <li><a href="{{ROOT}}/index.html"{{HOME_ACTIVE}}>Home</a></li>
{{NAV}}
            </ul>
        </nav>
    </aside>
    <div class="main">
        <div class="breadcrumb">{{BREADCRUMB}}</div>
        <div class="content-wrap">
            <article class="content">
{{BODY}}
{{PREVNEXT}}
            </article>
{{TOC_SIDEBAR}}
        </div>
    </div>
    <script>
    var SITE_ROOT = "{{ROOT}}";
    </script>
    <script src="{{ROOT}}/search.js"></script>
    <script>
    // Close sidebar on mobile when clicking a link
    document.querySelectorAll('.sidebar nav a').forEach(function(a) {
        a.addEventListener('click', function() {
            if (window.innerWidth <= 768) document.querySelector('.sidebar').classList.remove('open');
        });
    });
    // Auto-open sidebar sections containing the active page
    var activeLink = document.querySelector('.sidebar nav a.active');
    if (activeLink) {
        var el = activeLink.closest('details');
        while (el) { el.open = true; el = el.parentElement ? el.parentElement.closest('details') : null; }
    }
    </script>
</body>
</html>"""


# ---------------------------------------------------------------------------
# Build Logic
# ---------------------------------------------------------------------------

def extract_title(md_text, filename):
    """Extract first H1 from markdown, or generate from filename."""
    m = re.match(r'^#\s+(.+)$', md_text.strip(), re.MULTILINE)
    if m:
        return m.group(1).strip()
    return filename.replace('.md', '').replace('-', ' ').title()


def extract_plain_text(md_text, max_chars=200):
    """Strip markdown to plain text for search snippet."""
    text = re.sub(r'^#{1,6}\s+', '', md_text, flags=re.MULTILINE)
    text = re.sub(r'```[\s\S]*?```', '', text)
    text = re.sub(r'`[^`]+`', '', text)
    text = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', text)
    text = re.sub(r'!\[([^\]]*)\]\([^)]+\)', '', text)
    text = re.sub(r'[*_]{1,3}', '', text)
    text = re.sub(r'\|', ' ', text)
    text = re.sub(r'[-:]{3,}', '', text)
    text = re.sub(r'>\s?', '', text)
    text = re.sub(r'\n+', ' ', text)
    text = re.sub(r'\s+', ' ', text).strip()
    return text[:max_chars]


def compute_root(rel_path):
    """Compute relative path from file location back to build root.
    E.g. 'hardware/lora/overview.html' -> '../..'
    """
    depth = len(Path(rel_path).parent.parts)
    if depth == 0:
        return "."
    return "/".join([".."] * depth)


def build_breadcrumb(rel_path, title):
    """Build breadcrumb HTML."""
    root = compute_root(rel_path)
    parts = Path(rel_path).parts
    crumbs = [f'<a href="{root}/index.html">Home</a>']
    # Add directory parts
    for i, part in enumerate(parts[:-1]):
        display = SECTION_NAMES.get(part, part.replace("-", " ").title())
        crumbs.append(f'<span>/</span> {escape(display)}')
    crumbs.append(f'<span>/</span> {escape(title)}')
    return ' '.join(crumbs)


def build_toc_sidebar(toc):
    """Build right-side table of contents from h2/h3 entries."""
    if not toc:
        return ""
    items = []
    for level, anchor, text in toc:
        cls = "toc-h3" if level == 3 else ""
        items.append(f'<li class="{cls}"><a href="#{anchor}">{escape(text)}</a></li>')
    return f"""<aside class="page-toc">
                <h4>On This Page</h4>
                <ul>
                    {''.join(items)}
                </ul>
            </aside>"""


def build_prev_next(pages, current_rel):
    """Build previous/next navigation links."""
    idx = None
    for i, (rp, _) in enumerate(pages):
        if rp == current_rel:
            idx = i
            break
    if idx is None:
        return ""

    root = compute_root(current_rel)
    parts = []
    if idx > 0:
        prev_path = pages[idx - 1][0].replace('.md', '.html')
        prev_title = pages[idx - 1][1]
        parts.append(f'<a href="{root}/{prev_path}"><span class="label">Previous</span>{escape(prev_title)}</a>')
    else:
        parts.append('<span></span>')

    if idx < len(pages) - 1:
        next_path = pages[idx + 1][0].replace('.md', '.html')
        next_title = pages[idx + 1][1]
        parts.append(f'<a href="{root}/{next_path}"><span class="label">Next</span>{escape(next_title)}</a>')
    else:
        parts.append('<span></span>')

    return f'<div class="prev-next">{"".join(parts)}</div>'


def generate_search_js():
    """Generate the client-side search JavaScript."""
    return """// search.js — client-side search for Tech Survival USB docs
(function() {
    var searchIndex = null;
    var input = document.getElementById('search-input');
    var resultsDiv = document.getElementById('search-results');
    if (!input || !resultsDiv) return;

    function loadIndex() {
        if (searchIndex) return Promise.resolve(searchIndex);
        return new Promise(function(resolve, reject) {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', SITE_ROOT + '/search-index.json');
            xhr.onload = function() {
                if (xhr.status === 200) {
                    searchIndex = JSON.parse(xhr.responseText);
                    resolve(searchIndex);
                } else {
                    // Fallback: try to load from script tag
                    reject('Could not load search index');
                }
            };
            xhr.onerror = function() { reject('Network error'); };
            xhr.send();
        });
    }

    function doSearch(query) {
        if (!query || query.length < 2) {
            resultsDiv.innerHTML = '';
            return;
        }
        loadIndex().then(function(index) {
            var q = query.toLowerCase();
            var terms = q.split(/\\s+/).filter(function(t) { return t.length > 0; });
            var scored = [];
            index.forEach(function(entry) {
                var titleLower = entry.title.toLowerCase();
                var snippetLower = entry.snippet.toLowerCase();
                var pathLower = entry.path.toLowerCase();
                var score = 0;
                terms.forEach(function(term) {
                    if (titleLower.indexOf(term) !== -1) score += 10;
                    if (pathLower.indexOf(term) !== -1) score += 3;
                    if (snippetLower.indexOf(term) !== -1) score += 1;
                });
                if (score > 0) scored.push({ entry: entry, score: score });
            });
            scored.sort(function(a, b) { return b.score - a.score; });
            var top = scored.slice(0, 15);
            if (top.length === 0) {
                resultsDiv.innerHTML = '<p style="padding:5px 0;font-size:0.85em;color:#888;">No results found.</p>';
                return;
            }
            var html = '';
            top.forEach(function(item) {
                var href = SITE_ROOT + '/' + item.entry.path;
                html += '<a href="' + href + '">' + escapeHtml(item.entry.title) + '<br><span class="sr-path">' + escapeHtml(item.entry.path) + '</span></a>';
            });
            resultsDiv.innerHTML = html;
        }).catch(function() {
            resultsDiv.innerHTML = '<p style="padding:5px 0;font-size:0.85em;color:#888;">Search unavailable (run from a local server or open search-index.json).</p>';
        });
    }

    function escapeHtml(text) {
        var div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    var debounceTimer;
    input.addEventListener('input', function() {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function() { doSearch(input.value); }, 200);
    });

    // Allow Enter to navigate to first result
    input.addEventListener('keydown', function(e) {
        if (e.key === 'Enter') {
            var first = resultsDiv.querySelector('a');
            if (first) window.location.href = first.href;
        }
    });

    // Keyboard shortcut: / to focus search
    document.addEventListener('keydown', function(e) {
        if (e.key === '/' && document.activeElement !== input && document.activeElement.tagName !== 'INPUT') {
            e.preventDefault();
            input.focus();
        }
    });
})();
"""


def generate_index_html(md_files, nav_tree):
    """Generate the main index.html with grid layout matching START_HERE.html."""
    # Group files by top-level section
    sections = OrderedDict()
    for rel_path, info in sorted(md_files.items()):
        if rel_path == "index.md":
            continue
        parts = Path(rel_path).parts
        if len(parts) >= 2:
            section = parts[0]
            if section not in sections:
                sections[section] = []
            sections[section].append((rel_path, info["title"]))

    cards_html = []
    for section_key, files in sections.items():
        display = SECTION_NAMES.get(section_key, section_key.replace("-", " ").title())
        links = []
        for rel_path, title in files:
            html_path = rel_path.replace(".md", ".html")
            links.append(f'<li><a href="{html_path}">{escape(title)}</a></li>')
        cards_html.append(f"""<div class="card">
            <h3>{escape(display)}</h3>
            <ul>{''.join(links)}</ul>
        </div>""")

    body = f"""<h1>Tech Survival USB</h1>
<p class="subtitle">Offline documentation for electronics, radio, and mesh networking</p>
<div class="tip"><strong>Tip:</strong> Use the sidebar to navigate, or press <kbd>/</kbd> to search all docs.</div>
<h2>Documentation</h2>
<div class="grid">
{''.join(cards_html)}
</div>
<style>
.subtitle {{ color: {COLORS["text_dim"]}; font-size: 1.1em; margin-bottom: 20px; }}
.grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 20px 0; }}
.card {{ background: {COLORS["bg_card"]}; border: 1px solid {COLORS["border"]}; border-radius: 8px; padding: 20px; transition: border-color 0.2s; }}
.card:hover {{ border-color: {COLORS["accent"]}; }}
.card h3 {{ color: {COLORS["accent2"]}; margin: 0 0 10px; font-size: 1.1em; }}
.card ul {{ list-style: none; padding: 0; }}
.card li {{ padding: 3px 0; font-size: 0.9em; }}
.card li::before {{ content: "\\2192  "; color: #555; }}
.tip {{ background: {COLORS["tip_bg"]}; border-left: 3px solid {COLORS["tip_border"]}; padding: 10px 15px; margin: 15px 0; border-radius: 0 4px 4px 0; }}
kbd {{ background: {COLORS["bg_code"]}; padding: 2px 6px; border-radius: 3px; border: 1px solid {COLORS["border"]}; font-size: 0.85em; }}
</style>"""

    return body


def main():
    print("=" * 60)
    print("  Tech Survival USB — HTML Documentation Builder")
    print("=" * 60)
    print()

    if not DOCS_DIR.is_dir():
        print(f"ERROR: docs/ directory not found at {DOCS_DIR}")
        sys.exit(1)

    # Collect all .md files
    md_files = OrderedDict()  # rel_path -> { title, md_text }
    for md_path in sorted(DOCS_DIR.rglob("*.md")):
        rel = md_path.relative_to(DOCS_DIR)
        rel_str = str(rel).replace("\\", "/")
        md_text = md_path.read_text(encoding="utf-8", errors="replace")
        title = extract_title(md_text, md_path.name)
        md_files[rel_str] = {
            "title": title,
            "md_text": md_text,
            "path": md_path,
        }

    print(f"Found {len(md_files)} markdown files in docs/")
    print()

    # Build nav tree
    nav_tree = build_nav_tree(md_files)
    pages = get_flat_page_list(md_files)

    # Prepare output directory
    if BUILD_DIR.exists():
        shutil.rmtree(BUILD_DIR)
    BUILD_DIR.mkdir(parents=True, exist_ok=True)

    # Template
    template = get_template()
    search_index = []
    total_size = 0
    files_converted = 0

    for rel_str, info in md_files.items():
        title = info["title"]
        md_text = info["md_text"]

        print(f"  Converting: {rel_str}")

        # Parse markdown
        parser = MarkdownParser(current_file_rel=rel_str)
        body_html, toc = parser.parse(md_text)

        # Build page
        root = compute_root(rel_str)
        nav_html = render_nav_html(nav_tree, rel_str)
        nav_html = nav_html.replace("{{ROOT}}", root)
        breadcrumb = build_breadcrumb(rel_str, title)
        toc_sidebar = build_toc_sidebar(toc)
        prev_next = build_prev_next(pages, rel_str)
        home_active = ' class="active"' if rel_str == "index.md" else ''

        page_html = template
        page_html = page_html.replace("{{TITLE}}", escape(title))
        page_html = page_html.replace("{{CSS}}", CSS)
        page_html = page_html.replace("{{ROOT}}", root)
        page_html = page_html.replace("{{NAV}}", nav_html)
        page_html = page_html.replace("{{HOME_ACTIVE}}", home_active)
        page_html = page_html.replace("{{BREADCRUMB}}", breadcrumb)
        page_html = page_html.replace("{{BODY}}", body_html)
        page_html = page_html.replace("{{TOC_SIDEBAR}}", toc_sidebar)
        page_html = page_html.replace("{{PREVNEXT}}", prev_next)

        # Write
        out_path = BUILD_DIR / rel_str.replace(".md", ".html")
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(page_html, encoding="utf-8")

        file_size = out_path.stat().st_size
        total_size += file_size
        files_converted += 1

        # Search index entry
        search_index.append({
            "title": title,
            "path": rel_str.replace(".md", ".html"),
            "snippet": extract_plain_text(md_text, 200),
        })

    # Generate index.html
    print(f"\n  Generating: index.html (main entry point)")
    index_body = generate_index_html(md_files, nav_tree)
    root = "."
    nav_html = render_nav_html(nav_tree, "index.md")
    nav_html = nav_html.replace("{{ROOT}}", root)

    index_page = template
    index_page = index_page.replace("{{TITLE}}", "Home")
    index_page = index_page.replace("{{CSS}}", CSS)
    index_page = index_page.replace("{{ROOT}}", root)
    index_page = index_page.replace("{{NAV}}", nav_html)
    index_page = index_page.replace("{{HOME_ACTIVE}}", ' class="active"')
    index_page = index_page.replace("{{BREADCRUMB}}", '<a href="index.html">Home</a>')
    index_page = index_page.replace("{{BODY}}", index_body)
    index_page = index_page.replace("{{TOC_SIDEBAR}}", "")
    index_page = index_page.replace("{{PREVNEXT}}", "")

    index_path = BUILD_DIR / "index.html"
    index_path.write_text(index_page, encoding="utf-8")
    total_size += index_path.stat().st_size

    # Write search index
    print(f"  Generating: search-index.json")
    SEARCH_INDEX_FILE.write_text(json.dumps(search_index, indent=1), encoding="utf-8")
    total_size += SEARCH_INDEX_FILE.stat().st_size

    # Write search.js
    print(f"  Generating: search.js")
    search_js_path = BUILD_DIR / "search.js"
    search_js_path.write_text(generate_search_js(), encoding="utf-8")
    total_size += search_js_path.stat().st_size

    # Summary
    print()
    print("=" * 60)
    print(f"  Build complete!")
    print(f"  Files converted: {files_converted}")
    print(f"  Output directory: {BUILD_DIR}")
    if total_size > 1024 * 1024:
        print(f"  Total size: {total_size / (1024*1024):.1f} MB")
    else:
        print(f"  Total size: {total_size / 1024:.1f} KB")
    print("=" * 60)


if __name__ == "__main__":
    main()
