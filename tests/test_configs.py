#!/usr/bin/env python3
"""Validate config files are well-formed."""
import csv
import sys
from pathlib import Path

CONFIG_DIR = Path("config")


def check_text_list(filepath, name):
    """Check a text file with one item per line (# comments allowed)."""
    errors = []
    if not filepath.exists():
        return [f"{name}: file not found"]

    lines = filepath.read_text().strip().splitlines()
    entries = [l.strip() for l in lines if l.strip() and not l.strip().startswith("#")]

    if not entries:
        errors.append(f"{name}: no entries found")

    for i, entry in enumerate(entries, 1):
        if "\t" in entry:
            errors.append(f"{name} line {i}: contains tab character")

    return errors


def check_csv(filepath, name):
    """Check a CSV file is parseable."""
    errors = []
    if not filepath.exists():
        return [f"{name}: file not found"]

    try:
        with open(filepath, newline="", encoding="utf-8") as f:
            reader = csv.reader(f)
            header = next(reader)
            if len(header) < 2:
                errors.append(f"{name}: header has fewer than 2 columns")
            rows = list(reader)
            if not rows:
                errors.append(f"{name}: no data rows")
    except csv.Error as e:
        errors.append(f"{name}: CSV parse error: {e}")

    return errors


def check_datasheets(filepath, name):
    """Check datasheets.txt has FILENAME URL format."""
    errors = []
    if not filepath.exists():
        return [f"{name}: file not found"]

    lines = filepath.read_text().strip().splitlines()
    for i, line in enumerate(lines, 1):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split(None, 1)
        if len(parts) < 2:
            errors.append(f"{name} line {i}: expected 'FILENAME URL', got: {line[:60]}")
        elif not parts[1].startswith("http"):
            errors.append(f"{name} line {i}: URL doesn't start with http: {parts[1][:60]}")

    return errors


def main():
    all_errors = []

    all_errors += check_text_list(CONFIG_DIR / "packages-npm.txt", "packages-npm.txt")
    all_errors += check_text_list(CONFIG_DIR / "packages-pip.txt", "packages-pip.txt")
    all_errors += check_text_list(CONFIG_DIR / "docker-images.txt", "docker-images.txt")
    all_errors += check_csv(CONFIG_DIR / "chirp-frequencies.csv", "chirp-frequencies.csv")
    all_errors += check_datasheets(CONFIG_DIR / "datasheets.txt", "datasheets.txt")

    # Check meshtastic-presets.yaml is valid YAML
    yaml_file = CONFIG_DIR / "meshtastic-presets.yaml"
    if yaml_file.exists():
        try:
            # Try stdlib approach first — no yaml in stdlib, so just check it's not empty
            content = yaml_file.read_text()
            if len(content.strip()) < 50:
                all_errors.append("meshtastic-presets.yaml: appears empty")
            # Basic YAML structure check
            if "mobile_node:" not in content:
                all_errors.append("meshtastic-presets.yaml: missing expected 'mobile_node' preset")
        except Exception as e:
            all_errors.append(f"meshtastic-presets.yaml: read error: {e}")
    else:
        all_errors.append("meshtastic-presets.yaml: file not found")

    if all_errors:
        print(f"FAIL: {len(all_errors)} config error(s):")
        for e in all_errors:
            print(f"  - {e}")
        sys.exit(1)

    print("OK: All config files validated.")


if __name__ == "__main__":
    main()
