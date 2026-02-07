#!/bin/bash
set -euo pipefail

# Load utility
source ./scripts/util.sh

log "info" "Publish" "Publishing image v$version"

# Push
./scripts/build.sh push

log "success" "Publish" "✅ Image v$version published successfully!"
