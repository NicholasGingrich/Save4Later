#!/bin/bash
# Moves Simulator screenshots from Desktop into this folder and renames them.
# Run this once from Terminal after Claude finishes taking screenshots.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP="$HOME/Desktop"

NAMES=(
  "01_light_home.png"
  "02_light_detail.png"
  "03_light_create.png"
  "04_light_search.png"
  "05_dark_home.png"
  "06_dark_detail.png"
  "07_dark_create.png"
  "08_dark_search.png"
)

echo "Looking for Simulator screenshots on Desktop..."

# Find all iPhone simulator PNGs from today, sorted oldest-first
FILES=($(ls -t "$DESKTOP"/iPhone\ *.png 2>/dev/null | tail -r))

if [ ${#FILES[@]} -eq 0 ]; then
  echo "No Simulator screenshots found on Desktop. Make sure you haven't moved them."
  exit 1
fi

echo "Found ${#FILES[@]} screenshot(s). Moving to $SCRIPT_DIR ..."

for i in "${!FILES[@]}"; do
  if [ $i -ge ${#NAMES[@]} ]; then
    break
  fi
  DEST="$SCRIPT_DIR/${NAMES[$i]}"
  mv "${FILES[$i]}" "$DEST"
  echo "  ${NAMES[$i]}"
done

echo ""
echo "Done! Screenshots saved to:"
echo "  $SCRIPT_DIR"
