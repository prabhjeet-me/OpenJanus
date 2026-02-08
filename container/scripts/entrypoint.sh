#!/bin/bash
set -euo pipefail

# Load utility
source /etc/openjanus/scripts/util.sh

log "info" "OpenJanus" "v$OPENJANUS_VERSION"

log "info" "EntryPoint" "Configuring WireGuard..."

# Configure WireGuard
bash /etc/openjanus/scripts/wireguard.sh

log "info" "EntryPoint" "Configuring SSL..."

# Configure SSL
bash /etc/openjanus/scripts/ssl.sh

log "success" "EntryPoint" "Success"

# Execute the command passed to CMD or other application logic
exec "$@"
