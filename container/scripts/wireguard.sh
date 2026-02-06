#!/bin/bash
set -euo pipefail

# Load utility
source /etc/openjanus/scripts/util.sh

# Variables
WG_IF=wg0
WG_CONF=/etc/wireguard/$WG_IF.conf
VPN_SERVER_IP=10.13.13.1
WG_PORT=51820
PEERS_RAW=${WG_PEERS:-}
PEER_CONF_PATH=/etc/wireguard/peers

# Check required environment variable
if [ -z "$VPN_ENDPOINT" ]; then
  log "error" "WireGuard" "Environment variable VPN_ENDPOINT is not set. Exiting."
  exit 1
else
  log "info" "WireGuard" "VPN_ENDPOINT environment variable found!: $VPN_ENDPOINT"
fi

if [ -z "$VPN_PORT" ]; then
  log "error" "WireGuard" "Environment variable VPN_PORT is not set. Exiting."
  exit 1
else
  log "info" "WireGuard" "VPN_PORT environment variable found!: $VPN_PORT"
fi

mkdir -p /etc/wireguard $PEER_CONF_PATH

# generate server keypair if not present
if [ ! -f /etc/wireguard/server_private.key ]; then
  log "warning" "WireGuard" "Server private key not found!. Generating new public and private key..."
  ls /etc/wireguard/
  umask 077
  wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
else
  log "info" "WireGuard" "Reusing existing server private & public key."
fi

# Save private and public key
SERVER_PRIV=$(cat /etc/wireguard/server_private.key)
SERVER_PUB=$(cat /etc/wireguard/server_public.key)

# build base wg conf
if [ ! -f "$WG_CONF" ]; then
  log "warning" "WireGuard" "File '$WG_CONF' not found. Generating..."
  cat > "$WG_CONF" <<EOF
[Interface]
Address = ${VPN_SERVER_IP}/24
ListenPort = ${WG_PORT}
PrivateKey = ${SERVER_PRIV}
SaveConfig = true
EOF
else
  log "info" "WireGuard" "Reusing '$WG_CONF' file."
fi

# function to add a peer
add_peer() {
  local name="$1"
  local ip="$2"
  local peer_conf_path="$PEER_CONF_PATH/${name}.conf"
  local existing_entry

  existing_entry=$(grep -A2 "# ${name}" "$WG_CONF" 2>/dev/null || true)
  if [ -n "$existing_entry" ]; then
    log "notice" "WireGuard" "Peer '$name' already exists. Skipping..."
    return
  fi

  log "info" "WireGuard" "Adding a new peer '$name' (${ip})."

  # Generate or reuse peer key
  local peer_priv peer_pub
  if [ -f "$peer_conf_path" ]; then
    peer_priv=$(grep -A0 'PrivateKey' "$peer_conf_path" | awk '{print $3}')
  fi
  if [ -z "${peer_priv:-}" ]; then
    peer_priv=$(wg genkey)
  fi
  peer_pub=$(echo "$peer_priv" | wg pubkey)

  # Append to wg0.conf
  cat >> "$WG_CONF" <<EOP

[Peer]
# ${name}
PublicKey = ${peer_pub}
AllowedIPs = ${ip}/32
EOP

  # Create or overwrite client config
  cat > "$peer_conf_path" <<EOC
[Interface]
PrivateKey = ${peer_priv}
Address = ${ip}/24
DNS = 1.1.1.1

[Peer]
PublicKey = ${SERVER_PUB}
Endpoint = ${VPN_ENDPOINT}:${VPN_PORT}
AllowedIPs = 10.13.13.0/24, $SERVER_PUBLIC_IP/32
PersistentKeepalive = 25
EOC

  # Print QR for first time
  if command -v qrencode >/dev/null 2>&1; then
    log "notice" "WireGuard" "QR for peer: ${name}"
    qrencode -t ANSIUTF8 -o - < "$peer_conf_path"
  fi
}

# Parse WG_PEERS
if [ -n "$PEERS_RAW" ]; then
  IFS=',' read -ra entries <<< "$PEERS_RAW"
  for e in "${entries[@]}"; do
    # trim
    e=$(echo "$e" | tr -d '[:space:]')
    name=$(echo "$e" | cut -d':' -f1)
    ip=$(echo "$e" | cut -d':' -f2)
    if [ -z "$name" ] || [ -z "$ip" ]; then
      log "error" "WireGuard" "Skipping invalid peer entry $e"
      continue
    fi
    add_peer "$name" "$ip"
  done
else
  log "warning" "WireGuard" "No 'WG_PEERS' provided. Skipping creating peers."
fi

# bring up the interface
chmod 600 "$WG_CONF"

log "warning" "WireGuard" "wg-quick up."
wg-quick up "$WG_IF" || true

log "warning" "WireGuard" "Setting IP routing"

ip route add 10.13.13.0/24 dev wg0 || true
iptables -t nat -A PREROUTING -i wg0 -d $SERVER_PUBLIC_IP -p tcp --dport 443 -j DNAT --to-destination $(hostname -i):443

log "success" "WireGuard" "Successfully configured."
