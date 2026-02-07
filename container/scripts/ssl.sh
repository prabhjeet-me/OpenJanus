#!/bin/bash
set -euo pipefail

# Load utility
source /etc/openjanus/scripts/util.sh

FIRST_RUN_DIR="/var/lib/openjanus/"
FIRST_RUN_FILE="$FIRST_RUN_DIR.first_run_done"

# Test mode warning
if [ "$CB_TESTING" == "1" ]; then
  log "warning" "SSL" "Test Mode: Using certbot's staging environment."
fi

# Generate Diffie-Hellman params
if [ -f /etc/openjanus/ssl/dhparam.pem ]; then
  log "info" "SSL"  "Reusing existing DH params (file already exists)."
else
  log "warning" "SSL" "Missing DH param file, generating a new one. This will take some time, please wait."
  openssl dhparam -out /etc/openjanus/ssl/dhparam.pem $SSL_DH_SIZE
fi

# Copy configs in nginx directory to load
copy_configs() {
  log "info" "SSL"  "Loading nginx config files."

  if compgen -G "/etc/openjanus/conf/*.conf" > /dev/null; then
    # Copy other configs
    cp -r /etc/openjanus/conf/*.conf /etc/nginx/conf.d/
  fi

  if compgen -G "/etc/openjanus/stream/*.conf" > /dev/null; then
    # Copy other configs
    cp -r /etc/openjanus/stream/*.conf /etc/nginx/stream.d/
  fi
}

# Function to monitor nginx response
reload_nginx() {
    # Register and get ssl certificate for defined CB_DOMAINs
    certbot certonly --webroot -w /var/www/certbot --expand $(printf -- '-d %s ' $CB_DOMAINs) --email $CB_EMAIL --non-interactive --agree-tos --no-eff-email $( [ "$CB_TESTING" = "1" ] && echo --staging ) || { log "error" "SSL" "Initial certificate generation failed — exiting."; exit 1; }
    
    log "info" "SSL"  "Reload nginx in 5 seconds..."
    
    sleep 5

    copy_configs

    # Reload nginx
    nginx -s reload

    # Generate first run file
    touch "$FIRST_RUN_FILE"

    log "success" "SSL"  "Initial configuration completed."
}

# Check required environment variable
if [ -z "$CB_EMAIL" ]; then
  log "error" "SSL" "Environment variable CB_EMAIL is not set. Exiting."
  exit 1
else
  log "info" "SSL" "CB_EMAIL environment variable found!: $CB_EMAIL"
fi

# Check required environment variable
if [ -z "$CB_DOMAINs" ]; then
  log "error" "SSL" "Environment variable CB_DOMAINs is not set. Exiting."
  exit 1
else
  log "info" "SSL" "CB_DOMAINs environment variable found!: $CB_DOMAINs"
fi

# Check if first run
if [ ! -f "$FIRST_RUN_FILE" ]; then
    log "info" "SSL" "First run detected, configuring certbot."
    reload_nginx & # Continue container execution
else
    log "info" "SSL" "Skipping certbot setup, Delete '.first_run_done' for invoking initial configuration or adding new domains."
    copy_configs
fi

# Configure cronjob to run based on defined pattern
(crontab -l 2>/dev/null; echo "$CB_CRON_PATTERN /etc/openjanus/scripts/renew_reload.sh 2>&1 | tee -a /var/log/certbot/renewal.log") | crontab -

# Run cron in foreground and show logs in docker logs
crond -f -l 8 & # Continue container execution

log "info" "SSL" "Certificate renewal cron started."
