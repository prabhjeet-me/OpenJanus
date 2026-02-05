#!/bin/bash
set -euo pipefail

# Load utility
source ./scripts/util.sh

version=$(jq -r '.version' package.json)

log "info" "Build" "Building image v$version"

# Build image using buildx
docker buildx build -t openjanus:$version .

log "success" "Build" "✅ Image v$version build successfully!"
