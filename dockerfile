# Base image
FROM openresty/openresty:alpine

# Install required packages
RUN apk add --no-cache certbot openssl wireguard-tools iproute2 openssl bash curl iptables libqrencode-tools \
    && rm -rf /var/cache/apk/*

# ========= Environment Variables =========

# Email to register to letsencrypt
ENV CB_EMAIL=

# Domains to request certificate for
ENV CB_DOMAINs=

# SSL renewal pattern (Default: Midnight)
ENV CB_CRON_PATTERN="0 0 * * *"

# Server's public IP where container is container is deployed (required for VPN)
ENV SERVER_PUBLIC_IP=

# VPN Endpoint (Ex: vpn.example.com)
ENV VPN_ENDPOINT=

# VPN port (51820 default WireGuard port. Change if a different port is mapped on host)
ENV VPN_PORT=51820

# 1 if enable testing mode (--staging on certbot commands)
ENV TEST=0

# DH param size
ENV SSL_DH_SIZE=2048

# ================== Volumes ==================

# Open janus directory
VOLUME /etc/openjanus

# Openresty first run state
VOLUME /var/lib/openjanus

# Certificate storage
VOLUME /etc/letsencrypt

# SSL certificates
VOLUME /etc/ssl/certs/dhparam

# Wireguard
VOLUME /etc/wireguard

# =================== Ports ===================

# Expose HTTP, HTTPS & WireGuard VPN port
EXPOSE 80 443 51820/udp

# Command
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
