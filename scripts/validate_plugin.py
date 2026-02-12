#!/usr/bin/env python3
"""Validate skill-overflow plugin structure and metadata."""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
errors: list[str] = []


def error(msg: str) -> None:
    errors.append(msg)
    print(f"  FAIL: {msg}")


def validate_plugin_json() -> None:
    print("Checking .claude-plugin/plugin.json ...")
    path = ROOT / ".claude-plugin" / "plugin.json"
    if not path.exists():
        error("plugin.json not found")
        return

    try:
        data = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        error(f"plugin.json is not valid JSON: {exc}")
        return

    name = data.get("name")
    if not name:
        error("plugin.json missing 'name'")
    elif not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", name):
        error(f"plugin.json 'name' must be kebab-case, got '{name}'")

    if not data.get("version"):
        error("plugin.json missing 'version'")


def validate_marketplace_json() -> None:
    print("Checking .claude-plugin/marketplace.json ...")
    path = ROOT / ".claude-plugin" / "marketplace.json"
    if not path.exists():
        error("marketplace.json not found")
        return

    try:
        data = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        error(f"marketplace.json is not valid JSON: {exc}")
        return

    if not data.get("name"):
        error("marketplace.json missing 'name'")

    owner = data.get("owner")
    if not owner or not owner.get("name"):
        error("marketplace.json missing 'owner.name'")

    plugins = data.get("plugins")
    if not isinstance(plugins, list) or len(plugins) == 0:
        error("marketplace.json missing 'plugins' array")


def validate_skills() -> None:
    print("Checking skills ...")
    skills_dir = ROOT / "skills"
    if not skills_dir.is_dir():
        error("skills/ directory not found")
        return

    for skill_dir in sorted(skills_dir.iterdir()):
        if not skill_dir.is_dir():
            continue

        skill_name = skill_dir.name
        skill_file = skill_dir / "SKILL.md"

        if not skill_file.exists():
            error(f"skills/{skill_name}/SKILL.md not found")
            continue

        content = skill_file.read_text()

        # Extract YAML frontmatter
        match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
        if not match:
            error(f"skills/{skill_name}/SKILL.md missing YAML frontmatter")
            continue

        frontmatter = match.group(1)

        # Check name field
        name_match = re.search(r"^name:\s*(.+)$", frontmatter, re.MULTILINE)
        if not name_match:
            error(f"skills/{skill_name}/SKILL.md frontmatter missing 'name'")
        elif name_match.group(1).strip() != skill_name:
            error(
                f"skills/{skill_name}/SKILL.md 'name' is '{name_match.group(1).strip()}', "
                f"expected '{skill_name}'"
            )

        # Check description field
        desc_match = re.search(r"^description:\s*(.+)$", frontmatter, re.MULTILINE)
        if not desc_match or not desc_match.group(1).strip():
            error(f"skills/{skill_name}/SKILL.md frontmatter missing 'description'")


def main() -> int:
    validate_plugin_json()
    validate_marketplace_json()
    validate_skills()

    print()
    if errors:
        print(f"Validation failed with {len(errors)} error(s).")
        return 1

    print("All checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
