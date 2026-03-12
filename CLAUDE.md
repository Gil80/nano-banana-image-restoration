# nano-banana-image-restoration

AI image restoration toolkit for scanned vintage film photographs.

## Project Structure
- `scripts/` — Generation scripts (Kie.ai, Gemini API, export)
- `prompts/` — Structured restoration prompts (JSON + plain text)
- `images/` — Source photos to restore + restored output images
- `demo/` — Demo recordings

## Setup & Run
- Python 3.12, venv in `.venv/`
- API keys in `.env` (never commit)
- Via Kie.ai: `python scripts/generate_kie.py prompts/image_restoration.json images/restored_output.png`
- Via Gemini: `python scripts/generate_gemini.py prompts/image_restoration.json images/restored_output.png`
- Export for Gemini web UI: `python scripts/export_prompt.py prompts/image_restoration.json`

## Conventions
- Use `pathlib` for file paths
- Use `python-dotenv` for env vars
- Scripts follow CLI pattern: `python scripts/<script>.py <prompt.json> <output_path>`
- Version prompt iterations with suffixes: `_v1`, `_v1b`, `_v1c`, `_v2`

## Environment Variables
- `KIE_API_KEY` — Kie.ai nano-banana-2 (primary)
- `GEMINI_API_KEY` — Google AI Studio (Gemini direct)

## Important
- Never commit `.env` or API keys
- Always ask for output resolution (1K/2K/4K) before restoring — it affects billing
- Source image must be added to `image_input` array in the JSON prompt before running
