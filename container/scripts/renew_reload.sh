#!/bin/bash
set -euo pipefail

# Load utility
source /etc/openjanus/scripts/util.sh

log "info" "SSL" "Renewing certificates..."

if [[ "$CB_TESTING" == "1"]]; then
  log "warning" "SSL" "Test Mode: Using certbot's dry-run command & simulating certificate renewal."
fi

# Renew certificates
certbot renew --webroot -w /var/www/certbot $( [ "$CB_TESTING" = "1" ] && echo --dry-run )

log "info" "SSL" "Reloading Nginx..."

# Restart nginx
nginx -s reload || log "error" "SSL" "Nginx reload failed!"

log "success" "SSL" "Due certificate renewed."
