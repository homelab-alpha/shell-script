#!/usr/bin/env python3

# Filename:    generate_badges.py
# Author:      Homelab-Alpha
# Date:        2026-10-31
# Version:     1.0.0

# Description: Generates the README badges as self-contained SVG files, in the
#              Apple Human Interface Guidelines style described in
#              .github/branding/brand_guide.md. It replaces
#              img.shields.io: nothing is fetched from a third-party service.
#
#              Dynamic badges (Super Linter, CodeQL, last commit, repo size,
#              license) are rendered from a JSON file that the badges workflow
#              fills with GitHub API data. Static badges (changelog, code of
#              conduct, commit convention, versioning) need no input.
#
#              Uses the Python standard library only.
#
# Usage:
#   # Render all badges into ./badges
#   python3 .github/scripts/generate_badges.py --data badge_data.json --output badges
#
# Input (--data), a JSON object:
#   {
#     "last_commit": "2026-10-31T09:15:00Z",   ISO 8601 timestamp
#     "size_kb": 812,                           repository size in KB
#     "license": "Apache-2.0",                  SPDX id or license name
#     "super_linter": "success",                latest run conclusion (optional)
#     "codeql": "failure"                       latest run conclusion (optional)
#   }
#
#   A run conclusion is "success", "failure", or anything else for unknown.
#
# Environment Variables:
#   GITHUB_ACTIONS — When "true", problems are also emitted as annotations.

from __future__ import annotations

import argparse
import json
import logging
import os
import sys
from dataclasses import dataclass
from datetime import datetime
from html import escape
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)

# ── Semantic color tokens ────────────────────────────────────────────────────
# Same tokens as the design guidelines (Apple HIG): never use a raw color
# outside these tables. Keep in sync with .github/branding/brand_guide.md.
# `group` and `sep` match the tile and line colors of the profile stats cards,
# in light and dark mode. The dark text, accent, green, and red colors match the
# terminal session of those cards, so the badges blend with the GitHub themes.
LIGHT = {
    "label": "#000000",
    "label2": "#5c5c61",
    "group": "#eaeef2",
    "sep": "#c3c9cf",
    "accent": "#0062cc",
    "green": "#1b7a34",
    "red": "#c4161c",
}
DARK = {
    "label": "#dfe2e6",
    "label2": "#8b949e",
    "group": "#151b23",
    "sep": "#353a3f",
    "accent": "#398cfe",
    "green": "#3fbc51",
    "red": "#df3733",
}

# ── Layout (pixels) ──────────────────────────────────────────────────────────
# A 4 and 8 point rhythm. The tile is a capsule: its radius is half its height.
HEIGHT = 24
RADIUS = HEIGHT // 2
PAD_X = 12
ICON_SIZE = 12
GAP_ICON = 8
GAP_TEXT = 4
GAP_DOT = 8
DOT_SIZE = 6
FONT_SIZE = 12  # caption size; never below 11 px
FONT_FAMILY = (
    "-apple-system, BlinkMacSystemFont, 'SF Pro Text', system-ui, "
    "'Segoe UI', Roboto, sans-serif"
)
BASELINE_Y = 16

# ── Icons ────────────────────────────────────────────────────────────────────
# Drawn on a 16 x 16 grid, stroke only, round caps and joins, like the mark.
ICONS = {
    "commit": (
        '<path d="M1 8 H5.5 M10.5 8 H15"/><circle cx="8" cy="8" r="2.5"/>'
    ),
    "box": (
        '<path d="M2 5 L8 2 L14 5 V11 L8 14 L2 11 Z M2 5 L8 8 L14 5 M8 8 V14"/>'
    ),
    "scales": (
        '<path d="M8 2.5 V13.5 M4.5 13.5 H11.5 M3 4.5 H13 '
        "M3 4.5 L1.5 9 M3 4.5 L4.5 9 M1.5 9 a1.5 1.5 0 0 0 3 0 "
        "M13 4.5 L11.5 9 M13 4.5 L14.5 9 M11.5 9 a1.5 1.5 0 0 0 3 0"
        '"/>'
    ),
    "list": '<path d="M2.5 4 H3.5 M6 4 H13 M2.5 8 H3.5 M6 8 H13 M2.5 12 H3.5 M6 12 H13"/>',
    "heart": (
        '<path d="M8 13.5 C3 10.5 1.5 8 1.5 5.8 C1.5 3.8 3 2.5 4.8 2.5 '
        "C6.2 2.5 7.4 3.3 8 4.5 C8.6 3.3 9.8 2.5 11.2 2.5 "
        'C13 2.5 14.5 3.8 14.5 5.8 C14.5 8 13 10.5 8 13.5 Z"/>'
    ),
    "check": '<circle cx="8" cy="8" r="6"/><path d="M5.5 8.2 L7.3 10 L10.7 6"/>',
    "search": '<circle cx="7" cy="7" r="4.5"/><path d="M10.5 10.5 L14 14"/>',
    "shield": (
        '<path d="M8 1.8 L13.5 3.8 V8 C13.5 11 11.2 13 8 14.3 '
        'C4.8 13 2.5 11 2.5 8 V3.8 Z M5.7 8 L7.3 9.6 L10.3 6.4"/>'
    ),
    "tag": '<path d="M2 2.5 H8 L14 8.5 L8.5 14 L2 7.5 Z M5 5.5 H5.01"/>',
}


@dataclass(frozen=True)
class Badge:
    """One badge: file name, icon, label, value, and whether it is live."""

    name: str
    icon: str
    label: str
    value: str
    dynamic: bool = False
    status: str = "now"  # dot of a live badge: now, ok, fail, or none


def gh_annotation(level: str, title: str, message: str) -> None:
    """Emit a GitHub Actions annotation if running in CI."""
    if os.getenv("GITHUB_ACTIONS") == "true":
        print(f"::{level} title={title}::{message}")


def fail(title: str, message: str) -> None:
    """Log an error, emit an annotation, and stop."""
    logger.error(message)
    gh_annotation("error", title, f"❌ {message}")
    raise SystemExit(1)


def human_size(size_kb: int) -> str:
    """Format a size in KB as KB, MB, or GB."""
    if size_kb < 1024:
        return f"{size_kb} KB"
    size_mb = size_kb / 1024
    if size_mb < 1024:
        return f"{size_mb:.1f} MB"
    return f"{size_mb / 1024:.1f} GB"


def format_date(timestamp: str) -> str:
    """Return the date (YYYY-MM-DD, UTC) of an ISO 8601 timestamp."""
    parsed = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
    return parsed.strftime("%Y-%m-%d")


def run_status(conclusion: object) -> tuple[str, str]:
    """Map a workflow run conclusion to a badge value and a dot status."""
    if conclusion == "success":
        return "passing", "ok"
    if conclusion in ("failure", "timed_out", "startup_failure"):
        return "failing", "fail"
    return "unknown", "none"


def text_width(text: str, bold: bool) -> float:
    """Estimate the rendered width of text in pixels at FONT_SIZE."""
    total = 0.0
    for char in text:
        if char in "iljI.,:;'|!()[] -":
            total += 0.30
        elif char in "mw":
            total += 0.86
        elif char in "MW@%":
            total += 0.92
        elif char.isdigit():
            total += 0.57
        elif char.isupper():
            total += 0.64
        else:
            total += 0.52
    if bold:
        total *= 1.05
    return round(total * FONT_SIZE, 1)


def render(badge: Badge) -> str:
    """Render one badge as an SVG document."""
    label_w = text_width(badge.label, bold=False)
    value_w = text_width(badge.value, bold=True)

    icon_x = PAD_X
    label_x = icon_x + ICON_SIZE + GAP_ICON
    value_x = round(label_x + label_w + GAP_TEXT, 1)
    end_x = value_x + value_w
    dot_x = 0.0
    if badge.dynamic:
        dot_x = round(end_x + GAP_DOT + DOT_SIZE / 2, 1)
        end_x = dot_x + DOT_SIZE / 2
    width = round(end_x + PAD_X)

    title = escape(f"{badge.label}: {badge.value}")
    label = escape(badge.label)
    value = escape(badge.value)
    scale = ICON_SIZE / 16
    icon_y = (HEIGHT - ICON_SIZE) / 2
    if not badge.dynamic:
        dot = ""
    elif badge.status == "none":
        # Unknown: a ring instead of a filled dot, so the shape differs too.
        dot = (
            f'  <circle class="dot-none" cx="{dot_x}" cy="{HEIGHT / 2}" '
            f'r="{DOT_SIZE / 2 - 0.75}" fill="none" stroke-width="1.5"/>\n'
        )
    else:
        dot = (
            f'  <circle class="dot-{badge.status}" cx="{dot_x}" '
            f'cy="{HEIGHT / 2}" r="{DOT_SIZE / 2}"/>\n'
        )

    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {HEIGHT}" '
        f'width="{width}" height="{HEIGHT}" role="img" aria-label="{title}">\n'
        f"  <title>{title}</title>\n"
        "  <style>\n"
        f"    .tile {{ fill: {LIGHT['group']}; stroke: {LIGHT['sep']}; }}\n"
        f"    .icon {{ stroke: {LIGHT['label2']}; }}\n"
        f"    .label {{ fill: {LIGHT['label2']}; }}\n"
        f"    .value {{ fill: {LIGHT['label']}; font-variant-numeric: tabular-nums; }}\n"
        f"    .dot-now {{ fill: {LIGHT['accent']}; }}\n"
        f"    .dot-ok {{ fill: {LIGHT['green']}; }}\n"
        f"    .dot-fail {{ fill: {LIGHT['red']}; }}\n"
        f"    .dot-none {{ stroke: {LIGHT['label2']}; }}\n"
        "    @media (prefers-color-scheme: dark) {\n"
        f"      .tile {{ fill: {DARK['group']}; stroke: {DARK['sep']}; }}\n"
        f"      .icon {{ stroke: {DARK['label2']}; }}\n"
        f"      .label {{ fill: {DARK['label2']}; }}\n"
        f"      .value {{ fill: {DARK['label']}; }}\n"
        f"      .dot-now {{ fill: {DARK['accent']}; }}\n"
        f"      .dot-ok {{ fill: {DARK['green']}; }}\n"
        f"      .dot-fail {{ fill: {DARK['red']}; }}\n"
        f"      .dot-none {{ stroke: {DARK['label2']}; }}\n"
        "    }\n"
        "  </style>\n"
        f'  <rect class="tile" x="0.5" y="0.5" width="{width - 1}" '
        f'height="{HEIGHT - 1}" rx="{RADIUS - 0.5}" stroke-width="1"/>\n'
        f'  <g class="icon" transform="translate({icon_x} {icon_y}) scale({scale})" '
        'fill="none" stroke-width="1.6" stroke-linecap="round" '
        f'stroke-linejoin="round">{ICONS[badge.icon]}</g>\n'
        f'  <text class="label" x="{label_x}" y="{BASELINE_Y}" '
        f'font-family="{FONT_FAMILY}" font-size="{FONT_SIZE}" font-weight="400" '
        f'textLength="{label_w}" lengthAdjust="spacing">{label}</text>\n'
        f'  <text class="value" x="{value_x}" y="{BASELINE_Y}" '
        f'font-family="{FONT_FAMILY}" font-size="{FONT_SIZE}" font-weight="600" '
        f'textLength="{value_w}" lengthAdjust="spacing">{value}</text>\n'
        f"{dot}"
        "</svg>\n"
    )


def load_data(path: Path) -> dict:
    """Read and validate the dynamic badge data."""
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        fail("File not found", f"Data file {path} does not exist.")
    except json.JSONDecodeError as error:
        fail("Invalid JSON", f"Data file {path} is not valid JSON: {error}.")

    for key in ("last_commit", "size_kb", "license"):
        if key not in data or data[key] in (None, ""):
            fail("Data missing", f"Key '{key}' is missing in {path}.")
    return data


def build_badges(data: dict) -> list[Badge]:
    """Return every badge, dynamic ones first."""
    try:
        last_commit = format_date(str(data["last_commit"]))
        size = human_size(int(data["size_kb"]))
    except (ValueError, TypeError) as error:
        fail("Invalid data", f"Could not read the badge data: {error}.")

    linter, linter_status = run_status(data.get("super_linter"))
    codeql, codeql_status = run_status(data.get("codeql"))

    return [
        Badge("super_linter", "search", "Super Linter", linter, True, linter_status),
        Badge("codeql", "shield", "CodeQL", codeql, True, codeql_status),
        Badge("last_commit", "commit", "Last commit", last_commit, True),
        Badge("repo_size", "box", "Repo size", size, True),
        Badge("license", "scales", "License", str(data["license"]), True),
        Badge("changelog", "list", "Changelog", "Keep a Changelog 1.1.0"),
        Badge("contributor_covenant", "heart", "Contributor Covenant", "3.0"),
        Badge("conventional_commits", "check", "Conventional Commits", "1.0.0"),
        Badge("semver", "tag", "SemVer", "2.0.0"),
    ]


def main() -> int:
    """Parse arguments and write the SVG files."""
    parser = argparse.ArgumentParser(description="Generate README badges.")
    parser.add_argument("--data", required=True, type=Path, help="JSON data file")
    parser.add_argument("--output", required=True, type=Path, help="output folder")
    args = parser.parse_args()

    badges = build_badges(load_data(args.data))
    args.output.mkdir(parents=True, exist_ok=True)

    for badge in badges:
        target = args.output / f"{badge.name}.svg"
        target.write_text(render(badge), encoding="utf-8")
        logger.info("Wrote %s (%s: %s)", target, badge.label, badge.value)

    logger.info("Generated %d badge(s) in %s.", len(badges), args.output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
