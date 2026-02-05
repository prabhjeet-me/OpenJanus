# Base image
FROM openresty/openresty:alpine

LABEL maintainer="Prabhjeet Singh <dev@prabhjeet.me>"

# Install required packages
RUN apk add --no-cache certbot openssl wireguard-tools iproute2 openssl bash curl iptables libqrencode-tools \
    && rm -rf /var/cache/apk/*

# ========= Environment Variables =========

# Email to register to letsencrypt
ENV CB_TESTING="0"

# Openjanus log file path
ENV LOG_FILE_PATH="/var/log/openjanus"

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

# =================== Copy ===================

# Scripts
COPY ./container/scripts /etc/openjanus/scripts
COPY ./scripts/util.sh /etc/openjanus/scripts/util.sh

# Configuration presets
COPY ./container/conf/presets /etc/openjanus/presets

# Nginx configs
COPY ./container/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY ./container/conf/default.conf /etc/nginx/conf.d/default.conf

# Error pages
COPY ./container/html /usr/local/openresty/nginx/html

# ================= Commands =================

# Make scripts executable
RUN chmod +x /etc/openjanus/scripts/*.sh

# For DH param file
RUN mkdir -p /etc/openjanus/ssl

# Configuration directories
RUN mkdir -p /etc/openjanus/conf
RUN mkdir -p /etc/openjanus/stream

# For certbot challenge
RUN mkdir -p /var/www/certbot

# Stream configs
RUN mkdir -p /etc/nginx/stream.d

# Wireguard
RUN mkdir -p /etc/wireguard

# ================== Volumes ==================

# Open janus directory
VOLUME /etc/openjanus

# Open janus var
VOLUME /var/lib/openjanus

# Certificate storage
VOLUME /etc/letsencrypt

# Wireguard
VOLUME /etc/wireguard

# =================== Ports ===================

# Expose HTTP, HTTPS & WireGuard VPN port
EXPOSE 80 443 51820/udp

# Entry point
ENTRYPOINT [ "/etc/openjanus/scripts/entrypoint.sh" ]

# Command
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
