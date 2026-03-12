#!/usr/bin/env bash
# Demo: Image Restoration — API path
# User provides a scanned photo → tool updates JSON → API restores image

PS1="$ "
clear

_type() {
  echo -n "$ "
  local text="$1"
  for ((i=0; i<${#text}; i++)); do
    echo -n "${text:$i:1}"
    sleep 0.04
  done
  echo
}

_print_slow() {
  local text="$1"
  local delay="${2:-0.01}"
  for ((i=0; i<${#text}; i++)); do
    echo -n "${text:$i:1}"
    sleep "$delay"
  done
  echo
}

sleep 0.5

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  nano-banana-images — Image Restoration: API Path              ║"
echo "║  User request → JSON updated → API call → Restored image       ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
sleep 1.5

# Step 1: User request
echo "━━━ Step 1: User describes what they want ━━━"
echo ""
sleep 0.5
echo -n "User: "
_print_slow "Restore this scanned family photo: images/old_family_photo.jpg" 0.03
echo ""
sleep 1.2

# Step 2: Choose path
echo "━━━ Step 2: Choose restoration method ━━━"
echo ""
sleep 0.5
echo "  Which restoration method do you want?"
echo ""
echo "  1. Kie.ai API        (highest quality, requires KIE_API_KEY)"
echo "  2. Google Gemini API  (requires GEMINI_API_KEY)"
echo "  3. Gemini web UI      (free, manual copy/paste)"
echo ""
sleep 1.5
echo -n "User: "
_print_slow "2" 0.03
echo ""
sleep 1.0

# Step 3: Tool updates JSON
echo "━━━ Step 3: Updating restoration prompt ━━━"
echo ""
sleep 0.5
_print_slow "Adding source image to prompts/image_restoration.json..." 0.02
echo ""
sleep 0.3

cat << 'EOF'
{
  "prompt": "Perform technical image restoration on this uploaded
    photograph. This is a scanned vintage film photograph from my
    personal family album. Apply the following:
    1. ANALYZE IMAGE FILE PROPERTIES
    2. UPSCALE TO 4K (3840px long edge)
    3. SHARPEN (unsharp mask + detail recovery)
    4. COLOR CORRECTION (neutralize aged film dyes)
    5. ARTIFACT REMOVAL (grain, dust, scratches)
    CONSTRAINTS: Do NOT alter content. No hallucinated details.
    No composition changes. Only upscale, sharpen, color correct,
    and remove artifacts.",
  "negative_prompt": "altering content, adding non-existing details,
    inventing elements, changing composition, CGI, 3D render...",
  "image_input": ["images/old_family_photo.jpg"],  ← updated
  "api_parameters": {
    "resolution": "4K",
    "output_format": "png",
    "aspect_ratio": "auto"
  }
}
EOF

echo ""
sleep 1.5

# Step 4: Run restoration
echo "━━━ Step 4: Running API restoration ━━━"
echo ""
sleep 0.5
_type "python scripts/generate_gemini.py prompts/image_restoration.json images/restored_output.png"
sleep 0.4

echo "[INFO] Loading prompt from prompts/image_restoration.json"
sleep 0.5
echo "[INFO] Loading reference image: images/old_family_photo.jpg"
sleep 0.8
echo "[INFO] Generating image with aspect ratio: auto, resolution: 4K"
sleep 0.4
echo "[INFO] Calling Gemini API (this may take a moment)..."
sleep 3.0
echo ""
echo "✓ Image saved to images/restored_output.png  (3840 x 2560, 4K)"
echo ""
sleep 3
