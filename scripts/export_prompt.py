#!/usr/bin/env python3
"""
Export a JSON prompt as plain text for pasting into Gemini's web UI.
Usage: python scripts/export_prompt.py <prompt.json>
"""

import sys
import json


def load_prompt(prompt_file: str) -> dict:
    with open(prompt_file) as f:
        return json.load(f)


def export_text(prompt_data: dict) -> str:
    """Convert structured JSON prompt to plain text for Gemini web UI."""
    text = prompt_data["prompt"]
    negative = prompt_data.get("negative_prompt", "")
    if negative:
        text += f"\n\nAvoid the following: {negative}"
    return text


def main():
    if len(sys.argv) < 2:
        print("Usage: python scripts/export_prompt.py <prompt.json>")
        sys.exit(1)

    prompt_data = load_prompt(sys.argv[1])
    print(export_text(prompt_data))


if __name__ == "__main__":
    main()
