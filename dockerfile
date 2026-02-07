# =========== Stage 1 — Builder ===========

FROM node:24-slim AS builder

RUN apt update && apt install jq -y

WORKDIR /openjanus

# Dependencies
COPY package*.json ./

RUN npm ci

# Copy source
COPY . .

ENV LOG_FILE_PATH="./"

# Build pages
RUN npm run build:pages

# =========== Stage 2 — Runtime ===========

# Base image
FROM openresty/openresty:1.27.1.2-alpine

# =============== Arguments ===============

ARG VERSION

LABEL maintainer="Prabhjeet Singh <dev@prabhjeet.me>"
LABEL version="${VERSION}"
LABEL description="An open-source, containerized infrastructure stack combining OpenResty, automatic SSL, and a built-in WireGuard VPN to securely expose public and private endpoints with minimal configuration and operational overhead."

# =========== Required Packages ===========

RUN apk add --no-cache certbot openssl wireguard-tools iproute2 openssl bash curl iptables libqrencode-tools gettext \
    && rm -rf /var/cache/apk/*

# ========= Environment Variables =========

# Version
ENV VERSION=${VERSION}

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

# DH param size
ENV SSL_DH_SIZE=2048

# =================== Copy ===================

# Scripts
COPY --from=builder /openjanus/container/scripts /etc/openjanus/scripts
COPY --from=builder /openjanus/scripts/util.sh /etc/openjanus/scripts/util.sh

# Configuration presets
COPY --from=builder /openjanus/container/conf/presets /etc/openjanus/presets

# Nginx config template
COPY --from=builder /openjanus/container/conf/nginx.template.conf /usr/local/openresty/nginx/templates/nginx.conf

# Nginx default server
COPY --from=builder /openjanus/container/conf/default.conf /etc/nginx/conf.d/default.conf

# Error pages
COPY --from=builder /openjanus/container/html /usr/local/openresty/nginx/html

# ================= Commands =================

# Make scripts executable
RUN chmod +x /etc/openjanus/scripts/*.sh

# Substitute version in server header
RUN envsubst '$VERSION' < /usr/local/openresty/nginx/templates/nginx.conf > /usr/local/openresty/nginx/conf/nginx.conf

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

# OpenJanus directory
VOLUME /etc/openjanus

# OpenJanus var
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
