#!/usr/bin/env bash
# Demo: Image Restoration — Gemini web UI path
# User provides a scanned photo → tool outputs plain text → paste into Gemini

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
echo "║  nano-banana-images — Image Restoration: Gemini Web UI Path    ║"
echo "║  User request → Structured plain text → Paste into Gemini      ║"
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
_print_slow "3" 0.03
echo ""
sleep 1.0

# Step 3: Tool outputs plain text
echo "━━━ Step 3: Structured plain-text restoration prompt ━━━"
echo ""
sleep 0.5
_print_slow "Copy this prompt and paste it into gemini.google.com alongside your photo:" 0.02
echo ""
sleep 0.5
echo "┌──────────────────────────────────────────────────────────────┐"

cat << 'EOF'
│ Perform technical image restoration on this uploaded            │
│ photograph. This is a scanned vintage film photograph from my   │
│ personal family album. Apply the following image processing     │
│ operations:                                                     │
│                                                                 │
│ 1. ANALYZE IMAGE FILE PROPERTIES: Evaluate resolution,          │
│    sharpness, noise level, color balance, film grain density,   │
│    dust and scratch marks, compression artifacts, dynamic range. │
│                                                                 │
│ 2. UPSCALE TO 4K: Increase pixel resolution to 4K (3840px on   │
│    the long edge, maintaining original aspect ratio).           │
│                                                                 │
│ 3. SHARPEN: Apply unsharp mask and detail recovery to restore   │
│    edge crispness. Enhance micro-contrast.                      │
│                                                                 │
│ 4. COLOR CORRECTION: Neutralize color cast from aged film dyes. │
│    Restore accurate white balance. Recover true colors.         │
│                                                                 │
│ 5. ARTIFACT REMOVAL: Remove film grain, dust specks, scratches, │
│    and scanning artifacts while preserving genuine detail.       │
│                                                                 │
│ CONSTRAINTS: Do NOT alter content. Do NOT add details that do   │
│ not exist. Do NOT change framing or composition. Only apply:    │
│ upscaling, sharpening, color correction, artifact removal.      │
│                                                                 │
│ Avoid: altering content, adding non-existing details, inventing │
│ elements, changing composition, CGI, 3D render, over-saturation,│
│ HDR glow, artificial lens flare, hallucinated details           │
EOF

echo "└──────────────────────────────────────────────────────────────┘"
echo ""
sleep 1.5

echo "━━━ Next steps ━━━"
echo ""
echo "  1. Go to gemini.google.com"
echo "  2. Upload your scanned photo (images/old_family_photo.jpg)"
echo "  3. Paste the prompt above into the chat"
echo "  4. Download the restored image"
echo ""
sleep 4
