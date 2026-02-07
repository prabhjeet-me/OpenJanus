#!/bin/bash
set -euo pipefail

# Load utility
source ./scripts/util.sh

version=$(jq -r '.version' package.json)

log "info" "Export" "Exporting image v$version"

# Build (Testing image for export)
./scripts/build.sh

# Output directory
mkdir -p output

# Save image to output folder
docker save prabhjeetme/openjanus:$version-alpine -o output/prabhjeetme_openjanus-$version-alpine.tar

log "success" "Export" "✅ Image v$version exported successfully!"
