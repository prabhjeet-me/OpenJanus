#!/bin/bash
set -euo pipefail

# Load utility
source ./scripts/util.sh

version=$(node -p "require('./package.json').version")
node_version=$(node -p "require('./dependencies.json').NODE_VERSION")
openresty_version=$(node -p "require('./dependencies.json').OPENRESTY_VERSION")
certbot_version=$(node -p "require('./dependencies.json').CERTBOT_VERSION")
wireguard_version=$(node -p "require('./dependencies.json').WIREGUARD_VERSION")

log "info" "Build" "Building image v$version"

log "info" "Build" "Using Node: $node_version"
log "info" "Build" "Using OpenResty: $openresty_version"
log "info" "Build" "Using Certbot: $certbot_version"
log "info" "Build" "Using WireGuard: $wireguard_version"

# Build image using buildx
docker buildx build \
  --build-arg OPENJANUS_VERSION=$version \
  --build-arg NODE_VERSION=$node_version \
  --build-arg OPENRESTY_VERSION=$openresty_version \
  --build-arg CERTBOT_VERSION=$certbot_version \
  --build-arg WIREGUARD_VERSION=$wireguard_version \
  --platform linux/amd64,linux/arm64 \
  -t prabhjeetme/openjanus:$version-alpine \
  -t prabhjeetme/openjanus:latest \
  $( [ "${1:-}" = "push" ] && echo --push ) .

log "success" "Build" "✅ Image v$version build successfully!"
