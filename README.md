# nano-banana-image-restoration

An AI image restoration toolkit that restores and enhances scanned vintage film photographs — upscale to 4K, sharpen, color-correct, and remove artifacts without altering content. Supports API backends (Kie.ai, Google Gemini) and Gemini web UI.

## Demos

**API path** — provide scanned photo → JSON updated → API restores image:

![Restoration API Demo](demo/demo_restore_api.gif)

**Gemini web UI path** — provide scanned photo → plain text prompt → paste into Gemini:

![Restoration Gemini UI Demo](demo/demo_restore_gemini_ui.gif)

## How It Works

You tell the tool which photo to restore, choose your output path, and it handles the rest.

### Step 1: Describe What You Want

Tell Claude Code (with the `nano-banana-image-restoration` skill) which photo to restore:

> "Restore this scanned family photo: images/old_family_photo.jpg, 4K resolution"

Always include the desired **output resolution** in your request: `1K`, `2K`, or `4K`. Resolution affects API billing costs. If you don't specify, the tool will pause and ask.

### Step 2: Choose Your Output Path

The tool asks which restoration method you want to use:

- **API** (Kie.ai, Gemini API) — the tool adds your source image to the `image_input` array in `prompts/image_restoration.json`, then runs the generation script to restore the image and save it to `images/`
- **Gemini web UI** — the tool provides the structured plain-text restoration prompt from `prompts/image_restoration_plain_text.txt` for you to copy/paste into [gemini.google.com](https://gemini.google.com) alongside your uploaded photo

### Path A: API Restoration (automated)

The tool updates `image_restoration.json` with your source image path and runs the script:

```bash
# Via Kie.ai (highest quality)
python scripts/generate_kie.py prompts/image_restoration.json images/restored_output.png

# Via Gemini API
python scripts/generate_gemini.py prompts/image_restoration.json images/restored_output.png
```

The script:
1. Loads the JSON prompt
2. Uploads the source image
3. Sends the restoration prompt to the API
4. Polls for completion (Kie.ai) or waits for response (Gemini)
5. Downloads and saves the restored image to `images/`

Output: PNG saved to `images/`.

### Path B: Gemini Web UI (manual, free, no API key)

1. Go to [gemini.google.com](https://gemini.google.com)
2. Upload your scanned photo
3. Paste the contents of `prompts/image_restoration_plain_text.txt` alongside it
4. Download the restored image from Gemini's response

You can also convert the JSON prompt to plain text:

```bash
python scripts/export_prompt.py prompts/image_restoration.json
```

## What Restoration Does

The restoration prompt instructs the model to perform these steps in order:

1. **Analyze** — evaluate resolution, sharpness, noise, color balance, grain, dust/scratches
2. **Upscale** — increase to target resolution (1K/2K/4K), maintain aspect ratio, reconstruct detail from existing pixels only
3. **Sharpen** — unsharp mask + detail recovery, restore edge crispness, enhance micro-contrast
4. **Color correct** — neutralize aged film dye color casts, restore white balance, recover shadow/highlight detail
5. **Remove artifacts** — film grain, dust specks, scratches, and scanning artifacts

Strict constraints are enforced: no content alteration, no hallucinated details, no composition changes. The model can only upscale, sharpen, color-correct, and remove artifacts.

## Backends

| Script | Provider | API Key | Quality | Speed |
|--------|----------|---------|---------|-------|
| `generate_kie.py` | Kie.ai (nano-banana-2) | `KIE_API_KEY` | Highest | Fast |
| `generate_gemini.py` | Google Gemini API | `GEMINI_API_KEY` | Highest | Fast |
| `export_prompt.py` | Gemini web UI (copy/paste) | None | Highest | Manual |

## Project Structure

```
nano-banana-image-restoration/
├── scripts/
│   ├── generate_kie.py                    # Kie.ai nano-banana-2 API
│   ├── generate_gemini.py                 # Google Gemini API (direct)
│   └── export_prompt.py                   # Convert JSON prompt → plain text
├── prompts/
│   ├── image_restoration.json             # Restoration prompt (for API backends)
│   └── image_restoration_plain_text.txt   # Restoration prompt (for Gemini web UI)
├── images/
│   └── *.jpg / *.png                      # Source photos + restored outputs
├── demo/
│   ├── demo_restore_api.gif               # Demo: restoration via API
│   └── demo_restore_gemini_ui.gif         # Demo: restoration via Gemini web UI
├── .env                                   # API keys (not committed)
└── requirements.txt
```

## Quick Start

### 1. Clone and install

```bash
git clone https://github.com/Gil80/nano-banana-image-restoration.git
cd nano-banana-image-restoration
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Configure API keys

Copy `.env.example` to `.env` and add your keys:

```
KIE_API_KEY=your_key_here
GEMINI_API_KEY=your_key_here
```

### 3. Place your source photo

Copy the scanned photo you want to restore into the `images/` folder.

### 4. Restore

Ask Claude Code (with the `nano-banana-image-restoration` skill):

> "Restore images/old_family_photo.jpg, 4K resolution"

Or run manually:

```bash
# Edit prompts/image_restoration.json — set image_input to your photo path
python scripts/generate_gemini.py prompts/image_restoration.json images/restored_output.png
```

### 5. Iterate

Version your restoration prompts to track refinements: `image_restoration_v1.json` → `image_restoration_v1b.json` → `image_restoration_v2.json`.

## Prompt JSON Schema

| Field | Required | Description |
|-------|----------|-------------|
| `prompt` | Yes | Restoration instructions (analyze, upscale, sharpen, color-correct, remove artifacts) |
| `negative_prompt` | Yes | Blocklist preventing content alteration, hallucination, CGI, etc. |
| `image_input` | Yes | Array containing the path to the source photo to restore |
| `api_parameters.resolution` | Yes | `"1K"`, `"2K"`, or `"4K"` — output resolution |
| `api_parameters.output_format` | No | `"jpg"` or `"png"` (default: `"png"` for restoration) |
| `api_parameters.aspect_ratio` | No | `"auto"` preserves original aspect ratio |
| `settings` | No | Metadata for style, lighting preservation, quality |

## Key Concepts

- **Resolution matters** — always specify 1K, 2K, or 4K; resolution affects API billing costs and output quality
- **Preservation-only** — the model upscales, sharpens, color-corrects, and removes artifacts but never alters, adds, or removes content
- **Two paths** — API (automated, requires API key) or Gemini web UI (free, manual copy/paste)
- **Iterative refinement** — version your prompt files to track what changes improve restoration quality

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `KIE_API_KEY` | For Kie.ai | Kie.ai API key |
| `GEMINI_API_KEY` | For Gemini API | Google AI Studio API key |

## Related

For AI image **generation** (creating new images from text descriptions), see [nano-banana-images](https://github.com/Gil80/nano-banana-images).

## License

MIT
