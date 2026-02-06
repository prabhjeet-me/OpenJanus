#!/bin/bash
set -euo pipefail

# Load utility
source ./scripts/util.sh

version=$(jq -r '.version' package.json)

log "info" "Build" "Building image v$version"

# Build image using buildx
docker buildx build --build-arg VERSION=$version --platform linux/amd64,linux/arm64 \
    -t prabhjeetme/openjanus:$version-alpine \
    -t prabhjeetme/openjanus:latest \
    $( [ "${1:-}" = "push" ] && echo --push ) .

log "success" "Build" "✅ Image v$version build successfully!"
