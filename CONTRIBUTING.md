# Contributing to Offgrid Electronics

Thanks for your interest in contributing! This project is a community-driven offline reference for electronics, radio, SDR, and mesh networking.

## How to Contribute

### Reporting Issues

- Open an [issue](https://github.com/jscrobinson/offgrid-electronics/issues) for bugs, outdated information, or missing topics
- Include the file path if reporting a doc error (e.g., `docs/hardware/lora/lilygo-tbeam-v1.2.md`)

### Adding or Improving Documentation

1. Fork the repo and create a branch from `master`
2. Add or edit markdown files in `docs/`
3. If adding a new doc, add it to `docs/index.md`
4. Submit a pull request

### Documentation Guidelines

**Content:**
- Write for offline use — don't assume the reader has internet access
- Be practical and specific — include pinouts, code examples, command-line snippets
- Prefer accuracy over length, but don't be afraid of detail
- Include tables for specs, pin mappings, and comparisons
- Note which hardware you've personally tested when relevant

**Style:**
- Use ATX-style headers (`# H1`, `## H2`, etc.)
- One blank line before and after headers, code blocks, and tables
- Use fenced code blocks with language tags (` ```bash`, ` ```python`, ` ```cpp`)
- Use relative links between docs (e.g., `[T-Beam](../lora/lilygo-tbeam-v1.2.md)`)
- No trailing whitespace

**File naming:**
- Lowercase, hyphens for spaces: `my-new-topic.md`
- Place files in the appropriate `docs/` subdirectory
- Match existing naming patterns in that directory

### Adding or Updating Scripts

- Scripts go in `scripts/`
- Source `common.sh` for shared utilities (logging, downloads, disk checks)
- Use `set -euo pipefail` at the top
- Use `download_file` from `common.sh` for downloads with retry logic
- Add `continue-on-error: true` for new download steps in the release workflow

### Adding Config Files

- Config files go in `config/`
- Use comments to explain format and purpose
- If adding a new config, wire it into the relevant download script

## Commit Messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for automated releases.

| Prefix | When to use | Release effect |
|---|---|---|
| `feat:` | New documentation, scripts, or features | Minor version bump |
| `fix:` | Corrections, broken links, script fixes | Patch version bump |
| `docs:` | README, CONTRIBUTING, comments only | No release |
| `chore:` | CI, config, tooling changes | No release |
| `feat!:` | Breaking changes (directory restructure, etc.) | Major version bump |

Examples:
```
feat: add MeshCore documentation
fix: correct T-Beam v1.2 GPS pin assignment
docs: update README with download instructions
chore: update markdownlint config
```

## Pull Request Process

1. Ensure your branch is up to date with `master`
2. CI must pass — the following checks run on every PR:
   - **Markdown lint** — checks all `docs/**/*.md` files
   - **ShellCheck** — lints all `scripts/*.sh` files
   - **Doc validation** — verifies all planned docs exist and have content
   - **Internal links** — checks for broken cross-references between docs
   - **HTML build** — builds the static HTML site and verifies output
   - **Config validation** — checks config file format and completeness
3. Keep PRs focused — one topic per PR when possible
4. Describe what you changed and why in the PR description

## Development Setup

```bash
# Clone the repo
git clone https://github.com/jscrobinson/offgrid-electronics.git
cd offgrid-electronics

# Build the HTML docs locally
make html

# Run tests locally before pushing
python3 tests/test_docs_exist.py
python3 tests/test_internal_links.py
python3 tests/test_configs.py
python3 scripts/build-html.py
python3 tests/test_html_build.py
```

### Running ShellCheck Locally

```bash
# Install
sudo apt install shellcheck  # Debian/Ubuntu
brew install shellcheck       # macOS

# Run
shellcheck scripts/*.sh
```

### Running Markdownlint Locally

```bash
# Install
npm install -g markdownlint-cli2

# Run
markdownlint-cli2 "docs/**/*.md"
```

## Release Process

Releases are automated via [Release Please](https://github.com/googleapis/release-please):

1. Conventional commit messages on `master` are tracked automatically
2. Release Please opens a PR (e.g., "chore(master): release 1.4.0") with a changelog
3. Merging the PR triggers the release pipeline which:
   - Runs the full test suite
   - Builds HTML documentation
   - Downloads toolchains, editors, SDR software, firmware, datasheets, and cached packages
   - Creates split release zips (each under 2 GB for GitHub)
   - Publishes the GitHub release with all assets

## Project Structure

```
docs/           Authored markdown documentation (107 files)
scripts/        Download, build, and verification scripts
config/         Package lists, frequency lists, presets
static/         Images and printable cheatsheets
templates/      Document and pinout templates
tests/          CI test scripts
build/          Downloaded content (gitignored)
```

## Questions?

Open an issue or start a discussion on the repo. We're happy to help.
