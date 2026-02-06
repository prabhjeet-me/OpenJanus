#!/bin/bash
set -euo pipefail

# Load utility
source ./scripts/util.sh

version=$(jq -r '.version' package.json)

log "info" "Build" "Building image v$version"

# Build image using buildx
build() {
    docker buildx build --build-arg VERSION=$version --platform linux/amd64,linux/arm64 -t prabhjeetme/openjanus:$1 .
}

build $version-alpine
build latest

log "success" "Build" "✅ Image v$version build successfully!"
