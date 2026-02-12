#!/usr/bin/env python3
"""Validate skill-overflow marketplace structure and all department plugins."""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
errors: list[str] = []


def error(msg: str) -> None:
    errors.append(msg)
    print(f"  FAIL: {msg}")


def validate_marketplace_json() -> list[dict]:
    """Validate root marketplace.json and return the plugins list."""
    print("Checking .claude-plugin/marketplace.json ...")
    path = ROOT / ".claude-plugin" / "marketplace.json"
    if not path.exists():
        error("marketplace.json not found")
        return []

    try:
        data = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        error(f"marketplace.json is not valid JSON: {exc}")
        return []

    if not data.get("name"):
        error("marketplace.json missing 'name'")

    owner = data.get("owner")
    if not owner or not owner.get("name"):
        error("marketplace.json missing 'owner.name'")

    plugins = data.get("plugins")
    if not isinstance(plugins, list) or len(plugins) == 0:
        error("marketplace.json missing 'plugins' array")
        return []

    for plugin in plugins:
        if not plugin.get("name"):
            error("marketplace.json plugin entry missing 'name'")
        if not plugin.get("source"):
            error(f"marketplace.json plugin '{plugin.get('name', '?')}' missing 'source'")

    return plugins


def validate_no_root_plugin_json() -> None:
    """Ensure there is no root-level plugin.json (marketplace only)."""
    print("Checking no root plugin.json ...")
    path = ROOT / ".claude-plugin" / "plugin.json"
    if path.exists():
        error(
            "Root .claude-plugin/plugin.json should not exist — "
            "the root is a marketplace, not a plugin"
        )


def validate_plugin(plugin: dict) -> None:
    """Validate a single department plugin directory."""
    name = plugin.get("name", "unknown")
    source = plugin.get("source", "")
    plugin_dir = ROOT / source

    print(f"Checking plugin '{name}' at {source} ...")

    # Check source directory exists
    if not plugin_dir.is_dir():
        error(f"Plugin '{name}': source directory '{source}' not found")
        return

    # Check plugin.json
    pjson_path = plugin_dir / ".claude-plugin" / "plugin.json"
    if not pjson_path.exists():
        error(f"Plugin '{name}': .claude-plugin/plugin.json not found")
    else:
        try:
            pdata = json.loads(pjson_path.read_text())
        except json.JSONDecodeError as exc:
            error(f"Plugin '{name}': plugin.json is not valid JSON: {exc}")
            pdata = {}

        pname = pdata.get("name")
        if not pname:
            error(f"Plugin '{name}': plugin.json missing 'name'")
        elif not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", pname):
            error(f"Plugin '{name}': plugin.json 'name' must be kebab-case, got '{pname}'")

        if not pdata.get("version"):
            error(f"Plugin '{name}': plugin.json missing 'version'")

    # Validate skills
    skills_dir = plugin_dir / "skills"
    if skills_dir.is_dir():
        for skill_dir in sorted(skills_dir.iterdir()):
            if not skill_dir.is_dir():
                continue
            validate_skill(name, skill_dir)

    # Validate agents
    agents_dir = plugin_dir / "agents"
    if agents_dir.is_dir():
        for agent_file in sorted(agents_dir.iterdir()):
            if agent_file.suffix != ".md":
                continue
            validate_agent(name, agent_file)


def validate_skill(plugin_name: str, skill_dir: Path) -> None:
    """Validate a skill directory has proper SKILL.md with frontmatter."""
    skill_name = skill_dir.name
    skill_file = skill_dir / "SKILL.md"

    if not skill_file.exists():
        error(f"Plugin '{plugin_name}': skills/{skill_name}/SKILL.md not found")
        return

    content = skill_file.read_text()
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        error(f"Plugin '{plugin_name}': skills/{skill_name}/SKILL.md missing YAML frontmatter")
        return

    frontmatter = match.group(1)

    name_match = re.search(r"^name:\s*(.+)$", frontmatter, re.MULTILINE)
    if not name_match:
        error(f"Plugin '{plugin_name}': skills/{skill_name}/SKILL.md frontmatter missing 'name'")
    elif name_match.group(1).strip() != skill_name:
        error(
            f"Plugin '{plugin_name}': skills/{skill_name}/SKILL.md 'name' is "
            f"'{name_match.group(1).strip()}', expected '{skill_name}'"
        )

    desc_match = re.search(r"^description:\s*(.+)$", frontmatter, re.MULTILINE)
    if not desc_match or not desc_match.group(1).strip():
        error(
            f"Plugin '{plugin_name}': skills/{skill_name}/SKILL.md "
            f"frontmatter missing 'description'"
        )


def validate_agent(plugin_name: str, agent_file: Path) -> None:
    """Validate an agent file has proper frontmatter."""
    agent_name = agent_file.stem
    content = agent_file.read_text()

    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        error(f"Plugin '{plugin_name}': agents/{agent_name}.md missing YAML frontmatter")
        return

    frontmatter = match.group(1)

    name_match = re.search(r"^name:\s*(.+)$", frontmatter, re.MULTILINE)
    if not name_match:
        error(f"Plugin '{plugin_name}': agents/{agent_name}.md frontmatter missing 'name'")

    desc_match = re.search(r"^description:\s*(.+)$", frontmatter, re.MULTILINE)
    if not desc_match or not desc_match.group(1).strip():
        error(f"Plugin '{plugin_name}': agents/{agent_name}.md frontmatter missing 'description'")


def main() -> int:
    validate_no_root_plugin_json()
    plugins = validate_marketplace_json()

    for plugin in plugins:
        validate_plugin(plugin)

    print()
    if errors:
        print(f"Validation failed with {len(errors)} error(s).")
        return 1

    print(f"All checks passed ({len(plugins)} plugins validated).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
